#! /bin/sh

REPS=30

if [ ! -f multitime ]; then
    $SHELL ./build.sh || exit $?
fi

wrkdir=`pwd`
mkdir -p $wrkdir/results

benchmarks () {
	cd $wrkdir/benchmarks
    for leaf in `ls $1.* | sort`; do
        result_file=$wrkdir/results/$leaf_$1
        leaf_ne=`echo $leaf | cut -d "." -f 1`
        case $leaf in
            *.cv )
              echo "\n===> Converge1 $leaf $2"
              $wrkdir/converge1/vm/converge $wrkdir/converge1/compiler/convergec -fm $leaf
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_converge1 \
                $wrkdir/cpython/python $wrkdir/multitime $REPS $wrkdir/converge1/vm/converge \
                $leaf_ne $2
              echo "\n===> Converge2 $leaf $2"
              $wrkdir/converge2/vm/converge $wrkdir/converge2/compiler/convergec -fm $leaf
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_converge2 \
                $wrkdir/cpython/python $wrkdir/multitime $REPS $wrkdir/converge2/vm/converge \
                $leaf_ne $2
              ;;
            *.java )
              echo "\n===> Java $leaf $2"
              javac $leaf
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_java \
                $wrkdir/cpython/python $wrkdir/multitime $REPS java -Xmx3072M `echo $leaf | cut -d "." -f 1` $2
              ;;
            *.lua )
              echo "\n===> Lua $leaf $2"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_lua \
                $wrkdir/cpython/python $wrkdir/multitime $REPS $wrkdir/lua/src/lua $leaf $2
              echo "\n===> Luajit $leaf $2"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_luajit \
                $wrkdir/cpython/python $wrkdir/multitime $REPS $wrkdir/luajit/src/luajit $leaf $2
              ;;
            *.py )
              echo "\n===> CPython $leaf $2"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_cpython $wrkdir/cpython/python $wrkdir/multitime $REPS \
                $wrkdir/cpython/python $leaf $2
              echo "\n===> Jython $leaf $2"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_jython \
                $wrkdir/cpython/python $wrkdir/multitime $REPS $wrkdir/jython/bin/jython -J-Xmx3072M $leaf $2
              echo "\n===> PyPy-opt $leaf $2"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_pypy_standard \
                $wrkdir/cpython/python $wrkdir/multitime $REPS $wrkdir/pypy/pypy/translator/goal/pypy-jit-standard $leaf $2
              echo "\n===> PyPy-noopt $leaf $2"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_pypy_noopt $wrkdir/cpython/python $wrkdir/multitime $REPS \
                $wrkdir/pypy/pypy/translator/goal/pypy-jit-no-object-optimizations $leaf $2
              ;;
            *.rb )
              echo "\n===> JRuby $leaf $2"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_jruby \
                $wrkdir/cpython/python $wrkdir/multitime $REPS $wrkdir/jruby/bin/jruby -J-Xmx3072M $leaf $2
              echo "\n===> Ruby $leaf $2"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$2_ruby \
                $wrkdir/cpython/python $wrkdir/multitime $REPS $wrkdir/ruby/ruby -I $wrkdir/ruby/ \
                -I $wrkdir/ruby/lib $leaf $2
        esac
    done
}

benchmarks_pipein () {
	cd $wrkdir/benchmarks
    for leaf in `ls $1.*`; do
        result_file=$wrkdir/results/$leaf_$1
        leaf_ne=`echo $leaf | cut -d "." -f 1`
        case $leaf in
            *.java )
              echo "\n===> Java $leaf $2 $3"
              javac $leaf
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$3_java \
                $wrkdir/cpython/python $wrkdir/multitime -s $REPS java -Xmx3072M `echo $leaf | cut -d "." -f 1` $2 < $3
              ;;
            *.lua )
              echo "\n===> Lua $leaf $2 $3"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$3_lua \
                $wrkdir/cpython/python $wrkdir/multitime -s $REPS $wrkdir/lua/src/lua $leaf $2 < $3
              echo "\n===> Luajit $leaf $2 $3"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$3_luajit \
                $wrkdir/cpython/python $wrkdir/multitime -s $REPS $wrkdir/luajit/src/luajit $leaf $2 < $3
              ;;
            *.py )
              echo "\n===> CPython $leaf $2 $3"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$3_cpython \
                $wrkdir/cpython/python $wrkdir/multitime -s $REPS $wrkdir/cpython/python $leaf $2 < $3
              echo "\n===> Jython $leaf $2 $3"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$3_jython \
                $wrkdir/cpython/python $wrkdir/multitime -s $REPS $wrkdir/jython/bin/jython -J-Xmx3072M \
                $leaf $2 < $3
              echo "\n===> PyPy-opt $leaf $2 $3"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$3_pypy_standard \
                $wrkdir/cpython/python $wrkdir/multitime -s $REPS \
                $wrkdir/pypy/pypy/translator/goal/pypy-jit-standard $leaf $2 < $3
              echo "\n===> PyPy-noopt $leaf $2 $3"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$3_pypy_noopt \
                $wrkdir/cpython/python $wrkdir/multitime -s $REPS \
                $wrkdir/pypy/pypy/translator/goal/pypy-jit-no-object-optimizations \
                $leaf $2 < $3
              ;;
            *.rb )
              echo "\n===> JRuby $leaf $2 $3"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$3_jruby \
                $wrkdir/cpython/python $wrkdir/multitime -s $REPS $wrkdir/jruby/bin/jruby -J-Xmx3072M \
                $leaf $2 < $3
              echo "\n===> Ruby $leaf $2 $3"
              $wrkdir/supuner -e -o $wrkdir/results/${leaf_ne}_$3_ruby \
                $wrkdir/cpython/python $wrkdir/multitime -s $REPS $wrkdir/ruby/ruby -I $wrkdir/ruby/ \
                -I $wrkdir/ruby/lib $leaf $2 < $3
        esac
    done
}

echo "===> Creating test sets"

cd $wrkdir/benchmarks
$wrkdir/pypy/pypy/translator/goal/pypy-jit-standard fasta.py 1000000  > input1000000.txt
$wrkdir/pypy/pypy/translator/goal/pypy-jit-standard fasta.py 10000000 > input10000000.txt

# Make Jython bootstrap its libraries (only happens once)

echo "===> Bootstrapping Jython libraries"

$wrkdir/jython/bin/jython -m test.pystone


# Benchmarks

benchmarks binarytrees 14
benchmarks binarytrees 19
benchmarks dhrystone 50000
benchmarks dhrystone 5000000
benchmarks fannkuchredux 10
benchmarks fannkuchredux 11
benchmarks fasta 5000000
benchmarks fasta 50000000
benchmarks_pipein knucleotide 0 input1000000.txt
benchmarks_pipein knucleotide 0 input10000000.txt
benchmarks mandelbrot 500
benchmarks mandelbrot 5000
benchmarks nbody 2500000
benchmarks nbody 25000000
benchmarks_pipein regexdna 0 input1000000.txt
benchmarks_pipein regexdna 0 input10000000.txt
benchmarks_pipein revcomp 0 input1000000.txt
benchmarks_pipein revcomp 0 input10000000.txt
benchmarks richards 10
benchmarks richards 100
benchmarks spectralnorm 500
benchmarks spectralnorm 5000
