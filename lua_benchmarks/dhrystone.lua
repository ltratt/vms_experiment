local LOOPS = 50000

local Ident1 = 1
local Ident2 = 2
local Ident3 = 3
local Ident4 = 4
local Ident5 = 5

function Record(PtrComp, Discr, EnumComp, IntComp, StringComp)
    if Discr == nil then Discr = 0 end
    if EnumComp == nil then EnumComp = 0 end
    if IntComp == nil then IntComp = 0 end
    if StringComp == nil then StringComp = 0 end
    return {PtrComp = PtrComp, Discr = Discr, EnumComp = EnumComp,
            IntComp = IntComp, StringComp = StringComp}
end

function copy(record)
    return Record(record.PtrComp, record.Discr, record.EnumComp,
                  record.IntComp, record.StringComp)
end


function main(loops)
    if loops == nil then loops = LOOPS end
    benchtime, stones = dhrystones(loops)
    print("dhrystone(0.1) time for", loops, "passes =", benchtime)
    print("This machine benchmarks at", stones, "dhrystones/second")
end


function dhrystones(loops)
    return Proc0(loops)
end

function make_empty_array(length)
    local r = {}
    for i = 1, length do
        r[i] = 0
    end
    return r
end

local IntGlob = 0
local BoolGlob = false
local Char1Glob = '\0'
local Char2Glob = '\0'
local Array1Glob = make_empty_array(51)
local Array2Glob = {}
for i = 1, 51 do
    Array2Glob[i] = make_empty_array(51)
end
local PtrGlb = nil
local PtrGlbNext = nil

function Proc0(loops)
    PtrGlbNext = Record()
    PtrGlb = Record()
    PtrGlb.PtrComp = PtrGlbNext
    PtrGlb.Discr = Ident1
    PtrGlb.EnumComp = Ident3
    PtrGlb.IntComp = 40
    PtrGlb.StringComp = "DHRYSTONE PROGRAM, SOME STRING"
    String1Loc = "DHRYSTONE PROGRAM, 1'ST STRING"
    Array2Glob[8][7] = 10

    starttime = os.clock()

    for i = 1, loops do
        Proc5()
        Proc4()
        local IntLoc1 = 2
        local IntLoc2 = 3
        local IntLoc3 = 0
        local String2Loc = "DHRYSTONE PROGRAM, 2'ND STRING"
        local EnumLoc = Ident2
        BoolGlob = not Func2(String1Loc, String2Loc)
        while IntLoc1 < IntLoc2 do
            IntLoc3 = 5 * IntLoc1 - IntLoc2
            IntLoc3 = Proc7(IntLoc1, IntLoc2)
            IntLoc1 = IntLoc1 + 1
        end
        Proc8(Array1Glob, Array2Glob, IntLoc1, IntLoc3)
        PtrGlb = Proc1(PtrGlb)
        local CharIndex = string.byte('A')
        while CharIndex <= string.byte(Char2Glob) do
            if EnumLoc == Func1(CharIndex, 'C') then
                EnumLoc = Proc6(Ident1)
            end
            CharIndex = CharIndex + 1
        end
        IntLoc3 = IntLoc2 * IntLoc1
        IntLoc2 = IntLoc3 / IntLoc1
        IntLoc2 = 7 * (IntLoc3 - IntLoc2) - IntLoc1
        IntLoc1 = Proc2(IntLoc1)
    end

    benchtime = os.clock() - starttime
    if benchtime == 0.0 then
        loopsPerBenchtime = 0.0
    else
        loopsPerBenchtime = (loops / benchtime)
    end
    return benchtime, loopsPerBenchtime
end

function Proc1(PtrParIn)
    NextRecord = copy(PtrGlb)
    PtrParIn.PtrComp = NextRecord
    PtrParIn.IntComp = 5
    NextRecord.IntComp = PtrParIn.IntComp
    NextRecord.PtrComp = PtrParIn.PtrComp
    NextRecord.PtrComp = Proc3(NextRecord.PtrComp)
    if NextRecord.Discr == Ident1 then
        NextRecord.IntComp = 6
        NextRecord.EnumComp = Proc6(PtrParIn.EnumComp)
        NextRecord.PtrComp = PtrGlb.PtrComp
        NextRecord.IntComp = Proc7(NextRecord.IntComp, 10)
    else
        PtrParIn = copy(NextRecord)
    end
    NextRecord.PtrComp = nil
    return PtrParIn
end

function Proc2(IntParIO)
    local IntLoc = IntParIO + 10
    while true do
        if Char1Glob == 'A' then
            IntLoc = IntLoc - 1
            IntParIO = IntLoc - IntGlob
            EnumLoc = Ident1
        end
        if EnumLoc == Ident1 then
            break
        end
    end
    return IntParIO
end

function Proc3(PtrParOut)
    if PtrGlb ~= nil then
        PtrParOut = PtrGlb.PtrComp
    else
        IntGlob = 100
    end
    PtrGlb.IntComp = Proc7(10, IntGlob)
    return PtrParOut
end

function Proc4()
    local BoolLoc = Char1Glob == 'A'
    BoolLoc = BoolLoc or BoolGlob
    Char2Glob = 'B'
end

function Proc5()
    Char1Glob = 'A'
    BoolGlob = false
end

function Proc6(EnumParIn)
    local EnumParOut = EnumParIn
    if not Func3(EnumParIn) then
        EnumParOut = Ident4
    end
    if EnumParIn == Ident1 then
        EnumParOut = Ident1
    elseif EnumParIn == Ident2 then
        if IntGlob > 100 then
            EnumParOut = Ident1
        else
            EnumParOut = Ident4
        end
    elseif EnumParIn == Ident3 then
        EnumParOut = Ident2
    elseif EnumParIn == Ident5 then
        EnumParOut = Ident3
    end
    return EnumParOut
end

function Proc7(IntParI1, IntParI2)
    local IntLoc = IntParI1 + 2
    local IntParOut = IntParI2 + IntLoc
    return IntParOut
end

function Proc8(Array1Par, Array2Par, IntParI1, IntParI2)
    local IntLoc = IntParI1 + 5
    Array1Par[IntLoc] = IntParI2
    Array1Par[IntLoc+1] = Array1Par[IntLoc]
    Array1Par[IntLoc+30] = IntLoc
    for IntIndex = IntLoc, IntLoc+1 do
        Array2Par[IntLoc][IntIndex] = IntLoc
    end
    Array2Par[IntLoc][IntLoc-1] = Array2Par[IntLoc][IntLoc-1] + 1
    Array2Par[IntLoc+20][IntLoc] = Array1Par[IntLoc]
    IntGlob = 5
end

function Func1(CharPar1, CharPar2)
    local CharLoc1 = CharPar1
    local CharLoc2 = CharLoc1
    if CharLoc2 ~= CharPar2 then
        return Ident1
    else
        return Ident2
    end
end

function Func2(StrParI1, StrParI2)
    local IntLoc = 2
    local CharLoc = '\0'
    while IntLoc <= 1 do
        if Func1(string.byte(StrParI1, IntLoc), string.byte(StrParI2, IntLoc+1)) == Ident1 then
            CharLoc = 'A'
            IntLoc = IntLoc + 1
        end
    end
    if CharLoc >= 'W' and CharLoc <= 'Z' then
        IntLoc = 7
    end
    if CharLoc == 'X' then
        return true
    else
        if StrParI1 > StrParI2 then
            IntLoc = IntLoc + 7
            return true
        else
            return false
        end
    end
end

function Func3(EnumParIn)
    local EnumLoc = EnumParIn
    if EnumLoc == Ident3 then return true end
    return false
end

nargs = table.getn(arg)
loops = tonumber(arg[1])
if nargs > 1 then
    print(nargs, "arguments are too many")
elseif nargs == 1 and loops == nil then
    print("Invalid argument", arg[1])
else
    if nargs == 0 then
        loops = LOOPS
    end
    main(loops)
end
