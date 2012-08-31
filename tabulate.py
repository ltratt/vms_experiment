#! /usr/bin/env python

import os, re

RESULTS_PATH = "results"
VMS_MAP = {
  "java"          : "HotSpot",
  "converge1"     : "Converge1",
  "converge2"     : "Converge2",
  "cpython"       : "CPython",
  "jruby"         : "JRuby",
  "jython"        : "Jython",
  "lua"           : "Lua",
  "luajit"        : "LuaJIT",
  "pypy_noopt"    : "PyPy--nonopt",
  "pypy_standard" : "PyPy",
  "ruby"          : "Ruby"
}
VMS_ORDER=["java", "converge1", "converge2", "lua", "luajit", "cpython", \
  "jython", "pypy_noopt", "pypy_standard", "ruby", "jruby"]
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
RE_BENCHMARK = re.compile("(.*?)_(.*?)_(.*)")


def read_data():
    benchmarks = {}
    for leaf in os.listdir(RESULTS_PATH):
        path = os.path.join(RESULTS_PATH, leaf)
        print "Processing", path + "..."
        with file(path) as f:
            s = f.read()
            if len(s.strip()) == 0 or "exited with a non-zero return code on" in s:
                benchmarks[leaf] = [None, None]
                continue
            lines = s.splitlines()
            means = lines[2]
            stddev = lines[3]
            assert means.startswith("Means:")
            assert stddev.startswith("Std. devs:")
            mean = float(means.partition("real ")[2].partition(" user ")[0])
            stddev = float(stddev.partition("real ")[2].partition(" user ")[0])
            benchmarks[leaf] = [mean, stddev * 1.959964]
    return benchmarks



def timings(benchmarks, out_path, width, bench_filter, vm_filter):
    vms_used = set()
    bns_used = set()
    for bl in benchmarks.keys(): # Benchmark result leaf name, benchmark results
        m = RE_BENCHMARK.match(bl)
        bn, bsz, bvm = m.groups()
        if bench_filter and not bench_filter(bn):
            continue
        bns_used.add("%s_%s" % (bn, bsz))
        if vm_filter and not vm_filter(bvm):
            continue
        vms_used.add(bvm)

    bns_used = list(bns_used)
    bns_used.sort()
    with file(out_path, "w") as f:
        f.write("\\begin{center}\n")
        f.write("\\begin{tabularx}{%s}{l" % width + ">{\\raggedleft}X@{\hspace{-5pt}}c@{\hspace{5pt}}X" * (len(bns_used)) + "}\n")
        f.write("\\toprule\n")
        short_bns = list(set([bn.split("_")[0] for bn in bns_used]))
        short_bns.sort()
        for short_bn in short_bns:
            f.write("& \\multicolumn{6}{c}{%s} " % BENCH_MAP[short_bn])
        f.write("\\\\\n")
        for short_bn in bns_used:
            t = short_bn.split("_")[1]
            f.write("& \\multicolumn{3}{c}{%s} " % SIZE_MAP.get(t, t))
        f.write("\\\\\n")
        f.write("\\midrule\n")

        vms_used = list(vms_used)
        vms_used.sort(lambda x, y: cmp(VMS_ORDER.index(x), VMS_ORDER.index(y)))
        for vm in vms_used:
            f.write("%s" % VMS_MAP[vm])
            for bn in bns_used:
                mean, stddev = benchmarks.get("%s_%s" % (bn, vm)) or [None, None]
                if mean is None:
                    f.write(" & & - &")
                else:
                    f.write(" & \\multicolumn{1}{r}{%0.2f} & \\tiny{$\pm$} & \\tiny{%0.2f}" % (mean, stddev))
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