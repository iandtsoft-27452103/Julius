module Position
    include("record.jl")
    include("common.jl")
    function NumberPosition(records, num)
        positions = Array{posi}(undef, num)
        limit = length(records)
        println("position_num = "*string(length(positions)))
        index = 1
        for i = 1:limit
            #println(positions[index])
            ply = 0
            while true
                positions[index] = posi(0, 0, 0)
                p = positions[index]
                p.posi_no = index
                p.record_no = i
                p.ply = ply
                index += 1
                ply += 1
                #println(ply)
                #println(index)
                #println(p.record_no)
                if ply == records[i].ply
                    #return positions
                    break
                end
            end
        end
        return positions
    end
end
export Position