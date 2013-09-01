#! /usr/bin/env python

#
# This file takes in the "results" output from multitime, processes it, and
# outputs HTML (by default) or LaTeX files (suitable for inclusion into a paper).
#
# python format_results.py [latex]
#

import os, re, stat, subprocess, sys, time

RESULTS_PATH = "results"
VMS_MAP = {
  "c"             : "GCC (4.7.2)",
  "java"          : "HotSpot (1.7.0_09)",
  "converge1"     : "Converge1 (git 14563464)",
  "converge2"     : "Converge2 (git 52bc61a3)",
  "cpython"       : "CPython (2.7.5)",
  "jruby"         : "JRuby (1.7.4)",
  "jython"        : "Jython (2.5.3)",
  "lua"           : "Lua (5.2.2)",
  "luajit"        : "LuaJIT (2.0.2)",
  "pypy-jit-no-object-optimizations" : "PyPy--nonopt (2.1)",
  "pypy-jit-standard" : "PyPy (2.1)",
  "ruby"          : "Ruby (2.0.0-p247)",
  "topaz"         : "Topaz (nightly)",
  "d8"            : "V8 (3.20.15)"
}
VMS_ORDER=["c", "java", "converge1", "converge2", "d8", "lua", "luajit", "cpython", \
  "jython", "pypy-jit-no-object-optimizations", "pypy-jit-standard", "ruby", "jruby", \
  "topaz"]
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



def latex_timings(benchmarks, outp, width, bench_filter, vm_filter):
    vms_used = set()
    bns_used = set()
    for vm, bn, sz, mean, conf in benchmarks: # Benchmark result leaf name, benchmark results
        if bench_filter and not bench_filter(bn):
            continue
        bns_used.add((bn, sz))
        if vm_filter and not vm_filter(vm):
            continue
        vms_used.add(vm)

    bns_used = list(bns_used)
    bns_used.sort()
    with file(outp, "w") as f:
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
            safe_dvm = VMS_MAP[dvm].replace("#", "\\#").replace("_", "\\_")
            f.write("%s" % safe_dvm)
            for dbn, dsz in bns_used:
                for vm, bn, sz, mean, conf in benchmarks:
                    if dvm == vm and dbn == bn and dsz == sz:
                        f.write(" & \\multicolumn{1}{r}{%0.3f} & \\tiny{$\pm$} & \\tiny{%0.3f}" % (mean, conf))
                        break
                else:
                    f.write(" & & - &")
            f.write("\\\\\n")

        f.write("\\bottomrule\n")
        f.write("\end{tabularx}\n")
        f.write("\end{center}\n")




def html_timings(benchmarks, outp):
    vms_used = set()
    bns_used = set()
    for vm, bn, sz, mean, conf in benchmarks: # Benchmark result leaf name, benchmark results
        bns_used.add((bn, sz))
        vms_used.add(vm)

    bns_used = list(bns_used)
    bns_used.sort()
    with file(outp, "w") as f:
        t = time.localtime(os.stat("results")[stat.ST_MTIME])
        ppt = time.strftime(r"%Y-%m-%d %H:%M:%S %Z", t)
        f.write("""<!doctype html public "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<head>
<title>VMs experiment</title>
<style type="text/css">
table { border-spacing: 0 }
.top-rule    td { border-top: 2px solid black }
.mid-rule    td { border-bottom: 1px solid black }
.bottom-rule td { border-bottom: 2px solid black }
.smaller        { font-size: 50%% }
.plusmn         { font-size: 50%% ; padding: 0 5px 0 5px }
.left-margin    { padding-left: 30px }
h1              { text-align: center }
h3              { text-align: center; margin-top: 75px }
</style>
</head>
<body>

<h1>VMs experiment</h1>

This page is an auto-generated pretty printing of the results of running the
experiments that form part of the paper <a
href="http://tratt.net/laurie/research/publications/files/metatracing_vms/">
The Impact of Meta-Tracing on VM Design and Implementation</a> by Carl
Friedrich Bolz and Laurence Tratt. The <code>dmesg</code> for the machine
used to produce these results can be seen below.

<h3>Experimental results</h3>

The results here come from a <code>results</code> file last modified at %s.

<p>""" % ppt)

        f.write("""<table style="margin: 0 auto 0 auto">\n""")
        i = 0
        while i < len(bns_used):
            if i > 0:
                f.write("<tr><td>&nbsp;</td></tr>")
            
            bns = bns_used[i : i + 4]

            f.write("""<tr class="top-rule"><td></td>""")
            short_bns = list(set([bn for (bn, sz) in bns]))
            short_bns.sort()
            j = 0
            for short_bn in short_bns:
                if j == 0:
                    f.write("""<td class="left-margin" """)
                else:
                    f.write("<td ")
                f.write("""colspan=6 style="text-align: center">%s</td>""" % BENCH_MAP[short_bn])
                j += 1
            f.write("""</tr>\n<tr class="mid-rule"><td></td>""")
            j = 0
            for bn, sz in bns:
                if j == 0:
                    f.write("""<td class="left-margin" """)
                else:
                    f.write("<td ")
                f.write("""colspan=3 style="text-align: center">%s</td>""" % SIZE_MAP.get(sz, sz))
                j += 1
            f.write("</tr>\n")

            vms_used = list(vms_used)
            vms_used.sort(lambda x, y: cmp(VMS_ORDER.index(x), VMS_ORDER.index(y)))
            j = 0
            for dvm in vms_used:
                if j + 1 == len(vms_used):
                    f.write("""<tr class="bottom-rule">\n""")
                else:
                    f.write("<tr>\n")
                f.write("<td>%s</td>" % VMS_MAP[dvm])
                k = 0
                for dbn, dsz in bns:
                    for vm, bn, sz, mean, conf in benchmarks:
                        if dvm == vm and dbn == bn and dsz == sz:
                            if k == 0:
                                f.write("""<td class="left-margin">%0.3f</td>""" % mean)
                            else:
                                f.write("""<td>%0.3f</td>""" % mean)
                            f.write("""<td class="plusmn">&plusmn;</td><td class="smaller"   >%0.3f</td>""" % conf)
                            break
                    else:
                        f.write("<td></td><td></td><td>-</td>")
                f.write("\n")
                f.write("""</tr class="top-rule">""")
                j += 1

            f.write("")

            i += 4

        f.write("</table>\n")
        
        f.write("<h3>dmesg</h3>\n<pre>")
        dm = subprocess.Popen("dmesg", stdout=subprocess.PIPE)
        f.write(dm.stdout.read())
        f.write("</pre>\n</html>")
        



benchmarks = read_data()
if "latex" in sys.argv:
    latex_timings(benchmarks, "abbrev.tex", "1.2\\textwidth", \
      lambda x: x in ["dhrystone", "fannkuchredux", "richards"], None)
    latex_timings(benchmarks, "full1.tex", "\\textwidth", \
      lambda x: x in ["binarytrees", "dhrystone", "fannkuchredux"], \
      lambda x: not "converge" in x)
    latex_timings(benchmarks, "full2.tex", "\\textwidth", \
      lambda x: x in ["fasta", "knucleotide", "mandelbrot"], \
      lambda x: not "converge" in x)
    latex_timings(benchmarks, "full3.tex", "\\textwidth", \
      lambda x: x in ["nbody", "regexdna", "revcomp"], \
      lambda x: not "converge" in x)
    latex_timings(benchmarks, "full4.tex", ".72\\textwidth", \
      lambda x: x in ["richards", "spectralnorm"], \
      lambda x: not "converge" in x)
else:
    html_timings(benchmarks, "results.html")