module Analyze
    include("board.jl")
    include("color.jl")
    include("common.jl")
    include("hash.jl")
    include("io.jl")
    include("makemove.jl")
    include("record.jl")
    include("table.jl")
    include("feature1.jl")
    include("position.jl")
    using Flux
    using JLD2
    using CUDA
    using Random
    using Dates
    struct Join{T, F}
        combine::F
        paths::T
    end
    Join(combine, paths...) = Join(combine, paths)
    Flux.@functor Join
    (m::Join)(xs::Tuple) = m.combine(map((f, x) -> f(x), m.paths, xs)...)
    (m::Join)(xs...) = m(xs)

    #Learn1のモデルでの解析
    function AnalyzePolicy(ht, tbl, model_file_name, record_file_name, analyze_file_name, str_game_date, str_game_name)
        model_file_name = "model.jld2"
        ch = 192
        input_dim = 44
        output_dim = 1
        model = Chain(
            Conv((5,5), input_dim=>ch, pad=2, bias=false),
            BatchNorm(ch),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            SkipConnection(Chain(Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch), relu, Conv((3,3), ch=>ch, pad=1, bias=false), BatchNorm(ch)), +),
            relu,
            Conv((1,1), ch=>output_dim, pad=0, bias=true)
            )|>gpu
        bt = BoardTree(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        #model = Chain(Dense(input_dim => output_dim, sigmoid))|>gpu
        model_state = JLD2.load(model_file_name, "model_state")
        Flux.loadmodel!(model, model_state)
        batch_size = 32
        total_acc_cnt = 0
        Flux.testmode!(model)
        records, _ = IO.ReadRecords(record_file_name)
        io = open(analyze_file_name, "w")
        current_record = records[1]
        s = "対局日：" * str_game_date * "\n\n"
        write(io, s)
        s = "棋戦名：" * str_game_name * "\n\n"
        write(io, s)
        s = "黒番：" * current_record.player[1] * "\n\n"
        write(io, s)
        s = "白番：" * current_record.player[2] * "\n\n"
        write(io, s)

        Board.Init(bt)
        limit = length(current_record.moves)
        total_move_cnt = limit
        color = Color.black
        Board.Init(bt)
        color = Color.black
        test_batch = []
        test_label = []
        moves_stack = []
        test_color = []
        temp_label = zeros(Int64, batch_size)
        temp_direc = zeros(Int64, batch_size)
        counter = 1
        acc_cnt = 0
        black_acc_cnt = 0
        white_acc_cnt = 0
        black_cnt = 0
        white_cnt = 0
        ply = 1
        for j = 1:limit
            move = current_record.moves[j]
            f = Feature1.MakeInputFeature(bt, color, tbl)
            f = stack(f)
            lbl = zeros(Float32, 361)
            lbl[move] = 1
            push!(test_batch, f)
            push!(test_label, lbl)
            push!(test_color, color)

            ll = length(test_color)

            temp_moves =[]
            bb_empty = bt.bb_empty
            for k = 1:BB_Cnt
                bb = bb_empty[k]
                while bb > 0
                    pos = findfirst('1', bitstring(bb)) - Bit_Diff[k]
                    sq = pos + Bit_Delta[k]
                    bb = xor(bb, tbl.bb_mask[sq][Index_BB[sq]])
                    push!(temp_moves, sq)
                end
            end

            temp_moves = values(temp_moves)
            push!(moves_stack, temp_moves)

            if counter == batch_size || j == limit
                if counter == batch_size
                    start_index = j - batch_size + 1
                    end_index = j
                else
                    start_index = j - counter + 1
                    end_index = j
                end
                test_batch = stack(test_batch)
                #println(size(test_batch))
                bs = batch_size
                if counter != batch_size
                    bs = counter
                end
                test_batch = reshape(test_batch, (19, 19, input_dim, bs))
                test_label = stack(test_label)
                test_label = reshape(test_label, (19, 19, 1, bs))
                x = gpu(test_batch)
                t = gpu(test_label)
                y = model(x)
                y = y|>cpu
                y0 = stack(y)
                bs = counter
                y0 = reshape(y0, (Square_NB, bs))
                index = 1
                for k = start_index:end_index
                    flag = false
                    correct_move = current_record.moves[k]
                    str_correct_move = string(Str_Square2[correct_move])
                    first_move = 362
                    second_move = 362
                    third_move = 362
                    str_color = "●"
                    if test_color[k] == 2
                        str_color = "○"
                        white_cnt += 1
                    else
                        black_cnt += 1
                    end
                    correct_digit = y0[correct_move, index]
                    all_moves = moves_stack[k]
                    digits = []
                    ms = []
                    for m in all_moves
                        if m == correct_move
                            continue
                        end
                        digit = y0[m, index]
                        push!(digits, digit)
                        push!(ms, m)
                    end
                    dl = length(digits)
                    if dl == 0
                        first_move = correct_move
                        acc_cnt += 1
                        flag = true
                        if test_color[k] == 1
                            black_acc_cnt += 1
                        else
                            white_acc_cnt += 1
                        end
                    elseif dl == 1
                        #※2番目の候補手を取得する処理を追加する。
                        max_digit = digits[1]
                        if correct_digit >= max_digit
                            first_move = correct_move
                            acc_cnt += 1
                            flag = true
                            if test_color[k] == 1
                                black_acc_cnt += 1
                            else
                                white_acc_cnt += 1
                            end
                        end
                    else
                        #※2番目と3番目の候補手を取得する処理を追加する。
                        max_digit = maximum(digits, dims=1)
                        temp_index = argmax(digits)
                        if correct_digit >= max_digit[1]
                            first_move = correct_move
                            acc_cnt += 1
                            flag = true
                            if test_color[k] == 1
                                black_acc_cnt += 1
                            else
                                white_acc_cnt += 1
                            end
                        else
                            #temp_index = argmax(digits)
                            first_move = ms[temp_index]
                            flag = false
                        end
                        if dl == 2
                            digits[temp_index] = -32767
                            temp_index = argmax(digits)
                            second_move = ms[temp_index]
                        else
                            digits[temp_index] = -32767
                            temp_index = argmax(digits)
                            second_move = ms[temp_index]
                            digits[temp_index] = -32767
                            temp_index = argmax(digits)
                            third_move = ms[temp_index]
                        end
                    end
                    #ml = length(all_moves)
                    #candidates = []
                    #if ml == 1
                    #    push!(candidates, all_moves[1])
                    #elseif ml == 2
                    #    if digits[1] >= digits[2]
                    #        push!(candidates, all_moves[1])
                    #        push!(candidates, all_moves[2])
                    #    else
                    #        push!(candidates, all_moves[2])
                    #        push!(candidates, all_moves[1])
                    #    end
                    #elseif ml == 3
                    #    if digits[1] >= digits[2] && digits[1] >= digits[3] && digits[2] >= digits[3]
                    #        push!(candidates, all_moves[1])
                    #        push!(candidates, all_moves[2])
                    #        push!(candidates, all_moves[3])
                    #    elseif digits[1] >= digits[2] && digits[1] >= digits[3] && digits[2] < digits[3]
                    #        push!(candidates, all_moves[1])
                    #        push!(candidates, all_moves[3])
                    #        push!(candidates, all_moves[2])
                    #    elseif digits[2] >= digits[1] && digits[2] >= digits[3] && digits[1] >= digits[3]
                    #        push!(candidates, all_moves[2])
                    #        push!(candidates, all_moves[1])
                    #        push!(candidates, all_moves[3])
                    #    elseif digits[2] >= digits[1] && digits[2] >= digits[3] && digits[1] < digits[3]
                    #        push!(candidates, all_moves[2])
                    #        push!(candidates, all_moves[3])
                    #        push!(candidates, all_moves[1])
                    #    elseif digits[3] >= digits[1] && digits[3] >= digits[2] && digits[1] >= digits[2]
                    #        push!(candidates, all_moves[3])
                    #        push!(candidates, all_moves[1])
                    #        push!(candidates, all_moves[2])
                    #    elseif digits[3] >= digits[1] && digits[3] >= digits[2] && digits[1] < digits[2]
                    #        push!(candidates, all_moves[3])
                    #        push!(candidates, all_moves[2])
                    #        push!(candidates, all_moves[1])
                    #    end
                    #elseif ml >= 4
                    #end
                    str_first_move = string(Str_Square2[first_move])
                    str_tf = "×"
                    if flag == true
                        str_tf = "○"
                    end
                    #str_out = "ply=" * string(ply) * "   pro= " * str_color * str_correct_move * ",   候補手1= " * str_first_move * ",   result= " * str_tf
                    str_out = "ply=" * string(ply) * "   pro= " * str_color * str_correct_move * ",   候補手= " * str_first_move * ",   result= " * str_tf
                    #if second_move != 362
                    #    str_second_move = string(Str_Square2[second_move])
                    #    str_tf = "×"
                    #    if second_move == correct_move
                    #        str_tf = "○"
                    #    end
                    #    str_out *= ",    候補手2= " * str_second_move * ",   result= " * str_tf
                    #end
                    #if third_move != 362
                    #    str_third_move = string(Str_Square2[third_move])
                    #    str_tf = "×"
                    #    if third_move == correct_move
                    #        str_tf = "○"
                    #    end
                    #    str_out *= ",    候補手3= " * str_third_move * ",   result= " * str_tf
                    #end
                    str_out *= "\n"
                    ply += 1
                    write(io, str_out)
                    index += 1
                end
                test_batch = []
                test_label = []
                counter = 0
            end
            MakeMove.Do(bt, move, color, j, ht, tbl)
            color = Flip_Color[color]
            counter += 1
        end
        accuracy = acc_cnt / limit
        accuracy *= 100
        accuracy = round(accuracy; digits=2)
        b_accuracy = black_acc_cnt / black_cnt
        b_accuracy *= 100
        b_accuracy = round(b_accuracy; digits=2)
        w_accuracy = white_acc_cnt / white_cnt
        w_accuracy *= 100
        w_accuracy = round(w_accuracy; digits=2)
        write(io, "\n")
        str_out = "黒番一致率：" * string(black_acc_cnt) * " / " * string(black_cnt) * " " * string(b_accuracy) * "%\n\n"
        write(io, string(str_out))
        str_out = "白番一致率：" * string(white_acc_cnt) * " / " * string(white_cnt) * " " * string(w_accuracy) * "%\n\n"
        write(io, string(str_out))
        str_out = "全体一致率：" * string(acc_cnt) * " / " * string(limit) * " " * string(accuracy) * "%\n"
        write(io, string(str_out))
        #acc_rate = acc_cnt / limit
        #total_acc_cnt += acc_cnt
        #println("[record "*string(i)*"]")
        #println(string(acc_cnt)*" / "*string(limit))
        #println("accuracy="*string(acc_rate) * ")
        close(io)
    end
    #total_acc_rate = total_acc_cnt / total_move_cnt
    #println("")
    #println(string(total_acc_cnt)*" / "*string(total_move_cnt))
    #println("accuracy="*string(total_acc_rate))
    #close(io)
end
export Analyze