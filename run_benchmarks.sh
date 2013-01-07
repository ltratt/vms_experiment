#! /bin/sh

REPS=30

WRKDIR=`pwd`
BATCHF="$WRKDIR/batchf"
RESULTSF="$WRKDIR/results"

if [ ! -f multitime ]; then
    $SHELL ./build.sh || exit $?
fi

if [ -f $RESULTSF ]; then
    echo "$RESULTSF already exists. Will not overwrite."
    exit 1
fi
rm -f $BATCHF
touch $BATCHF

if [ "X$CC" = "X" ]; then
    CC=cc
fi

benchmark () {
    for leaf in `ls $1.* | sort`; do
        result_file=$WRKDIR/results/$leaf_$1
        leaf_ne=`echo $leaf | cut -d "." -f 1`
        echo $leaf
        case $leaf in
            *.c )
              if [ $leaf = "dhrystone.c" ]; then
                  $CC -O3 -o dhrystone_c dhrystone.c dhry_2.c || exit $?
              elif [ $leaf = "binarytrees.c" -o $leaf = "nbody.c" -o $leaf = "spectralnorm.c" ]; then
                  $CC -O3 -o ${leaf_ne}_c $leaf -lm || exit $?
              else
                  $CC -O3 -o ${leaf_ne}_c $leaf || exit $?
              fi
              echo "-q ./${leaf_ne}_c $2" >> $BATCHF
              ;;
            *.cv )
              if [ $leaf != "fannkuchredux.cv" ]; then
                  # fannkuchredux causes converge1 to crash; we therefore don't
                  # bother running it.
                  echo "-q -r \"$WRKDIR/converge1/vm/converge $WRKDIR/converge1/compiler/convergec -fm $leaf\" $WRKDIR/converge1/vm/converge $leaf_ne $2" >> $BATCHF
              fi
              echo "-q -r \"$WRKDIR/converge2/vm/converge $WRKDIR/converge2/compiler/convergec -fm $leaf\" $WRKDIR/converge2/vm/converge $leaf_ne $2" >> $BATCHF
              ;;
            *.java )
              javac $leaf || exit $?
              echo "-q java -Xmx2500M `echo $leaf | cut -d "." -f 1` $2" >> $BATCHF
              ;;
            *.lua )
              echo "-q $WRKDIR/lua/src/lua $leaf $2" >> $BATCHF
              echo "-q $WRKDIR/luajit/src/luajit $leaf $2" >> $BATCHF
              ;;
            *.py )
              echo "-q $WRKDIR/cpython/python $leaf $2" >> $BATCHF
              echo "-q $WRKDIR/jython/bin/jython -J-Xmx2500M $leaf $2" >> $BATCHF
              echo "-q $WRKDIR/pypy/pypy/translator/goal/pypy-jit-standard $leaf $2" >> $BATCHF
              echo "-q $WRKDIR/pypy/pypy/translator/goal/pypy-jit-no-object-optimizations $leaf $2" >> $BATCHF
              ;;
            *.rb )
              echo "-q $WRKDIR/jruby/bin/jruby -Xcompile.invokedynamic=true -J-Xmx2500M $leaf $2" >> $BATCHF
              echo "-q $WRKDIR/ruby/ruby -I $WRKDIR/ruby/ -I $WRKDIR/ruby/lib $leaf $2" >> $BATCHF
        esac
    done
}



benchmark_pipein () {
    for leaf in `ls $1.* | sort`; do
        result_file=$WRKDIR/results/$leaf_$1
        leaf_ne=`echo $leaf | cut -d "." -f 1`
        echo $leaf
        case $leaf in
            *.c )
              if [ $leaf = "knucleotide.c" -o $leaf = "revcomp.c" ]; then
                  $CC -O3 -std=c99 -o ${leaf_ne}_c $leaf -lpthread || exit $?
              elif [ $leaf = "regexdna.c" ]; then
                  $CC -O3 -o ${leaf_ne}_c regexdna.c -lpcre || exit $?
              else
                  $CC -O3 -o ${leaf_ne}_c $leaf || exit $?
              fi
              echo "-q -i \"cat $3\" ./${leaf_ne}_c $2" >> $BATCHF
              ;;
            *.java )
              javac $leaf || exit $?
              echo "-q -i \"cat $3\" java -Xmx2500M `echo $leaf | cut -d "." -f 1` $2" >> $BATCHF
              ;;
            *.lua )
              echo "-q -i \"cat $3\" $WRKDIR/lua/src/lua $leaf $2" >> $BATCHF
              echo "-q -i \"cat $3\" $WRKDIR/luajit/src/luajit $leaf $2" >> $BATCHF
              ;;
            *.py )
              echo "-q -i \"cat $3\" $WRKDIR/cpython/python $leaf $2" >> $BATCHF
              echo "-q -i \"cat $3\" $WRKDIR/jython/bin/jython -J-Xmx2500M $leaf $2" >> $BATCHF
              echo "-q -i \"cat $3\" $WRKDIR/pypy/pypy/translator/goal/pypy-jit-standard $leaf $2" >> $BATCHF
              echo "-q -i \"cat $3\" $WRKDIR/pypy/pypy/translator/goal/pypy-jit-no-object-optimizations $leaf $2" >> $BATCHF
              ;;
            *.rb )
              echo "-q -i \"cat $3\" $WRKDIR/jruby/bin/jruby -Xcompile.invokedynamic=true -J-Xmx2500M $leaf $2" >> $BATCHF
              echo "-q -i \"cat $3\" $WRKDIR/ruby/ruby -I $WRKDIR/ruby/ -I $WRKDIR/ruby/lib $leaf $2" >> $BATCHF
        esac
    done
}

echo "===> Creating test sets"

cd $WRKDIR/benchmarks
$WRKDIR/pypy/pypy/translator/goal/pypy-jit-standard fasta.py 1000000  > input1000000.txt
$WRKDIR/pypy/pypy/translator/goal/pypy-jit-standard fasta.py 10000000 > input10000000.txt

# Make Jython bootstrap its libraries (only happens once)

echo "===> Bootstrapping Jython libraries"

$WRKDIR/jython/bin/jython -m test.pystone


echo "===> Populating $BATCHF"

cd $WRKDIR/benchmarks
benchmark binarytrees 14
benchmark binarytrees 19
benchmark dhrystone 50000
benchmark dhrystone 5000000
benchmark fannkuchredux 10
benchmark fannkuchredux 11
benchmark fasta 5000000
benchmark fasta 50000000
benchmark_pipein knucleotide 0 input1000000.txt
benchmark_pipein knucleotide 0 input10000000.txt
benchmark mandelbrot 500
benchmark mandelbrot 5000
benchmark nbody 2500000
benchmark nbody 25000000
benchmark_pipein regexdna 0 input1000000.txt
benchmark_pipein regexdna 0 input10000000.txt
benchmark_pipein revcomp 0 input1000000.txt
benchmark_pipein revcomp 0 input10000000.txt
benchmark richards 10
benchmark richards 100
benchmark spectralnorm 500
benchmark spectralnorm 5000

echo "===> Running benchmarks"

cd $WRKDIR/benchmarks
RUBYOPT="" $WRKDIR/supuner -e -o $RESULTSF $WRKDIR/multitime -v -n $REPS -b $BATCHF