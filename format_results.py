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
  "c"       : "GCC (4.7.2)",
  "java"    : "HotSpot (1.7.0_09)",
  "cpython" : "CPython (2.7.7)",
  "jruby"   : "JRuby (1.7.12)",
  "jython"  : "Jython (2.5.3)",
  "lua"     : "Lua (5.2.3)",
  "luajit"  : "LuaJIT (2.0.3)",
  "php"     : "PHP (5.5.13)",
  "pypy"    : "PyPy (2.3.1)",
  "ruby"    : "Ruby (2.1.2)",
  "d8"      : "V8 (3.27.34)"
}
VMS_ORDER=["c", "java", "d8", "lua", "luajit", "cpython", "jython", "php", \
  "pypy", "ruby", "jruby"]
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
    raw_data = []
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
        
        raw_data = d[i:]
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

    return benchmarks, raw_data



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




def html_timings(benchmarks, raw_data, outp):
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
Friedrich Bolz and Laurence Tratt. The <a href="#methodology">methodology</a>
for the experiment and <a href="#dmesg"><code>dmesg</code></a> and
<a href="#installed">installed software</a> for the
machine used to produce these results can be seen below. The
latest version of the experiment, including the source code of the
benchmarking suite and benchmarks, can be found <a
href="http://tratt.net/laurie/research/pubs/files/metatracing_vms/">here</a>.


<h3><a name="methodology">Methodology</a></h3>

<p>The overall aim of this experiment is to better understand the relative
performance of different VMs. Synthetic benchmarks are the only plausible
candidates for comparing VMs which implement different languages. We caution
readers about over-interpreting results based on synthetic benchmarks, since
they can easily be gamed by language implementers and are often not
representative of real workloads. Nevertheless, they are currently our only
option. We use a variety of such benchmarks to give a finer-grained view of
VM performance. Many have their roots in the <a
href="http://benchmarksgame.alioth.debian.org/">Computer Language Benchmarks
Game</a>, though we have collected others from different sources. Where a
language has several variants of a benchmark, we have tried to use the best
performing version.

<p>A fundamental problem when measuring JIT-based systems is whether to include
warm-up time or not. JIT implementers often argue that warm-up times are
irrelevant for long-running processes, and should be discounted. Others argue
that many processes run for short time periods, and that warm-up
times must be taken into account. We see merit in both
arguments and therefore report two figures for each benchmark: <em>short</em>,
where the benchmark has a low input size (e.g. 10 for Richards), and where
warm-up times can play a significant part; and <em>long</em>, where a higher
input size (e.g.~100 for Richards) tends to reduce the effect of warm-up
times. Users who run batch jobs may find the former results more relevant;
those who run long-running server processes the latter.

<p>We ran all systems using the default options, with 3 exceptions. First, we used
the <code>-O3</code> optimisation level for GCC. Second, we increased the memory
available to the HotSpot-based VMs, as otherwise several of the benchmarks
run out of memory. Third, we used the <code>-Xcompile.invokedynamic=true</code>
option for JRuby to force the use of HotSpot's <code>invokedynamic</code>
instruction, which is otherwise disabled on current versions of HotSpot.

<p>We ran each version of the benchmark 30 times using
<a href="http://tratt.net/laurie/src/multitime/"><code>multitime</code></a> to
randomise the order of executions. We report the average wall time and
confidence intervals with 95%% confidence levels.


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

        f.write("""
<h3><a name="rawdata">Raw data</a></h3>

<pre style="white-space: pre-wrap">
""")
        f.write("\n".join(raw_data))
        
        f.write("""
</pre>


<h3><a name="dmesg">dmesg</a></h3>

<pre style="white-space: pre-wrap">
""")
        
        dm = subprocess.Popen("dmesg", stdout=subprocess.PIPE)
        f.write(dm.stdout.read())
        f.write("</pre>\n</html>")

        f.write("""
</pre>

<h3><a name="installed">Installed software</a></h3>

<pre style="white-space: pre-wrap">
""")
     
        uname = subprocess.Popen(["/usr/bin/env", "uname", "-a"], stdout=subprocess.PIPE).stdout.read()
        if "Debian" in uname:
            pkgs = subprocess.Popen(["/usr/bin/dpkg", "-l"], stdout=subprocess.PIPE)
            f.write(pkgs.stdout.read())
        elif "OpenBSD" in uname:
            pkgs = subprocess.Popen(["/usr/sbin/pkg_info"], stdout=subprocess.PIPE)
            f.write(pkgs.stdout.read())
        else:
            f.write("Unable to list packages for %s" % uname)
        f.write("</pre>\n</html>")
        



benchmarks, raw_data = read_data()
if "latex" in sys.argv:
    latex_timings(benchmarks, "abbrev.tex", "1.2\\textwidth", \
      lambda x: x in ["dhrystone", "fannkuchredux", "richards"], None)
    latex_timings(benchmarks, "full1.tex", "\\textwidth", \
      lambda x: x in ["binarytrees", "dhrystone", "fannkuchredux"], \
      None)
    latex_timings(benchmarks, "full2.tex", "\\textwidth", \
      lambda x: x in ["fasta", "knucleotide", "mandelbrot"], None)
      
    latex_timings(benchmarks, "full3.tex", "\\textwidth", \
      lambda x: x in ["nbody", "regexdna", "revcomp"], None)
    latex_timings(benchmarks, "full4.tex", ".72\\textwidth", \
      lambda x: x in ["richards", "spectralnorm"], None)
else:
    html_timings(benchmarks, raw_data, "results.html")
