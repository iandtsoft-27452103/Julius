include("common.jl")
include("board.jl")
include("io.jl")
include("table.jl")
include("hash.jl")
include("debug.jl")
include("test.jl")
include("learn1.jl")
include("analyze.jl")

begin
    println("Hello World!")
    bt = BoardTree(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    Board.Init(bt)
    Table.InitPosCrossTable()
    Table.InitBBMask()
    Hash.IniRandomTable()
    Analyze.AnalyzePolicy(Hash, Table, "model.jld2", "20250323_nhk_hai.txt", "analyze_result_policy.txt", "2025年3月23日", "第72回NHK杯決勝")
    return
end