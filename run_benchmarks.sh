#! /usr/bin/env bash

REPS=30

OLDPWD=`pwd`
WRKDIR=$(cd $(dirname $0) ; pwd)
BATCHF="$WRKDIR/batchf"
RESULTSF="$WRKDIR/results"

while (( $# )); do
    case "$1" in
        --target|-t)
            EXECUTABLE="$2"
            CUSTOMFILEEXT="$3"
            shift 3
            ;;
        --benchmark|-b)
            BENCHMARK="$2"
            shift 2
            ;;
        --force|-f)
            rm -f "$RESULTSF"
            shift
            ;;
        --repetitions|-r)
            REPS=$2
            shift 2
            ;;
        --available-benchmarks)
            pushd $WRKDIR/benchmarks
            echo "Available benchmarks:"
            for i in *.py; do
                echo "   ${i%*.py}"
            done
            popd
            exit 0
            ;;
        *)
            echo "You can pass the following options:"
            echo "  --target|-t [FULLPATH] [EXT]   # EXT should be e.g. 'java' or 'rb'"
            echo "  --benchmark|-b [NAME]"
            echo "  --force|-f                     # overwrites any previous results"
            echo "  --repetitions|-r [NUMBER]"
            exit 0
            ;;
    esac
done

if [ ! -f $WRKDIR/multitime ]; then
    $SHELL $WRKDIR/build.sh || exit $?
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
    name=$1
    count=$2
    if [ $# -eq 3 ]; then
        pipe="-i \"cat $3\""
    else
        pipe=""
    fi

    for leaf in `ls $name.* | sort`; do
        result_file=$WRKDIR/results/$leaf_$name
        leaf_ne=`echo $leaf | cut -d "." -f 1`
        leaf_ext=`echo $leaf | cut -d "." -f 2`
        if [ -n "$BENCHMARK" -a "$BENCHMARK" != "$leaf_ne" ]; then
            continue
        fi
        if [ -n "$CUSTOMFILEEXT" -a "$CUSTOMFILEEXT" != "$leaf_ext" ]; then
            continue
        fi
        unset cmds
        case $leaf in
            *.c )
              if [ $leaf = "dhrystone.c" ]; then
                  $CC -O3 -o dhrystone_c dhrystone.c dhry_2.c || exit $?
              elif [ $leaf = "binarytrees.c" -o $leaf = "nbody.c" -o $leaf = "spectralnorm.c" ]; then
                  $CC -O3 -o ${leaf_ne}_c $leaf -lm || exit $?
              elif [ $leaf = "knucleotide.c" -o $leaf = "revcomp.c" ]; then
                  $CC -O3 -std=c99 -o ${leaf_ne}_c $leaf -lpthread || exit $?
              elif [ $leaf = "regexdna.c" ]; then
                  $CC -O3 -o ${leaf_ne}_c regexdna.c -lpcre || exit $?
              else
                  $CC -O3 -o ${leaf_ne}_c $leaf || exit $?
              fi
              cmds[0]="$WRKDIR/benchmarks/${leaf_ne}_c $count"
              ;;
            *.cv )
              cmds[0]="-r \"$WRKDIR/converge2/vm/converge $WRKDIR/converge2/compiler/convergec -fm $leaf\" $WRKDIR/converge2/vm/converge $leaf_ne $count"
              if [ $leaf != "fannkuchredux.cv" ]; then
                  # fannkuchredux causes converge1 to crash; we therefore don't
                  # bother running it.
                  cmds[1]="-r \"$WRKDIR/converge1/vm/converge $WRKDIR/converge1/compiler/convergec -fm $leaf\" $WRKDIR/converge1/vm/converge $leaf_ne $count"
              fi
              ;;
            *.java )
              javac $leaf || exit $?
              cmds[0]="java -Xmx2500M `echo $leaf | cut -d "." -f 1` $count"
              ;;
            *.lua )
              cmds[0]="-q $WRKDIR/lua/src/lua $leaf $count"
              cmds[1]="-q $WRKDIR/luajit/src/luajit $leaf $count"
              ;;
            *.py )
              cmds[0]="$WRKDIR/cpython/python $leaf $count"
              cmds[1]="$WRKDIR/jython/bin/jython -J-Xmx2500M $leaf $count"
              cmds[2]="$WRKDIR/pypy/pypy/translator/goal/pypy-jit-standard $leaf $count"
              cmds[3]="$WRKDIR/pypy/pypy/translator/goal/pypy-jit-no-object-optimizations $leaf $count"
              ;;
            *.rb )
              cmds[0]="$WRKDIR/jruby/bin/jruby -Xcompile.invokedynamic=true -J-Xmx2500M $leaf $count"
              cmds[1]="$WRKDIR/ruby/ruby -I $WRKDIR/ruby/ -I $WRKDIR/ruby/lib $leaf $count"
              cmds[2]="-q $WRKDIR/topaz/bin/topaz $leaf $count"
        esac

        if [ -z "$EXECUTABLE" ]; then
            for i in "${cmds[@]}"; do
                echo "-q $pipe $i" >> $BATCHF
            done
        else
            echo "-q $pipe $EXECUTABLE $leaf $count" >> $BATCHF
        fi
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
benchmark knucleotide 0 input1000000.txt
benchmark knucleotide 0 input10000000.txt
benchmark mandelbrot 500
benchmark mandelbrot 5000
benchmark nbody 2500000
benchmark nbody 25000000
benchmark regexdna 0 input1000000.txt
benchmark regexdna 0 input10000000.txt
benchmark revcomp 0 input1000000.txt
benchmark revcomp 0 input10000000.txt
benchmark richards 10
benchmark richards 100
benchmark spectralnorm 500
benchmark spectralnorm 5000

echo "===> Running benchmarks"

cd $WRKDIR/benchmarks
RUBYOPT="" $WRKDIR/supuner -e -o $RESULTSF $WRKDIR/multitime -v -n $REPS -b $BATCHF

cd $OLDPWD
