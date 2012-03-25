#! /bin/sh

missing=0
check_for () {
	which $1 > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: can't find $1 binary"
        missing=1
    fi
}

check_for git
check_for hg
check_for bunzip2
which pypy > /dev/null 2> /dev/null
if [ $? -eq 0 ]; then
    PYTHON=`which pypy`
else
    check_for python
    PYTHON=`which python`
fi
check_for java
check_for javac
which gmake > /dev/null 2> /dev/null
if [ $? -eq 0 ]; then
    MYMAKE=gmake
else
    MYMAKE=make
fi

if [ $missing -eq 1 ]; then
    exit 1
fi

java -version 2>&1 | tail -n 1 | grep "OpenJDK .*Server VM (build 21.0-b17, mixed mode)" > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
    cat << EOF
Warning: incorrect version of Java detected. Expected:
  OpenJDK Server VM (build 21.0-b17, mixed mode)
You should download the correct version and put it in your PATH.
EOF
    echo -n "Continue building anyway? [Ny] "
    read answer
    case "$answer" in
        y | Y) ;;
        *) exit 1;;
    esac
fi

cat << EOF
In order to build these benchmarks, you need to agree to the licensing terms
of the Java Richards benchmark at:
  http://labs.oracle.com/people/mario/java_benchmarking/download.html
EOF
echo -n "Have you read and agreed to these terms? [Ny] "
read answer
case "$answer" in
    y | Y) ;;
    *) exit 1;;
esac

if [ $# -eq 0 ]; then
    wrkdir=`pwd`
elif [ $# -eq 1 ]; then
    wrkdir=$1
    mkdir -p $wrkdir
else
    echo "experiment.sh [<full path to working directory>]" 
    exit 1
fi
echo "===> Working in $wrkdir"

echo "\\n===> Fetching multitime and supuner\\n"

cd $wrkdir
wget https://raw.github.com/ltratt/bin/master/multitime
wget https://raw.github.com/ltratt/bin/master/supuner
chmod a+x supuner multitime

# download and build CPython

echo "\\n===> Download and build CPython\\n"
sleep 3
cd $wrkdir
wget http://python.org/ftp/python/2.7.2/Python-2.7.2.tar.bz2
bunzip2 -c - Python-2.7.2.tar.bz2 | tar xf -
cd Python-2.7.2
./configure || exit $?
$MYMAKE || exit $?

# download and build Lua

echo "\\n===> Download and build Lua\\n"
sleep 3
cd $wrkdir
wget http://www.lua.org/ftp/lua-5.1.5.tar.gz
tar xfz lua-5.1.5.tar.gz
cd lua-5.1.5
case `uname -s` in
    *BSD) $MYMAKE bsd || exit $?;;
    Darwin) $MYMAKE macosx || exit $?;;
    Linux) $MYMAKE linux || exit $?;;
    *) $MYMAKE generic || exit $?;;
esac

# download and build Luajit

echo "\\n===> Download and build LuaJIT\\n"
sleep 3
cd $wrkdir
git clone http://luajit.org/git/luajit-2.0.git
cd luajit-2.0
git checkout 5dbb6671a3
$MYMAKE || exit $?

# download and build Jython

echo "\\n===> Download and build Jython\\n"
sleep 3
cd $wrkdir
mkdir jython
wget http://downloads.sourceforge.net/project/jython/jython/2.5.2/jython_installer-2.5.2.jar
java -jar jython_installer-2.5.2.jar  -s -d jython

# Download and build Converge 1.x

echo "\\n===> Download and build Converge 1\\n"
sleep 3
cd $wrkdir
wget http://convergepl.org/releases/current/snapshot_1.2.x.tar.bz2
bunzip2 -c - snapshot_1.2.x.tar.bz2|tar xf -
mv converge-current converge-1.2.x
git clone git://github.com/ltratt/converge.git
mv converge converge1
cp -rp converge-1.2.x/bootstrap/32bit_little_endian/* converge1/bootstrap/32bit_little_endian/
cd converge1
cp -rp examples/benchmarks examples/benchmarks_tmp
git checkout converge-1.x
git checkout 9084f0cdaf
make -f Makefile.bootstrap
./configure || exit $?
$MYMAKE || exit $?
mv examples/benchmarks_tmp examples/benchmarks
cd examples/benchmarks
../../vm/converge ../../compiler/convergec -m cvstone.cv
../../vm/converge ../../compiler/convergec -m fannkuch-redux.cv
../../vm/converge ../../compiler/convergec -m richards.cv

# Download and build PyPy

echo "\\n===> Download PyPy 1.8\\n"
sleep 3
cd $wrkdir
hg clone https://bitbucket.org/pypy/pypy
cd pypy
hg checkout release-1.8
cd pypy/translator/goal/
echo "\\n===> Build normal PyPy\\n"
sleep 3
$PYTHON translate.py -Ojit --output=pypy-jit-standard || exit $?
echo "\\n===> Build PyPy without optimisations\\n"
sleep 3
$PYTHON translate.py -O2 --translation-jit  --output=pypy-jit-no-object-optimizations targetpypystandalone.py --no-objspace-std-withcelldict --no-objspace-std-withmapdict --no-objspace-std-withmethodcache || exit $?

# Download and build Converge 2

echo "\\n===> Download and build Converge 2\\n"
sleep 3
cd $wrkdir
wget http://convergepl.org/releases/current/snapshot.tar.bz2
bunzip2 -c - snapshot.tar.bz2 | tar xf -
git clone git://github.com/ltratt/converge.git
mv converge converge2
cd converge2
git checkout e44800ec7c
cd $wrkdir
cp converge-current/bootstrap/32bit_little_endian/* converge2/bootstrap/32bit_little_endian/
rm -rf converge-current
cd converge2
PYPY_SRC=$wrkdir/pypy/ ./configure || exit $?
$MYMAKE regress || exit $?

# Download the remaining benchmarks

echo "\\n===> Download and build misc benchmarks\\n"

mkdir $wrkdir/java_benchmarks

cd $wrkdir/java_benchmarks
wget http://labs.oracle.com/people/mario/java_benchmarking/richdbsrc.zip
unzip richdbsrc.zip
mv Benchmark.java Program.java COM/sun/labs/kanban/richards_deutsch_acc_virtual/
cd COM/sun/labs/kanban/richards_deutsch_acc_virtual
patch < $wrkdir/java_benchmarks/java_richards.patch || exit $?
javac *.java || exit $?

cd $wrkdir/java_benchmarks
javac fannkuchredux.java || exit $?

wget http://hotpy.googlecode.com/svn-history/r96/trunk/benchmarks/java/dhry.java http://hotpy.googlecode.com/svn-history/r96/trunk/benchmarks/java/GlobalVariables.java http://hotpy.googlecode.com/svn-history/r96/trunk/benchmarks/java/DhrystoneConstants.java http://hotpy.googlecode.com/svn-history/r96/trunk/benchmarks/java/Record_Type.java
javac dhry.java || exit $?