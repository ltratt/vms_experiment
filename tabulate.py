#! /usr/bin/env python

#
# This file takes in the "results" output from multitime, processes it, and
# outputs LaTeX files suitable for inclusion into a paper.
#

import os, re

RESULTS_PATH = "results"
VMS_MAP = {
  "c"             : "C",
  "java"          : "HotSpot",
  "converge1"     : "Converge1",
  "converge2"     : "Converge2",
  "cpython"       : "CPython",
  "jruby"         : "JRuby",
  "jython"        : "Jython",
  "lua"           : "Lua",
  "luajit"        : "LuaJIT",
  "pypy-jit-no-object-optimizations" : "PyPy--nonopt",
  "pypy-jit-standard" : "PyPy",
  "ruby"          : "Ruby"
}
VMS_ORDER=["c", "java", "converge1", "converge2", "lua", "luajit", "cpython", \
  "jython", "pypy-jit-no-object-optimizations", "pypy-jit-standard", "ruby", "jruby"]
BENCH_MAP = {
  "binarytrees"   : "Binary Trees",
  "dhrystone"     : "Dhrystone",
  "fannkuchredux" : "Fannkuch Redux",
  "fasta"         : "Fasta",
  "knucleotide"   : "KNucleotide",
  "mandelbrot"    : "Mandelbrot",
  "nbody"         : "NBody",
  "regexdna"      : "RegexDNA",
  "revcomp"       : "RevComp",
  "richards"      : "Richards",
  "spectralnorm"  : "Spectral Norm",
  "richards"      : "Richards"
}
SIZE_MAP = {
  "input1000000.txt" : "1000000",
  "input10000000.txt" : "10000000"
}


def read_data():
    benchmarks = []
    with file("results") as f:
        d = []
        while 1:
            l = f.readline()
            if not l:
                break
            d.append(l.strip())
        
        i = 0
        while i < len(d):
            if d[i] == "===> multitime results":
                i += 1
                break
            i += 1
        
        while i < len(d):
            name = d[i]
            real_sp = re.split(" +", d[i + 2])
            mean = float(real_sp[1])
            stddev = float(real_sp[2])
            
            if "luajit" in name:
                # Since lua could match luajit or lua, we special case luajit
                vm = "luajit"
            elif "jruby" in name:
                # Ditto Ruby/JRuby
                vm = "jruby"
            else:
                for vm in VMS_MAP.keys():
                    if vm == "c":
                        continue
                    if vm in name:
                        break
                else:
                    vm = "c"

            for bn in BENCH_MAP.keys():
                if bn in name:
                    break
            else:
                raise "XXX"

            for sz in SIZE_MAP.keys():
                if sz in name:
                    break
            else:
                sz = name.strip().split(" ")[-1]
            
            benchmarks.append([vm, bn, sz, mean, stddev * 1.959964])
            
            i += 6

    return benchmarks



def timings(benchmarks, out_path, width, bench_filter, vm_filter):
    vms_used = set()
    bns_used = set()
    for vm, bn, sz, mean, conf in benchmarks: # Benchmark result leaf name, benchmark results
        if bench_filter and not bench_filter(bn):
            continue
        bns_used.add((bn, sz))
        if vm_filter and not vm_filter(vm):
            continue
        vms_used.add(vm)
    print bns_used

    bns_used = list(bns_used)
    bns_used.sort()
    with file(out_path, "w") as f:
        f.write("\\begin{center}\n")
        f.write("\\begin{tabularx}{%s}{l" % width + ">{\\raggedleft}X@{\hspace{-5pt}}c@{\hspace{5pt}}X" * (len(bns_used)) + "}\n")
        f.write("\\toprule\n")
        short_bns = list(set([bn for (bn, sz) in bns_used]))
        short_bns.sort()
        for short_bn in short_bns:
            f.write("& \\multicolumn{6}{c}{%s} " % BENCH_MAP[short_bn])
        f.write("\\\\\n")
        for bn, sz in bns_used:
            f.write("& \\multicolumn{3}{c}{%s} " % SIZE_MAP.get(sz, sz))
        f.write("\\\\\n")
        f.write("\\midrule\n")

        vms_used = list(vms_used)
        vms_used.sort(lambda x, y: cmp(VMS_ORDER.index(x), VMS_ORDER.index(y)))
        for dvm in vms_used:
            f.write("%s" % VMS_MAP[dvm])
            for dbn, dsz in bns_used:
                for vm, bn, sz, mean, conf in benchmarks:
                    if dvm == vm and dbn == bn and dsz == sz:
                        f.write(" & \\multicolumn{1}{r}{%0.3f} & \\tiny{$\pm$} & \\tiny{%0.3f}" % (mean, conf))
                        break
                else:
                    print "blank"
                    f.write(" & & - &")
            f.write("\\\\\n")

        f.write("\\bottomrule\n")
        f.write("\end{tabularx}\n")
        f.write("\end{center}\n")



benchmarks = read_data()
timings(benchmarks, "abbrev.tex", "1.2\\textwidth", \
  lambda x: x in ["dhrystone", "fannkuchredux", "richards"], None)
timings(benchmarks, "full1.tex", "\\textwidth", lambda x: x in ["binarytrees", "dhrystone", "fannkuchredux"], \
  lambda x: not "converge" in x)
timings(benchmarks, "full2.tex", "\\textwidth", lambda x: x in ["fasta", "knucleotide", "mandelbrot"], \
  lambda x: not "converge" in x)
timings(benchmarks, "full3.tex", "\\textwidth", lambda x: x in ["nbody", "regexdna", "revcomp"], \
  lambda x: not "converge" in x)
timings(benchmarks, "full4.tex", ".72\\textwidth", lambda x: x in ["richards", "spectralnorm"], \
  lambda x: not "converge" in x)