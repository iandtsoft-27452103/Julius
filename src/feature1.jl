module Feature1
    include("common.jl")
    include("color.jl")
    const prev_move_limit = 40
    function MakeInputFeature(bt, color, tbl)
        features = []
        for c = 1:Color_NB
            ft = zeros(Float32, Square_NB)
            bb_stone = bt.bb_stone[c]
            for i = 1:BB_Cnt
                bb = bb_stone[i]
                while bb > 0
                    pos = findfirst('1', bitstring(bb)) - Bit_Diff[i]
                    sq = pos + Bit_Delta[i]
                    bb = xor(bb, tbl.bb_mask[sq][Index_BB[sq]])
                    ft[sq] = 1.0
                end
            end
            push!(features, ft)
        end
        ft = zeros(Float32, Square_NB)
        bb_empty = bt.bb_empty
        for i = 1:BB_Cnt
            bb = bb_empty[i]
            while bb > 0
                pos = findfirst('1', bitstring(bb)) - Bit_Diff[i]
                sq = pos + Bit_Delta[i]
                bb = xor(bb, tbl.bb_mask[sq][Index_BB[sq]])
                ft[sq] = 1.0
            end
        end
        push!(features, ft)
        limit = length(bt.current_moves)
        if limit < prev_move_limit
            limit2 = prev_move_limit - limit
        else
            limit = prev_move_limit
            limit2 = 0
        end
        i = limit
        while i > 0
            #println(i)
            ft = zeros(Float32, Square_NB)
            sq = bt.current_moves[i]
            ft[sq] = 1.0
            push!(features, ft)
            i -= 1
        end
        i = limit2
        while i > 0
            ft = zeros(Float32, Square_NB)
            push!(features, ft)
            i -= 1
        end
        if color == Color.black
            ft = ones(Float32, Square_NB)
        else
            ft = zeros(Float32, Square_NB)
        end
        push!(features, ft)
        return features
    end
end
export Feature1