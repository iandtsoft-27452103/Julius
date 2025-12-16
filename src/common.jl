Color_NB = 2
Square_NB = 361
File_NB = 19
Rank_NB = 19
Ply_Max = 512
Seq_Max = 256
BB_Cnt = 4
#Move_Cur_Limit = 256
#Bit_Diff = 128 - Square_NB
Bit_Diff = [33, 33, 33, 52]
Value_Max = Int32(32768)
Value_Min = -Value_Max
Value_Draw = Int32(0)
Value_Empty = 0
Flip_Color = [2, 1]
FileStr2Num = Dict([("a", 1), ("b", 2), ("c", 3), ("d", 4), ("e", 5), ("f", 6), ("g", 7), ("h", 8), ("i", 9), ("j", 10), ("k", 11), ("l", 12), ("m", 13), ("n", 14), ("o", 15), ("p", 16), ("q", 17), ("r", 18), ("s", 19)])
RankStr2Num = Dict([("a", 1), ("b", 20), ("c", 39), ("d", 58), ("e", 77), ("f", 96), ("g", 115), ("h", 134), ("i", 153), ("j", 172), ("k", 191), ("l", 210), ("m", 229), ("n", 248), ("o", 267), ("p", 286), ("q", 305), ("r", 324), ("s", 343)])
Square_Edge = [true, true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true,
               true, true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true,  true]
Index_BB = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
            2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
            2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
            2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
            2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
            3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
            3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
            3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
            3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
            3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
            4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
            4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
            4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
            4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
Shift_Num = [94, 93, 92, 91, 90, 89, 88, 87, 86, 85, 84, 83, 82, 81, 80, 79, 78, 77, 76,
             75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60, 59, 58, 57,
             56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38,
             37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19,
             18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
             94, 93, 92, 91, 90, 89, 88, 87, 86, 85, 84, 83, 82, 81, 80, 79, 78, 77, 76,
             75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60, 59, 58, 57,
             56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38,
             37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19,
             18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
             94, 93, 92, 91, 90, 89, 88, 87, 86, 85, 84, 83, 82, 81, 80, 79, 78, 77, 76,
             75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60, 59, 58, 57,
             56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38,
             37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19,
             18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
             75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60, 59, 58, 57,
             56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38,
             37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19,
             18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
Str_Square = ["aa", "ba", "ca", "da", "ea", "fa", "ga", "ha", "ia", "ja", "ka", "la", "ma", "na", "oa", "pa", "qa", "ra", "sa", 
              "ab", "bb", "cb", "db", "eb", "fb", "gb", "hb", "ib", "jb", "kb", "lb", "mb", "nb", "ob", "pb", "qb", "rb", "sb", 
              "ac", "bc", "cc", "dc", "ec", "fc", "gc", "hc", "ic", "jc", "kc", "lc", "mc", "nc", "oc", "pc", "qc", "rc", "sc", 
              "ad", "bd", "cd", "dd", "ed", "fd", "gd", "hd", "id", "jd", "kd", "ld", "md", "nd", "od", "pd", "qd", "rd", "sd", 
              "ae", "be", "ce", "de", "ee", "fe", "ge", "he", "ie", "je", "ke", "le", "me", "ne", "oe", "pe", "qe", "re", "se", 
              "af", "bf", "cf", "df", "ef", "ff", "gf", "hf", "if", "jf", "kf", "lf", "mf", "nf", "of", "pf", "qf", "rf", "sf", 
              "ag", "bg", "cg", "dg", "eg", "fg", "gg", "hg", "ig", "jg", "kg", "lg", "mg", "ng", "og", "pg", "qg", "rg", "sg", 
              "ah", "bh", "ch", "dh", "eh", "fh", "gh", "hh", "ih", "jh", "kh", "lh", "mh", "nh", "oh", "ph", "qh", "rh", "sh", 
              "ai", "bi", "ci", "di", "ei", "fi", "gi", "hi", "ii", "ji", "ki", "li", "mi", "ni", "oi", "pi", "qi", "ri", "si", 
              "aj", "bj", "cj", "dj", "ej", "fj", "gj", "hj", "ij", "jj", "kj", "lj", "mj", "nj", "oj", "pj", "qj", "rj", "sj", 
              "ak", "bk", "ck", "dk", "ek", "fk", "gk", "hk", "ik", "jk", "kk", "lk", "mk", "nk", "ok", "pk", "qk", "rk", "sk", 
              "al", "bl", "cl", "dl", "el", "fl", "gl", "hl", "il", "jl", "kl", "ll", "ml", "nl", "ol", "pl", "ql", "rl", "sl", 
              "am", "bm", "cm", "dm", "em", "fm", "gm", "hm", "im", "jm", "km", "lm", "mm", "nm", "om", "pm", "qm", "rm", "sm", 
              "an", "bn", "cn", "dn", "en", "fn", "gn", "hn", "in", "jn", "kn", "ln", "mn", "nn", "on", "pn", "qn", "rn", "sn", 
              "ao", "bo", "co", "do", "eo", "fo", "go", "ho", "io", "jo", "ko", "lo", "mo", "no", "oo", "po", "qo", "ro", "so", 
              "ap", "bp", "cp", "dp", "ep", "fp", "gp", "hp", "ip", "jp", "kp", "lp", "mp", "np", "op", "pp", "qp", "rp", "sp", 
              "aq", "bq", "cq", "dq", "eq", "fq", "gq", "hq", "iq", "jq", "kq", "lq", "mq", "nq", "oq", "pq", "qq", "rq", "sq", 
              "ar", "br", "cr", "dr", "er", "fr", "gr", "hr", "ir", "jr", "kr", "lr", "mr", "nr", "or", "pr", "qr", "rr", "sr", 
              "as", "bs", "cs", "ds", "es", "fs", "gs", "hs", "is", "js", "ks", "ls", "ms", "ns", "os", "ps", "qs", "rs", "ss" ]
Str_Square2 = ["1-1", "2-1", "3-1", "4-1", "5-1", "6-1", "7-1", "8-1", "9-1", "10-1", "11-1", "12-1", "13-1", "14-1", "15-1", "16-1", "17-1", "18-1", "19-1", 
               "1-2", "2-2", "3-2", "4-2", "5-2", "6-2", "7-2", "8-2", "9-2", "10-2", "11-2", "12-2", "13-2", "14-2", "15-2", "16-2", "17-2", "18-2", "19-2", 
               "1-3", "2-3", "3-3", "4-3", "5-3", "6-3", "7-3", "8-3", "9-3", "10-3", "11-3", "12-3", "13-3", "14-3", "15-3", "16-3", "17-3", "18-3", "19-3", 
               "1-4", "2-4", "3-4", "4-4", "5-4", "6-4", "7-4", "8-4", "9-4", "10-4", "11-4", "12-4", "13-4", "14-4", "15-4", "16-4", "17-4", "18-4", "19-4", 
               "1-5", "2-5", "3-5", "4-5", "5-5", "6-5", "7-5", "8-5", "9-5", "10-5", "11-5", "12-5", "13-5", "14-5", "15-5", "16-5", "17-5", "18-5", "19-5", 
               "1-6", "2-6", "3-6", "4-6", "5-6", "6-6", "7-6", "8-6", "9-6", "10-6", "11-6", "12-6", "13-6", "14-6", "15-6", "16-6", "17-6", "18-6", "19-6", 
               "1-7", "2-7", "3-7", "4-7", "5-7", "6-7", "7-7", "8-7", "9-7", "10-7", "11-7", "12-7", "13-7", "14-7", "15-7", "16-7", "17-7", "18-7", "19-7", 
               "1-8", "2-8", "3-8", "4-8", "5-8", "6-8", "7-8", "8-8", "9-8", "10-8", "11-8", "12-8", "13-8", "14-8", "15-8", "16-8", "17-8", "18-8", "19-8", 
               "1-9", "2-9", "3-9", "4-9", "5-9", "6-9", "7-9", "8-9", "9-9", "10-9", "11-9", "12-9", "13-9", "14-9", "15-9", "16-9", "17-9", "18-9", "19-9", 
               "1-10", "2-10", "3-10", "4-10", "5-10", "6-10", "7-10", "8-10", "9-10", "10-10", "11-10", "12-10", "13-10", "14-10", "15-10", "16-10", "17-10", "18-10", "19-10", 
               "1-11", "2-11", "3-11", "4-11", "5-11", "6-11", "7-11", "8-11", "9-11", "10-11", "11-11", "12-11", "13-11", "14-11", "15-11", "16-11", "17-11", "18-11", "19-11", 
               "1-12", "2-12", "3-12", "4-12", "5-12", "6-12", "7-12", "8-12", "9-12", "10-12", "11-12", "12-12", "13-12", "14-12", "15-12", "16-12", "17-12", "18-12", "19-12", 
               "1-13", "2-13", "3-13", "4-13", "5-13", "6-13", "7-13", "8-13", "9-13", "10-13", "11-13", "12-13", "13-13", "14-13", "15-13", "16-13", "17-13", "18-13", "19-13", 
               "1-14", "2-14", "3-14", "4-14", "5-14", "6-14", "7-14", "8-14", "9-14", "10-14", "11-14", "12-14", "13-14", "14-14", "15-14", "16-14", "17-14", "18-14", "19-14", 
               "1-15", "2-15", "3-15", "4-15", "5-15", "6-15", "7-15", "8-15", "9-15", "10-15", "11-15", "12-15", "13-15", "14-15", "15-15", "16-15", "17-15", "18-15", "19-15", 
               "1-16", "2-16", "3-16", "4-16", "5-16", "6-16", "7-16", "8-16", "9-16", "10-16", "11-16", "12-16", "13-16", "14-16", "15-16", "16-16", "17-16", "18-16", "19-16", 
               "1-17", "2-17", "3-17", "4-17", "5-17", "6-17", "7-17", "8-17", "9-17", "10-17", "11-17", "12-17", "13-17", "14-17", "15-17", "16-17", "17-17", "18-17", "19-17", 
               "1-18", "2-18", "3-18", "4-18", "5-18", "6-18", "7-18", "8-18", "9-18", "10-18", "11-18", "12-18", "13-18", "14-18", "15-18", "16-18", "17-18", "18-18", "19-18", 
               "1-19", "2-19", "3-19", "4-19", "5-19", "6-19", "7-19", "8-19", "9-19", "10-19", "11-19", "12-19", "13-19", "14-19", "15-19", "16-19", "17-19", "18-19", "19-19" ]
Bit_Delta = [0, 95, 190, 285]
bb_full = 

#ビットボード
#128ビット変数4枚とし、上から5段・5段・5段・4段とする
mutable struct BitBoard
    bb
    function BitBoard()
        bb = zeros(UInt128, BB_Cnt)
    end
end

mutable struct posi
    posi_no
    record_no
    ply
end

mutable struct BoardTree
    board
    bb_stone
    bb_occupied
    bb_empty
    next_seq_num
    seq_number_table
    current_moves
    seq_bb
    dame_bb
    agehama
    hash_key
    hash_array
    saved_agehama
    connect_flag
    tori_flag
    saved_seq_num
    saved_seq_bb
    saved_dame_bb
    saved_base_seq_num
    saved_base_seq_bb
    saved_base_dame_bb
    saved_opp_seq_num
    saved_opp_seq_dame_bb
    saved_made_dame_bb
    removed_seq_num
    removed_seq_bb
    kou_sq
    kou_array
    current_hash
    prev_hash
    ply
    root_moves
    root_color
end
mutable struct Node
    color
    ParentIndex
    ThisIndex
    TrialCount
    PlayoutCount
    WinCount
    DrawCount
    LostCount
    EvalCount
    WinRateSum
    LostRateSum
    IsLeaf
    ChildIndexes
    move
    PolicyResult
end