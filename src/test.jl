module TestModule
    include("common.jl")
    include("board.jl")
    include("color.jl")
    include("io.jl")
    include("makemove.jl")
    include("debug.jl")
    # index = 3, 瀬戸大樹 - 林漢傑
    # index = 15, 小池芳弘 - 鶴山淳志
    # index = 22, 孫喆 - 黄翊祖
    # index = 27, 依田紀基 - 羽根直樹
    # index = 40, 山下敬吾 - 高尾紳路
    # index = 44, 許家元 - 高尾紳路
    # index = 46, 伊田篤史 - 井山裕太
    function TestDoUnDo(bt, ht, tbl, v)
        records, pos_num = IO.ReadRecords("test_records2.txt")
        limit = length(records)
        #println(limit)
        current_record = records[15]
        Board.Init(bt)
        limit2 = length(current_record.moves)
        color = Color.black
        for j = 1:limit2
            current_move = current_record.moves[j]
            if j == v
                x = 0
                println(bt.seq_number_table[1, 42])
            end
            MakeMove.Do(bt, current_move, color, j, ht, tbl)
            if j == v
                #println(current_move)
                MakeMove.UnDo(bt, current_move, color, j, ht, tbl)
                Debug.OutBoardArray(bt)
                Debug.OutBoardBB(bt, tbl)
                println(bt.next_seq_num[1])
                println(bt.next_seq_num[2])
                #println(bt.bb_empty)
                return
            end
            #MakeMove.UnDo(bt, current_move, color, ply, ht, tbl)
            color = Flip_Color[color]
        end
    end
end
export TestModule