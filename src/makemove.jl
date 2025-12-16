module MakeMove
    include("common.jl")
    #※ToDoリスト
    #bb_stone, bb_occupiedを更新する処理が漏れていたので入れる。
    #DoとUnDoでさらなる最適化が可能。細かく精査してからテストに移る。
    function Do(bt, sq, color, ply, ht, tbl)
        #v1 = Dict{UInt16, UInt16}()
        v2 = Dict{UInt16, UInt16}()
        v3 = Dict{UInt16, UInt16}()
        v4 = Dict{UInt16, UInt16}()
        add_dame_count = 0
        count1 = 0
        kou_candidate = 0
        bt.board[sq] = color
        bt.bb_stone[color][Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
        bt.bb_occupied[Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
        push!(bt.current_moves, sq)#bt.saved_made_dame_square[ply, i]
        bt.bb_empty[Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
        bt.prev_hash = bt.current_hash
        push!(bt.hash_array, bt.hash_key)
        bt.hash_key ⊻= ht.StoneRand[color, sq]
        #bt.current_hash = bt.hash_key
        bt.saved_agehama[color, ply] = bt.agehama[color]
        bt.saved_agehama[Flip_Color[color], ply] = bt.agehama[Flip_Color[color]]
        bt.kou_sq = bt.kou_array[ply] = 0
        li = values(tbl.PosCrossTable[sq])
        connect_count = UInt16(0)
        connect_sq = Dict{UInt16, UInt16}()
        empty_sq = Dict{UInt16, UInt16}()
        for v in li
            if bt.board[v] == color
                connect_sq[connect_count] = v
                connect_count += 1
            elseif bt.board[v] == Value_Empty
                empty_sq[add_dame_count] = v
                add_dame_count += 1
            end
        end
        if connect_count == 0
            # 自分の石と連絡しない手の場合
            bt.connect_flag[ply] = false
            bt.seq_number_table[color, sq] = bt.next_seq_num[color]
            bt.seq_bb[color, bt.next_seq_num[color]][Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
            x = values(empty_sq)
            for v in x
                bt.dame_bb[color, bt.next_seq_num[color]][Index_BB[v]] ⊻= tbl.bb_mask[v][Index_BB[v]]
            end
            #println(bt.dame_bb[color, 1])
            bt.next_seq_num[color] += 1
            #v1[count1] = sq
            v2[count1] = bt.seq_number_table[color, sq]
        else
            # 自分の石と連絡している場合の手（ノビ, サガリ, ツギ他）
            bt.connect_flag[ply] = true
            x = values(connect_sq)
            for v in x
                #v1[count1] = v
                if bt.seq_number_table[color, v] ∉ values(v2)
                    v2[count1] = bt.seq_number_table[color, v]
                    count1 += 1
                end
                # ∉ 
            end
            BaseNumber = v2[0]
            bt.seq_number_table[color, sq] = BaseNumber
            bt.saved_base_seq_num[ply] = BaseNumber
            bt.saved_base_seq_bb[ply] = bt.seq_bb[color, BaseNumber]
            bt.saved_base_dame_bb[ply] = bt.dame_bb[color, BaseNumber]
            bt.seq_bb[color, BaseNumber][Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
            x = values(empty_sq)
            for v in x
                if bt.dame_bb[color, BaseNumber][Index_BB[v]] & tbl.bb_mask[v][Index_BB[v]] == 0
                    bt.dame_bb[color, BaseNumber][Index_BB[v]] ⊻= tbl.bb_mask[v][Index_BB[v]]
                end
            end
            if count1 > 1
                limit = count1
                index = 1
                #seq_numbers = []
                for i = 1:limit
                    if v2[i - 1] == BaseNumber
                        continue
                    end
                    #if v2[i - 1] ∈ seq_numbers
                        #continue
                    #end
                    #push!(seq_numbers, v2[i - 1])
                    #if BaseNumber == v2[i - 1]
                    #    index += 1
                    #    continue
                    #end
                    bt.saved_seq_num[ply, index] = v2[i - 1]
                    bt.saved_seq_bb[ply, index] = deepcopy(bt.seq_bb[color, v2[i - 1]])
                    bt.saved_dame_bb[ply, index] = deepcopy(bt.dame_bb[color, v2[i - 1]])
                    for j = 1:BB_Cnt
                        bt.seq_bb[color, BaseNumber][j] |= bt.seq_bb[color, v2[i - 1]][j]
                        bt.dame_bb[color, BaseNumber][j] |= bt.dame_bb[color, v2[i - 1]][j]
                    end
                    for j = 1:BB_Cnt
                        bb = bt.seq_bb[color, v2[i - 1]][j]
                        while bb > 0
                            pos = findfirst('1', bitstring(bb)) - Bit_Diff[j]
                            pos = pos + Bit_Delta[j]
                            bb = xor(bb, tbl.bb_mask[pos][Index_BB[pos]])
                            #pos = pos + Bit_Delta[j]
                            bt.seq_number_table[color, pos] = BaseNumber
                        end
                    end
                    bt.seq_bb[color, v2[i - 1]] = BitBoard()#初期化
                    bt.dame_bb[color, v2[i - 1]] = BitBoard()
                    index += 1
                end
            end
            bt.dame_bb[color, BaseNumber][Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
        end
        # 4つの連をツグ手の場合、相手の駄目を詰めないので終了
        if connect_count == 4
            bt.ply += 1
            bt.current_hash = bt.hash_key
            return
        end

        # 自分の石と連絡せず、相手の駄目も詰めない手の場合終了
        if add_dame_count == 4
            bt.ply += 1
            bt.current_hash = bt.hash_key
            return
        end

        len = length(values(tbl.PosCrossTable[sq]))
        if add_dame_count == len
            bt.ply += 1
            bt.current_hash = bt.hash_key
            return
        end

        count2 = UInt16(1)
        tori_cnt = UInt16(1)
        #l = UInt16(0)
        m = UInt16(0)
        n = UInt16(0)#x
        #limit = length(li)
        for v in li
            if bt.board[v] == Flip_Color[color]
                v3[n] = bt.seq_number_table[Flip_Color[color], v]
                v4[n] = v
                n += 1
            end
        end
        k3 = keys(v3)
        vs = []
        for k in k3
            a = v3[k]
            if a ∈ vs
                continue
            end
            b = v4[k]
            push!(vs, a)
            #k += 1
            #println("bb_mask="*string(tbl.bb_mask[sq][Index_BB[sq]]))
            if bt.dame_bb[Flip_Color[color], a][Index_BB[sq]] & tbl.bb_mask[sq][Index_BB[sq]] > 0
                bt.saved_opp_seq_num[ply, count2] = a
                bt.saved_opp_seq_dame_bb[ply, count2] = bt.dame_bb[Flip_Color[color], a]
                bt.dame_bb[Flip_Color[color], a][Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
                count2 += 1
                #println(bt.dame_bb[1, 19])
                bb_compare = bt.dame_bb[Flip_Color[color], a][1] | bt.dame_bb[Flip_Color[color], a][2] | bt.dame_bb[Flip_Color[color], a][3] | bt.dame_bb[Flip_Color[color], a][4]
                if bb_compare == 0
                    l = UInt16(0)
                    # トリの手の場合
                    for j = 1:BB_Cnt
                        bb = bt.seq_bb[Flip_Color[color], a][j]
                        l += count('1', bitstring(bb))
                    end
                    bt.agehama[color] += l
                    bt.tori_flag[ply] = true
                    #bt.saved_agehama[color, ply] = bt.agehama[color]

                    # 取った相手の石の連・碁盤・空白の情報を更新する
                    for j = 1:BB_Cnt
                        bb = bt.seq_bb[Flip_Color[color], a][j]
                        #for o = 1:BB_Cnt
                        bt.bb_empty[j] ⊻= bb
                        bt.bb_stone[Flip_Color[color]][j] ⊻= bb
                        bt.bb_occupied[j] ⊻= bb
                        #end
                        while bb > 0
                            pos = findfirst('1', bitstring(bb)) - Bit_Diff[j]
                            pos = pos + Bit_Delta[j]
                            bb = xor(bb, tbl.bb_mask[pos][Index_BB[pos]])
                            #pos = pos + Bit_Delta[j]
                            bt.seq_number_table[Flip_Color[color], pos] = Int16(0)
                            #bt.bb_empty[Index_BB[pos]] ⊻= tbl.bb_mask[pos][Index_BB[pos]]
                            bt.board[pos] = Value_Empty
                            bt.hash_key ⊻= ht.StoneRand[Flip_Color[color], pos]
                        end
                    end
                    #for j = 1:BB_Cnt
                        #bt.saved_made_dame_bb[ply, i][j] |= bt.seq_bb[Flip_Color[color], v3[i]][j]
                    #end
                    bt.saved_made_dame_bb[ply, m + 1] = deepcopy(bt.seq_bb[Flip_Color[color], a])

                    # 自分の駄目を作る => ※怪しいので要検証！
                    for j = 1:BB_Cnt
                        bb = bt.saved_made_dame_bb[ply, m + 1][j]
                        while bb > 0
                            pos = findfirst('1', bitstring(bb)) - Bit_Diff[j]
                            pos = pos + Bit_Delta[j]
                            bb = xor(bb, tbl.bb_mask[pos][Index_BB[pos]])
                            #pos = pos + Bit_Delta[j]
                            li = values(tbl.PosCrossTable[pos])
                            li2 = []
                            for v in li
                                if bt.seq_number_table[color, v] ∈ li2
                                    continue
                                end
                                push!(li2, bt.seq_number_table[color, v])
                                if bt.board[v] == color
                                    if bt.dame_bb[color, bt.seq_number_table[color, v]][j] & tbl.bb_mask[v][Index_BB[v]] == 0
                                        bt.dame_bb[color, bt.seq_number_table[color, v]][j] ⊻= tbl.bb_mask[pos][Index_BB[pos]]
                                    end
                                end
                            end
                        end
                    end

                    # 所属する連番号を初期化する => ※怪しいので要検証！
                    #for v in v3
                        #bt.seq_number_table[Flip_Color[color], v] = Int16(0)
                    #end
                    #bt.seq_number_table[Flip_Color[color], a] = Int16(0)

                    # 取った連番号と位置を保存する
                    bt.removed_seq_num[ply, tori_cnt] = a
                    #for j = 1:BB_Cnt
                    #    bt.removed_seq_bb[ply, m][j] = bt.seq_bb[Flip_Color[color], v3[i]][j]
                    #end
                    bt.removed_seq_bb[ply, m + 1] = deepcopy(bt.seq_bb[Flip_Color[color], a])
                    bt.seq_bb[Flip_Color[color], a] = zeros(UInt128, BB_Cnt)
                    bt.dame_bb[Flip_Color[color], a] = zeros(UInt128, BB_Cnt)
                    tori_cnt += 1
                    m += 1
                end
            end
        end
        if add_dame_count == 0 && connect_count == 0 && bt.tori_flag[ply] == true && m == 1
            for i = 1:n
                cnt = 0
                index = 0
                for j = 1:BB_Cnt
                    cnt += count('1', bitstring(bt.saved_made_dame_bb[ply, i][j]))
                    if cnt > 0
                        index = j
                        break
                    end
                end
                if cnt == 1
                    #bt.kou_sq = bt.kou_array[ply] = bt.saved_made_dame_bb[ply, i][index]
                    #pos = bt.saved_made_dame_bb[ply, i][index]
                    #println(bt.removed_seq_bb[ply, i])
                    #println(index)
                    pos = findfirst('1', bitstring(bt.removed_seq_bb[ply, i][index])) - Bit_Diff[index]
                    pos = pos + Bit_Delta[index]
                    bt.kou_sq = pos
                    bt.kou_array[ply] = pos
                    #bt.saved_made_dame_square
                    break
                end
            end
        end
        bt.ply += 1
        bt.current_hash = bt.hash_key
    end
    #htは不要？
    function UnDo(bt, sq, color, ply, ht, tbl)
        bt.board[sq] = Value_Empty
        bt.bb_stone[color][Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
        bt.bb_occupied[Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
        l = length(bt.current_moves)
        deleteat!(bt.current_moves, l)#バグがあるかもしれないので要確認
        bt.bb_empty[Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]
        bt.current_hash = bt.hash_key = bt.prev_hash
        l = length(bt.hash_array)
        if l == 1
            bt.prev_hash = 0
        else
            bt.prev_hash = bt.hash_array[l - 1]
        end
        #deleteat!(bt.hash_array, ply)#バグがあるかもしれないので要確認
        l = length(bt.hash_array)
        deleteat!(bt.hash_array, l)
        bt.agehama[color] = bt.saved_agehama[color, ply]#バグがあるかもしれないので要確認 ply - 1
        bt.agehama[Flip_Color[color]] = bt.saved_agehama[Flip_Color[color], ply]#バグがあるかもしれないので要確認 ply - 1
        if ply == 1
            bt.kou_sq = 0
        else
            bt.kou_sq = bt.kou_array[ply - 1]#型はbotad.jlの初期化処理のものに合わせてある
        end
        bt.kou_array[ply] = UInt16(0)
        bt.ply -= 1
        if bt.connect_flag[ply] == false
            # 自分の石と連絡していない手
            bt.seq_number_table[color, sq] = Int16(0)
            bt.seq_bb[color, bt.next_seq_num[color] - 1] = BitBoard()
            bt.dame_bb[color, bt.next_seq_num[color] - 1] = BitBoard()
            bt.next_seq_num[color] -= 1
        else
            # 自分の石と連絡している場合の手（ノビ, サガリ, ツギ他）
            # 基になる連番号の情報を戻す
            bt.seq_bb[color, bt.saved_base_seq_num[ply]] = deepcopy(bt.saved_base_seq_bb[ply])
            bt.dame_bb[color, bt.saved_base_seq_num[ply]] = deepcopy(bt.saved_base_dame_bb[ply])
            bt.dame_bb[color, bt.saved_base_seq_num[ply]][Index_BB[sq]] ⊻= tbl.bb_mask[sq][Index_BB[sq]]#これは不要かもしれないのでデバッグ時に精査する
            bt.connect_flag[ply] = false
            bt.saved_base_seq_num[ply] = UInt16(0)
            bt.saved_base_seq_bb[ply] = BitBoard()
            bt.saved_base_dame_bb[ply] = BitBoard()
            for i = 1:3
                if bt.saved_seq_num[ply, i] == UInt16(0)
                    break
                end
                bt.seq_bb[color, bt.saved_seq_num[ply, i]] = deepcopy(bt.saved_seq_bb[ply, i])
                for j = 1:BB_Cnt
                    bb = bt.seq_bb[color, bt.saved_seq_num[ply, i]][j]
                    while bb > 0
                        pos = findfirst('1', bitstring(bb)) - Bit_Diff[j]
                        pos = pos + Bit_Delta[j]
                        bb = xor(bb, tbl.bb_mask[pos][Index_BB[pos]])
                        #pos = pos + Bit_Delta[j]
                        bt.seq_number_table[color, pos] = bt.saved_seq_num[ply, i]
                    end
                end
                bt.dame_bb[color, bt.saved_seq_num[ply, i]] = deepcopy(bt.saved_dame_bb[ply, i])
                bt.saved_seq_num[ply, i] = UInt16(0)
                bt.saved_seq_bb[ply, i] = BitBoard()
                bt.saved_dame_bb[ply, i] = BitBoard()
            end
        end
        for i = 1:4
            if bt.saved_opp_seq_num[ply, i] == UInt16(0)
                break
            end
            bt.dame_bb[Flip_Color[color], bt.saved_opp_seq_num[ply, i]] = deepcopy(bt.saved_opp_seq_dame_bb[ply, i])
            bt.saved_opp_seq_num[ply, i] = UInt16(0)
            bt.saved_opp_seq_dame_bb[ply, i] = BitBoard()
        end
        if bt.tori_flag[ply] == true
            for i = 1:4
                if bt.removed_seq_num[ply, i] == UInt16(0)
                    break
                end
                #println(bt.removed_seq_num[ply, i])
                bt.seq_bb[Flip_Color[color], bt.removed_seq_num[ply, i]] = deepcopy(bt.removed_seq_bb[ply, i])
                for j = 1:4
                    bb = bt.removed_seq_bb[ply, i][j]
                    bt.bb_empty[j] ⊻= bb
                    bt.bb_stone[Flip_Color[color]][j] ⊻= bb#[k]
                    bt.bb_occupied[j] ⊻= bb
                    #for k=1:BB_Cnt
                    #    bt.bb_empty[k] ⊻= bb
                    #    bt.bb_stone[Flip_Color[color]][k] ⊻= bb#[k]
                    #    bt.bb_occupied[k] ⊻= bb
                    #end
                    while bb > 0
                        pos = findfirst('1', bitstring(bb)) - Bit_Diff[j]
                        pos = pos + Bit_Delta[j]
                        bb = xor(bb, tbl.bb_mask[pos][Index_BB[pos]])
                        #pos = pos + Bit_Delta[j]
                        bt.seq_number_table[Flip_Color[color], pos] = bt.removed_seq_num[ply, i]
                        bt.board[pos] = Int16(Flip_Color[color])
                        #bt.bb_empty[Index_BB[sq]] ⊻= tbl.bb_mask[pos][Index_BB[pos]]
                    end
                end
                bt.removed_seq_num[ply, i] = UInt16(0)
                bt.removed_seq_bb[ply, i] = BitBoard()
            end
            for i = 1:4
                if (bt.saved_made_dame_bb[ply, i][1] | bt.saved_made_dame_bb[ply, i][2] | bt.saved_made_dame_bb[ply, i][3] | bt.saved_made_dame_bb[ply, i][4]) == 0
                    continue
                end
                for j = 1:BB_Cnt 
                    bb = bt.saved_made_dame_bb[ply, i][j]
                    while bb > 0
                        pos = findfirst('1', bitstring(bb)) - Bit_Diff[j]
                        pos = pos + Bit_Delta[j]
                        bb = xor(bb, tbl.bb_mask[pos][Index_BB[pos]])
                        #pos = pos + Bit_Delta[j]
                        pct = values(deepcopy(tbl.PosCrossTable[pos]))
                        for k in pct
                            if bt.board[k] == color
                                if bt.dame_bb[color, bt.seq_number_table[color, k]][Index_BB[k]] & tbl.bb_mask[k][Index_BB[k]] > 0
                                    bt.dame_bb[color, bt.seq_number_table[color, k]][Index_BB[k]] ⊻= tbl.bb_mask[k][Index_BB[k]]
                                end
                            end
                        end
                    end
                end
                bt.saved_made_dame_bb[ply, i] = BitBoard()
            end
        end
    end
end
export MakeMove