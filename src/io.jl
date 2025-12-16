module IO
    include("record.jl")
    include("board.jl")
    include("color.jl")
    include("common.jl")
    function ReadRecords(file_name)
        io = open(file_name, "r")
        s = readlines(io)
        limit = length(s)
        records = Array{Record}(undef, limit)
        pos_num = 0
        for i = 1:limit
            records[i] = Record(0, 0, 0, 0, 0)
            r = records[i]
            temp = split(s[i], ",")
            r.player = []
            for j = 1:Color_NB
                push!(r.player, "")
            end
            r.player[1] = temp[1]
            r.player[2] = temp[2]
            r.ply = length(temp) - 3
            str_result = temp[3]
            if str_result[1] == "B"
                r.winner = Color.black
            else
                r.winner = Color.white
            end
            pos_num += r.ply
            limit2 = length(temp)
            r.str_moves = []
            r.moves = []
            for j = 4:limit2
                s2 = temp[j]
                push!(r.str_moves, s2)
                sf= string(s2[1])
                sr = string(s2[2])
                k = FileStr2Num[sf]
                l = RankStr2Num[sr]
                #move = k + l
                move = k + l - 1
                push!(r.moves, move)
            end
        end
        close(io)
        return records, pos_num
    end
end
export IO