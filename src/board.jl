module Board
    include("common.jl")
    function Init(bt)
        bt.board = zeros(Int16, Square_NB)
        fill!(bt.board, Value_Empty)
        bt.bb_empty = BitBoard()
        bt.bb_empty[1] = bt.bb_empty[2] = bt.bb_empty[3] = (UInt128(1) << UInt128(95)) - 1
        bt.bb_empty[4] = (UInt128(1) << UInt128(76)) - 1
        bt.bb_stone = []
        push!(bt.bb_stone, BitBoard())
        push!(bt.bb_stone, BitBoard())
        bt.bb_occupied = BitBoard()
        bt.next_seq_num = zeros(Int16, Color_NB)
        fill!(bt.next_seq_num, 1)
        bt.seq_number_table = zeros(Int16, Color_NB, Square_NB)# C#版ではseq_max = 256で初期化しているが、Juliaでは配列が1がら始まるので0で初期化する
        #bt.current_moves = zeros(UInt16, Move_Cur_Limit)
        bt.current_moves = []
        bt.seq_bb = []
        bt.dame_bb = []
        for i = 1:Color_NB
            for j = 1:Seq_Max
                bb = BitBoard()
                push!(bt.seq_bb, bb)
                bb = BitBoard()
                push!(bt.dame_bb, bb)
            end
        end
        bt.seq_bb = reshape(bt.seq_bb, (Color_NB, Seq_Max))
        bt.dame_bb = reshape(bt.dame_bb, (Color_NB, Seq_Max))
        bt.agehama = zeros(UInt16, Color_NB)
        bt.hash_key = UInt128(0)
        bt.hash_array = []
        bt.saved_agehama = zeros(UInt16, Color_NB, Ply_Max)
        bt.connect_flag = Array{Bool}(undef, Ply_Max)
        fill!(bt.connect_flag, false)
        bt.saved_seq_num = zeros(UInt16, Ply_Max, 3)# C#版ではseq_max = 256で初期化しているが、Juliaでは配列が1がら始まるので0で初期化する
        bt.saved_seq_bb = []
        bt.saved_dame_bb = []
        bt.saved_base_seq_bb = []
        bt.saved_base_dame_bb = []
        bt.saved_opp_seq_dame_bb = []
        bt.saved_made_dame_bb = []
        bt.removed_seq_bb = []
        bt.tori_flag = []
        for i = 1:Ply_Max
            bb = BitBoard()
            push!(bt.saved_base_seq_bb, bb)
            bb = BitBoard()
            push!(bt.saved_base_dame_bb, bb)
            for j = 1:4
                if j < 4
                    bb = BitBoard()
                    push!(bt.saved_seq_bb, bb)
                    bb = BitBoard()
                    push!(bt.saved_dame_bb, bb)
                end
                bb = BitBoard()
                push!(bt.saved_opp_seq_dame_bb, bb)
                bb = BitBoard()
                push!(bt.saved_made_dame_bb, bb)
                bb = BitBoard()
                push!(bt.removed_seq_bb, bb)
            end
        end
        bt.saved_seq_bb = reshape(bt.saved_seq_bb, (Ply_Max, 3))
        bt.saved_dame_bb = reshape(bt.saved_dame_bb, (Ply_Max, 3))
        bt.saved_opp_seq_dame_bb = reshape(bt.saved_opp_seq_dame_bb, (Ply_Max, 4))
        bt.saved_made_dame_bb = reshape(bt.saved_made_dame_bb, (Ply_Max, 4))
        bt.removed_seq_bb = reshape(bt.removed_seq_bb, (Ply_Max, 4))
        bt.saved_base_seq_num = zeros(UInt16, Ply_Max)
        bt.saved_opp_seq_num = zeros(UInt16, Ply_Max, 4)
        bt.removed_seq_num = zeros(UInt16, Ply_Max, 4)
        bt.kou_sq = 0#C#版ではSquare_NB = 361で初期化しているが、Juliaでは配列が1がら始まるので0で初期化する
        bt.kou_array = zeros(UInt16, Ply_Max)
        bt.current_hash = 0
        bt.prev_hash = 0
        bt.tori_flag = fill(false, Ply_Max)
        bt.ply = 1#C#版ではS0で初期化しているが、Juliaでは配列が1がら始まるので1で初期化する
    end
end
export Board