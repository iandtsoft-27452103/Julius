module Learn1
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
    #ResNet Conv2Dによる学習
    #手の選択用パラメータ
    #棋譜からの学習
    function TrainPolicy(record_no, epoch_num, batch_size, is_load_model, ht, tbl)
        console_out_threshold = 25
        file_name = "model.jld2"
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
        wd = Flux.Optimise.WeightDecay(0.0001)
        opt = Flux.Optimiser(wd, Nesterov(0.00018, 0.9))
        #opt = Flux.Optimiser(wd, RMSProp(0.001, 0.9))
        opt_state = Flux.setup(opt, model)|>gpu
        if is_load_model == true
            model = model |>cpu
            #opt_state = opt_state |>cpu
            model_state = JLD2.load(file_name, "model_state")
            #opt_state = JLD2.load(file_name, "opt_state")
            Flux.loadmodel!(model, model_state)
            model = model|>gpu
            #opt_state = opt_state|>gpu
        end
        record_file_name = "records" * string(record_no) * ".txt"
        records, pos_num = IO.ReadRecords(record_file_name)
        pos = Position.NumberPosition(records, pos_num)
        iteration_max = pos_num ÷ batch_size
        println("iteration_num = " * string(iteration_max))
                #※後で直す
        iteration_max = 15000
        total_loss = 0
        iteration_count = 0
        for i = 1:epoch_num
            t = now()
            s = "epoch" * string(i) * " start! " * string(t)
            println(s)
            pos = shuffle(pos)
            console_out_counter = 0
            for j = 1:iteration_max
                #println(iteration_count)
                loop_start = (j - 1) * batch_size + 1
                loop_end = loop_start + batch_size - 1
                train_batch = []
                train_label = []
                for k = loop_start:loop_end
                    #println("k="*string(k))
                    record_no = pos[k].record_no
                    current_ply = pos[k].ply + 1
                    current_move = records[record_no].moves[current_ply]
                    bt = BoardTree(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                    Board.Init(bt)
                    color = Color.black
                    limit = current_ply - 1
                    for l = 1:limit
                        #println("ply="*string(l))
                        move = records[record_no].moves[l]
                        MakeMove.Do(bt, move, color, l, ht, tbl)
                        color = Flip_Color[color]
                    end
                    f = Feature1.MakeInputFeature(bt, color, tbl)
                    f = stack(f)
                    lbl = zeros(Float32, Square_NB)
                    lbl[current_move] = 1.0
                    push!(train_batch, f)
                    push!(train_label, lbl)
                end
                #println(size(train_batch))
                train_batch = stack(train_batch)
                train_batch = reshape(train_batch, (19, 19, input_dim, batch_size))
                train_label = stack(train_label)
                train_label = reshape(train_label, (19, 19, 1, batch_size))
                x = gpu(train_batch)
                t = gpu(train_label)
                #println(iteration_count)
                #y = model(x)
                #y = y|>cpu
                #loss_func(a,b) = Flux.logitcrossentropy(a, b)
                #model = model|> cpu
                #t = t|>cpu
                #grads = Flux.gradient((model) -> loss_func(y, t), model)
                #loss = loss_func(y, t)
                loss_func(a,b) = Flux.logitcrossentropy(a, b)                    
                loss, grads = Flux.withgradient(model) do m
                    y = m(x)
                    loss_func(y, t)
                end
                Flux.update!(opt_state, model, grads[1])
                model = model|>gpu
                iteration_count += 1
                console_out_counter += 1
                total_loss += loss
                if console_out_counter == console_out_threshold
                    console_out_counter = 0
                    avg_loss = total_loss / iteration_count
                    println("progress= [ "*string(j)*" / "*string(iteration_max)*" ]")
                    println("train_loss="*string(loss)*", avg_loss="*string(avg_loss))
                end
            end
            t = now()
            s = "epoch" * string(i) * " end! " * string(t)
            println(s)
        end
        try
            model = model|>cpu
            model_state = Flux.state(model)
            jldsave(file_name; model_state)
            #opt_state = opt_state|>cpu
            #jldsave(file_name; model_state, opt_state)
        catch e
            #println(e)
            println("raise error")
        end
        println("learning end!")        
        println("Train Policy End!")
    end
    function TestPolicy(ht, tbl)
        file_name = "model.jld2"
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
        model_state = JLD2.load(file_name, "model_state")
        Flux.loadmodel!(model, model_state)
        record_file_name = "test_records.txt"
        records, pos_num = IO.ReadRecords(record_file_name)
        limit = length(records)
        batch_size = 32
        total_acc_cnt = 0
        total_move_cnt = 0
        Flux.testmode!(model)
        limit = 40#後で直す
        for i = 1:limit
            current_record = records[i]
            Board.Init(bt)
            limit2 = length(current_record.moves)
            total_move_cnt += limit2
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
            for j = 1:limit2
                move = current_record.moves[j]
                f = Feature1.MakeInputFeature(bt, color, tbl)
                f = stack(f)
                #println(size(f))
                lbl = zeros(Float32, 361)
                lbl[move] = 1
                push!(test_batch, f)
                push!(test_label, lbl)
                push!(test_color, color)

                ll = length(test_color)
                #println("batch_size="*string(ll))

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

                if counter == batch_size || j == limit2
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
                        correct_move = current_record.moves[k]
                        correct_digit = y0[correct_move, index]
                        all_moves = moves_stack[k]
                        digits = []
                        for m in all_moves
                            if m == correct_move
                                continue
                            end
                            digit = y0[m, index]
                            push!(digits, digit)
                        end
                        dl = length(digits)
                        if dl == 0
                            acc_cnt += 1
                        elseif dl == 1
                            max_digit = digits[1]
                            if correct_digit >= max_digit
                                acc_cnt += 1
                            end
                        else
                            max_digit = maximum(digits, dims=1)
                            if correct_digit >= max_digit[1]
                                acc_cnt += 1
                            end
                        end
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
            acc_rate = acc_cnt / limit2
            total_acc_cnt += acc_cnt
            println("[record "*string(i)*"]")
            println(string(acc_cnt)*" / "*string(limit2))
            println("accuracy="*string(acc_rate))
        end
        total_acc_rate = total_acc_cnt / total_move_cnt
        println("")
        println(string(total_acc_cnt)*" / "*string(total_move_cnt))
        println("total_accuracy="*string(total_acc_rate))
    end
    
    #ロジスティック回帰による学習
    #評価関数用パラメータ
    #棋譜からの学習
    function TrainValue(record_no, epoch_num, batch_size, is_load_model, ht, tbl)
        console_out_threshold = 25
        file_name = "model_value.jld2"
        ch = 192
        input_dim = 44
        output_dim = 1
        fcl = 256
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
            Conv((1,1), ch=>output_dim, pad=0, bias=true),
            BatchNorm(output_dim),
            relu,
            Flux.flatten,
            Flux.Dense((output_dim*Square_NB)=>fcl),
            relu,
            Flux.Dense((fcl=>1))
            )|>gpu

        #model = Chain(Dense(input_dim => output_dim, sigmoid))|>gpu#この構成だとパラメータ数が少なすぎる
        wd = Flux.Optimise.WeightDecay(0.005)
        opt = Flux.Optimiser(wd, Nesterov(0.0017, 0.9))
        opt_state = Flux.setup(opt, model)|>gpu
        if is_load_model == true
            model_state = JLD2.load(file_name, "model_state")
            opt_state = JLD2.load(file_name, "opt_state")
            Flux.loadmodel!(model, model_state)
            opt_state = Flux.setup(opt, model)|>gpu
        end
        record_file_name = "records" * string(record_no) * ".txt"
        records, pos_num = IO.ReadRecords(record_file_name)
        pos = Position.NumberPosition(records, pos_num)
        iteration_max = pos_num ÷ batch_size
        println("iteration_num = " * string(iteration_max))
                #※後で直す
        iteration_max = 6000
        total_loss = 0
        iteration_count = 0
        avg_loss = 0.0
        for i = 1:epoch_num
            t = now()
            s = "epoch" * string(i) * " start! " * string(t)
            println(s)
            pos = shuffle(pos)
            console_out_counter = 0
            for j = 1:iteration_max
                #println(iteration_count)
                loop_start = (j - 1) * batch_size + 1
                loop_end = loop_start + batch_size - 1
                train_batch = []
                train_label = []
                for k = loop_start:loop_end
                    #println("k="*string(k))
                    record_no = pos[k].record_no
                    current_ply = pos[k].ply + 1
                    current_move = records[record_no].moves[current_ply]
                    bt = BoardTree(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                    Board.Init(bt)
                    color = Color.black
                    limit = current_ply - 1
                    for l = 1:limit
                        #println("ply="*string(l))
                        move = records[record_no].moves[l]
                        MakeMove.Do(bt, move, color, l, ht, tbl)
                        color = Flip_Color[color]
                    end
                    f = Feature1.MakeInputFeature(bt, color, tbl)
                    f = stack(f)
                    if color == Color.black
                        if records[record_no].winner == Color.black
                            lbl = 1.0
                        elseif records[record_no].winner == Color.white
                            lbl = 0.0
                        else
                            lbl = 0.5
                        end
                    else
                        if records[record_no].winner == Color.black
                            lbl = 0.0
                        elseif records[record_no].winner == Color.white
                            lbl = 1.0
                        else
                            lbl = 0.5
                        end
                    end
                    push!(train_batch, f)
                    push!(train_label, lbl)
                end
                #println(size(train_batch))
                train_batch = stack(train_batch)
                train_batch = reshape(train_batch, (19, 19, input_dim, batch_size))
                train_label = stack(train_label)
                train_label = reshape(train_label, (1, batch_size))
                x = gpu(train_batch)
                t = gpu(train_label)
                #println(iteration_count)
                #y = model(x)
                #y = y|>cpu
                #loss_func(a,b) = Flux.logitbinarycrossentropy(a, b)
                #model = model|> cpu
                #t = t|>cpu
                #grads = Flux.gradient((model) -> loss_func(y, t), model)
                #println(iteration_count)
                #loss = loss_func(y, t)
                loss_func(a,b) = Flux.logitbinarycrossentropy(a, b)                    
                loss, grads = Flux.withgradient(model) do m
                    y = m(x)
                    loss_func(y, t)
                end
                Flux.update!(opt_state, model, grads[1])
                model = model|>gpu
                iteration_count += 1
                console_out_counter += 1
                total_loss += loss
                if console_out_counter == console_out_threshold
                    console_out_counter = 0
                    avg_loss = total_loss / iteration_count
                    println("progress= [ "*string(j)*" / "*string(iteration_max)*" ]")
                    println("train_loss="*string(loss)*", avg_loss="*string(avg_loss))
                end
            end
            t = now()
            s = "epoch" * string(i) * " end! " * string(t)
            println(s)
        end
        try
            model = model|>cpu
            model_state = Flux.state(model)
            opt_state = opt_state|>cpu
            jldsave(file_name; model_state, opt_state)
            io = open("avg_loss_value_network.txt", "a")
            s = string(avg_loss)*"\n"
            write(io, s)
            close(io)
        catch e
            #println(e)
            println("raise error")
        end
        println("learning end!")        
        println("Train Value End!")
    end
end
export Learn1