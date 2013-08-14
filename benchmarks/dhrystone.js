"use strict";
var Ident1 = 1, Ident2 = 2, Ident3 = 3, Ident4 = 4, Ident5 = 5;

function Record(PtrComp, Discr, EnumComp, IntComp, StringComp) {
    this.PtrComp = PtrComp || null;
    this.Discr = Discr || 0;
    this.EnumComp = EnumComp || 0;
    this.IntComp = IntComp || 0;
    this.StringComp = StringComp || 0;
}

Record.prototype.copy = function copy() {
    return new Record(this.PtrComp, this.Discr, this.EnumComp, this.IntComp, this.StringComp);
}

var TRUE = 1, FALSE = 0;

function main(loops) {
    loops = loops || LOOPS;
    var r = pystones(loops), benchtime = r[0], stones = r[1];
    print("JsPystone() time for " + loops + " passes = " + benchtime);
    print("This machine benchmarks at " + stones + " pystones/second");
}

function pystones(loops) { return Proc0(loops); }


var LOOPS = arguments[0];

function loop(loops) {
    return Proc0(loops || LOOPS);
}

var IntGlob = 0;
var BoolGlob = FALSE;
var Char1Glob = '\0';
var Char2Glob = '\0';
var Array1Glob = new Array(51); for (var i = 0; i < Array1Glob.length; ++i) { Array1Glob[i] = 0 }
var Array2Glob = Array1Glob.map(function(n) { return Array1Glob.slice(); });
var PtrGlb = null;
var PtrGlbNext = null;


function clock() { return new Date().valueOf() / 1000.0 }

function Proc0(loops) {
    var starttime = clock();
    for (var i = 0; i < loops; ++i) 
	/* nothing*/ ;
    var nulltime = (clock() - starttime);

    PtrGlbNext = new Record()
    PtrGlb = new Record()
    PtrGlb.PtrComp = PtrGlbNext
    PtrGlb.Discr = Ident1
    PtrGlb.EnumComp = Ident3
    PtrGlb.IntComp = 40
    PtrGlb.StringComp = "DHRYSTONE PROGRAM, SOME STRING"
    var String1Loc = "DHRYSTONE PROGRAM, 1'ST STRING"
    Array2Glob[8][7] = 10

    starttime = clock()

    for (i = 0; i < loops; ++i) {
        Proc5()
        Proc4()
        var IntLoc1 = 2
        var IntLoc2 = 3
        var String2Loc = "DHRYSTONE PROGRAM, 2'ND STRING"
        var EnumLoc = Ident2
        BoolGlob = ! Func2(String1Loc, String2Loc)
        while (IntLoc1 < IntLoc2) {
            var IntLoc3 = 5 * IntLoc1 - IntLoc2
            IntLoc3 = Proc7(IntLoc1, IntLoc2)
            IntLoc1 = IntLoc1 + 1
	}
        Proc8(Array1Glob, Array2Glob, IntLoc1, IntLoc3)
        PtrGlb = Proc1(PtrGlb)
        var CharIndex = 'A'
        while (CharIndex <= Char2Glob) {
            if (EnumLoc == Func1(CharIndex, 'C')) {
                EnumLoc = Proc6(Ident1)
	    }
            CharIndex = String.fromCharCode(CharIndex.charCodeAt(0)+1)
	}
        IntLoc3 = IntLoc2 * IntLoc1
        IntLoc2 = IntLoc3 / IntLoc1
        IntLoc2 = 7 * (IntLoc3 - IntLoc2) - IntLoc1
        IntLoc1 = Proc2(IntLoc1)
    }

    var benchtime = clock() - starttime - nulltime
    var loopsPerBenchtime;
    if (benchtime === 0.0) {
        loopsPerBenchtime = 0.0;
    } else {
        loopsPerBenchtime = (loops / benchtime)
    }
    return [benchtime, loopsPerBenchtime]
}

function Proc1(PtrParIn) {
    var NextRecord;
    PtrParIn.PtrComp = NextRecord = PtrGlb.copy()
    PtrParIn.IntComp = 5
    NextRecord.IntComp = PtrParIn.IntComp
    NextRecord.PtrComp = PtrParIn.PtrComp
    NextRecord.PtrComp = Proc3(NextRecord.PtrComp)
    if (NextRecord.Discr == Ident1) {
        NextRecord.IntComp = 6
        NextRecord.EnumComp = Proc6(PtrParIn.EnumComp)
        NextRecord.PtrComp = PtrGlb.PtrComp
        NextRecord.IntComp = Proc7(NextRecord.IntComp, 10)
    } else {
        PtrParIn = NextRecord.copy()
    }
    NextRecord.PtrComp = null
    return PtrParIn
}

function Proc2(IntParIO) {
    var IntLoc = IntParIO + 10
    while(1) {
        if (Char1Glob == 'A') {
            IntLoc = IntLoc - 1
            IntParIO = IntLoc - IntGlob
            var EnumLoc = Ident1
	}
        if (EnumLoc == Ident1)
            break
    }
    return IntParIO
}

function Proc3(PtrParOut) {
    if (PtrGlb !== null) {
        PtrParOut = PtrGlb.PtrComp
    } else {
        IntGlob = 100
    }
    PtrGlb.IntComp = Proc7(10, IntGlob)
    return PtrParOut
}

function Proc4() {
    var BoolLoc = Char1Glob == 'A'
    BoolLoc = BoolLoc || BoolGlob
    Char2Glob = 'B'
}

function Proc5() {
    Char1Glob = 'A'
    BoolGlob = FALSE
}

function Proc6(EnumParIn) {
    var EnumParOut = EnumParIn
    if (! Func3(EnumParIn)) {
        EnumParOut = Ident4
    }

    if (EnumParIn == Ident1) {
        EnumParOut = Ident1
    } else if (EnumParIn == Ident2) {
        if (IntGlob > 100) {
            EnumParOut = Ident1
	} else {
            EnumParOut = Ident4
	}
    } else if (EnumParIn == Ident3) {
        EnumParOut = Ident2
    } else if (EnumParIn == Ident4) {
        null;
    } else if (EnumParIn == Ident5) {
        EnumParOut = Ident3
    }
    return EnumParOut
}

function Proc7(IntParI1, IntParI2) {
    var IntLoc = IntParI1 + 2
    var IntParOut = IntParI2 + IntLoc
    return IntParOut
}

function Proc8(Array1Par, Array2Par, IntParI1, IntParI2) {
    var IntLoc = IntParI1 + 5
    Array1Par[IntLoc] = IntParI2
    Array1Par[IntLoc+1] = Array1Par[IntLoc]
    Array1Par[IntLoc+30] = IntLoc
// for IntIndex in range(IntLoc, IntLoc+2):
    for (var IntIndex = IntLoc; IntIndex < IntLoc+2; ++IntIndex) {
        Array2Par[IntLoc][IntIndex] = IntLoc
    }
    Array2Par[IntLoc][IntLoc-1] = Array2Par[IntLoc][IntLoc-1] + 1
    Array2Par[IntLoc+20][IntLoc] = Array1Par[IntLoc]
    IntGlob = 5
}

function Func1(CharPar1, CharPar2) {
    var CharLoc1 = CharPar1
    var CharLoc2 = CharLoc1
    if (CharLoc2 != CharPar2) {
        return Ident1
    } else {
        return Ident2
    }
}

function Func2(StrParI1, StrParI2) {
    var IntLoc = 1
    while(IntLoc <= 1) {
        if (Func1(StrParI1[IntLoc], StrParI2[IntLoc+1]) == Ident1) {
            var CharLoc = 'A'
            IntLoc = IntLoc + 1
	}
    }
    if (CharLoc >= 'W' && CharLoc <= 'Z') {
        IntLoc = 7
    }
    if (CharLoc == 'X') {
        return TRUE
    } else {
        if (StrParI1 > StrParI2) {
            IntLoc = IntLoc + 7
            return TRUE
	} else {
            return FALSE
	}
    }
}

function Func3(EnumParIn) {
    var EnumLoc = EnumParIn
    if (EnumLoc == Ident3) return TRUE;
    return FALSE
}

main(LOOPS);