module Debug
    include("common.jl")
    include("color.jl")
    function OutBoardArray(bt)
        io = open("debug_log.txt", "w")
        sq_counter = 0
        rank_counter = 1
        str_out = ""
        write(io, "   1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19\n")
        for i = 1:Square_NB
            if sq_counter == 0
                str_out *= string(rank_counter)
                if rank_counter < 10
                    str_out *= " "
                end
                str_out *= " "
            end
            if bt.board[i] == Color.black
                str_out *= "● "
            elseif bt.board[i] == Color.white
                str_out *= "○ "
            elseif bt.board[i] == Value_Empty
                str_out *= "・ "
            end
            #str_out *= " "
            sq_counter += 1
            if sq_counter == File_NB
                sq_counter = 0
                rank_counter += 1
                str_out *= "\n"
                write(io, str_out)
                str_out = ""
            end
        end
        str_out = "黒のアゲハマ：" * string(bt.agehama[1]) * "\n"
        write(io, str_out)
        str_out = "白のアゲハマ：" * string(bt.agehama[2]) * "\n"
        write(io, str_out)
        close(io)
    end
    function OutBoardBB(bt, tbl)
        io = open("debug_log2.txt", "w")
        sq_counter = 0
        rank_counter = 1
        str_out = ""
        write(io, "   1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19\n")
        black_pos_list = []
        white_pos_list = []
        bb = bt.bb_stone[1]
        for i = 1:BB_Cnt
            bb_temp = bb[i]
            while bb_temp > 0
                pos = findfirst('1', bitstring(bb_temp)) - Bit_Diff[i]
                pos = pos + Bit_Delta[i]
                bb_temp = xor(bb_temp, tbl.bb_mask[pos][Index_BB[pos]])
                push!(black_pos_list, pos)
            end
        end
        bb = bt.bb_stone[2]
        for i = 1:BB_Cnt
            bb_temp = bb[i]
            while bb_temp > 0
                pos = findfirst('1', bitstring(bb_temp)) - Bit_Diff[i]
                pos = pos + Bit_Delta[i]
                bb_temp = xor(bb_temp, tbl.bb_mask[pos][Index_BB[pos]])
                push!(white_pos_list, pos)
            end
        end
        for i = 1:Square_NB
            if sq_counter == 0
                str_out *= string(rank_counter)
                if rank_counter < 10
                    str_out *= " "
                end
                str_out *= " "
            end
            if i ∈ black_pos_list
                str_out *= "● "
            elseif i ∈ white_pos_list
                str_out *= "○ "
            else
                str_out *= "・ "
            end
            #str_out *= " "
            sq_counter += 1
            if sq_counter == File_NB
                sq_counter = 0
                rank_counter += 1
                str_out *= "\n"
                write(io, str_out)
                str_out = ""
            end
        end
        str_out = "黒のアゲハマ：" * string(bt.agehama[1]) * "\n"
        write(io, str_out)
        str_out = "白のアゲハマ：" * string(bt.agehama[2]) * "\n"
        write(io, str_out)
        close(io)
    end
    function VeryfyBoard(bt0, bt1)
        for i = 1:Square_NB
            if bt0.board[i] != bt1.board[i]
                println("error raise in i="*string(i)*", board")
                return
            end
        end
        for i = 1:Color_NB
            if bt0.bb_stone[i] != bt1.bb_stone[i]
                if i == Color.black
                    println("error raise in bb_stone color=black")
                    return
                else
                    println("error raise in bb_stone color=white")
                    return
                end
            end
        end
        if bt0.bb_occupied != bt1.bb_occupied
            println("error raise in bb_occupied")
            return
        end
    end
end
export Debug