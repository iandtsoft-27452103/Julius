module Table
    include("common.jl")
    PosCrossTable = Array{Dict{Int64, Int64}}(undef, Square_NB)
    #bb_mask = Array{BitBoard}(undef, Square_NB)
    bb_mask = []
    function InitPosCrossTable()
        WallNorth = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
        WallWest = [20, 39, 58, 77, 96, 115, 134, 153, 172, 191, 210, 229, 248, 267, 286, 305, 324]
        WallEast = [38, 57, 76, 95, 114, 133, 152, 171, 190, 209, 228, 247, 266, 285, 304, 323]
        WallSouth = [344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360]
        for i = 1:Square_NB
            ar = Dict{Int64, Int64}()
            if i == 1
                ar[1] = 2
                ar[2] = 20
            elseif i == 19
                ar[1] = 18
                ar[2] = 38
            elseif i == 343
                ar[1] = 324
                ar[2] = 344
            elseif i == 361
                ar[1] = 342
                ar[2] = 360
            elseif i ∈ WallNorth
                ar[1] = i - 1
                ar[2] = i + 1
                ar[3] = i + 19
            elseif i ∈ WallWest
                ar[1] = i - 19
                ar[2] = i + 1
                ar[3] = i + 19
            elseif i ∈ WallEast
                ar[1] = i - 19
                ar[2] = i - 1
                ar[3] = i + 19
            elseif i ∈ WallSouth
                ar[1] = i - 19
                ar[2] = i - 1
                ar[3] = i + 1
            else
                ar[1] = i - 19
                ar[2] = i - 1
                ar[3] = i + 1
                ar[4] = i + 19
            end
            PosCrossTable[i] = ar
        end
    end
    function InitBBMask()
        for i = 1:Square_NB
            index = Index_BB[i]
            #bb_mask[i] = BitBoard()
            bb = BitBoard()
            bb[index] = UInt128(1) << UInt128(Shift_Num[i])
            push!(bb_mask, bb)
            #println(bb_mask[i])
        end
    end
end
export Table