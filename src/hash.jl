module Hash
    include("common.jl")
    include("color.jl")
    #ハッシュ用クラス
    #Bonanzaのrand.cとhash.cを移植
    #PRNG based on Mersenne Twister ( M.Matsumoto and T.Nishimura, 1998 ).
    const RandM = UInt128(397)
    const RandN = UInt128(624)
    const MaskU = UInt128(0x80000000)
    const MaskL = UInt128(0x7fffffff)
    const Mask32 = UInt128(0xffffffff)
    StoneRand = zeros(UInt128, Color_NB, Square_NB)
    mutable struct RandWorkT
        count
        cnst
        vec
    end
    function IniRand(rwt, u)
        rwt.cnst = Dict{UInt128, UInt128}()
        rwt.vec = Dict{UInt128, UInt128}()
        rwt.count = RandN
        rwt.cnst[0] = UInt128(0)
        rwt.cnst[1] = UInt128(0x9908b0df)
        #limit = RandN - 1
        for i = 1:RandN
            u = UInt128((i + 1812433253 * (u ⊻ (u >> UInt128(30)))))
            u &= Mask32
            rwt.vec[i] = u
        end
    end
    function Rand32(rwt)
        if rwt.count == RandN
            rwt.count = 0
            limit = RandN - RandM
            for i = 1:limit
                u = rwt.vec[i] & MaskU
                u |= rwt.vec[i + 1] & MaskL
                u0 = rwt.vec[i + RandM]
                u1 = UInt128(u >> UInt128(1))
                k = u & 1
                u2 = rwt.cnst[k]
                rwt.vec[i] = u0 ⊻ u1 ⊻ u2
                #println("i="*string(i))
            end
            istart = limit + 1
            limit = RandN - 1
            for i = istart:limit
                u = rwt.vec[i] & MaskU
                u |= rwt.vec[i + 1] & MaskL
                u0 = rwt.vec[i + RandM - RandN]
                u1 = UInt128(u >> UInt128(1))
                k = u & 1
                u2 = rwt.cnst[k]
                rwt.vec[i] = u0 ⊻ u1 ⊻ u2
            end
            #println(limit)
        end
        u = rwt.vec[rwt.count + 1]
        rwt.count += 1
        u ⊻= UInt128((u >> UInt128(11)))
        u ⊻= UInt128((u << UInt128(7)) & UInt128(0x9d2c5680))
        u ⊻= UInt128((u << UInt128(15)) & UInt128(0xefc60000))
        u ⊻= UInt128(u >> UInt128(18))
        return u
    end
    function Rand64(rwt)
        h = Rand32(rwt)
        l = Rand32(rwt)
        v = UInt128(l) | UInt128(h << UInt128(32))
        return v
    end
    function Rand128(rwt)
        h = Rand64(rwt)
        l = Rand64(rwt)
        v = UInt128(l) | UInt128(h << UInt128(64))
        return v
    end
    function IniRandomTable()
        #rwt =[]
        #for k = 1:4
        #    a = RandWorkT(0, 0, 0)
        #    IniRand(a, UInt128(5489))
        #    push!(rwt, a)
        #end
        rwt = RandWorkT(0, 0, 0)
        IniRand(rwt, UInt128(5489))
        for i = 1:Color_NB
            for j = 1:Square_NB
                StoneRand[i, j] = Rand128(rwt)
            end
        end
    end
end
export Hash