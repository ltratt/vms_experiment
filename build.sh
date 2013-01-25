#! /bin/sh

missing=0
check_for () {
	which $1 > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: can't find $1 binary"
        missing=1
    fi
}

check_for bunzip2
check_for git
check_for hg
check_for python
check_for svn
check_for unzip
which pypy > /dev/null 2> /dev/null
if [ $? -eq 0 ]; then
    PYTHON=`which pypy`
else
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

java -version 2>&1 | tail -n 1 | grep "OpenJDK .*Server VM (build 23.2-b09, mixed mode)" > /dev/null 2> /dev/null
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

echo "\\n===> Fetching supuner and srep\\n"

cd $wrkdir
wget https://raw.github.com/ltratt/bin/master/supuner || exit $?
wget https://raw.github.com/ltratt/bin/master/srep || exit $?
chmod a+x srep supuner

echo "\\n===> Fetching and building multitime\\n"

wget http://tratt.net/laurie/src/multitime/releases/multitime-1.2.tar.gz || exit $?
tar xfz multitime-1.2.tar.gz
cd multitime-1.2
./configure || exit $?
make || exit $?
cp multitime ..


# Converge 1

echo "\\n===> Download and build Converge1\\n"
sleep 3
cd $wrkdir
wget http://tratt.net/laurie/research/publications/files/metatracing_vms/snapshot_1.2.x.tar.bz2  || exit $?
bunzip2 -c - snapshot_1.2.x.tar.bz2|tar xf -
mv converge-current converge-1.2.x
git clone git://github.com/ltratt/converge.git || exit $?
mv converge converge1
cp -rp converge-1.2.x/bootstrap/32bit_little_endian/* converge1/bootstrap/32bit_little_endian/
cd converge1
git checkout converge-1.x
git checkout 68c795d2be
make -f Makefile.bootstrap || exit $?
./configure || exit $?
$MYMAKE || exit $?


# CPython

echo "\\n===> Download and build CPython\\n"
sleep 3
cd $wrkdir
wget http://python.org/ftp/python/2.7.3/Python-2.7.3.tar.bz2 || exit $?
bunzip2 -c - Python-2.7.3.tar.bz2 | tar xf -
mv Python-2.7.3 cpython
cd cpython
./configure || exit $?
$MYMAKE || exit $?
cp $wrkdir/cpython/Lib/test/pystone.py $wrkdir/benchmarks/dhrystone.py


# JRuby

echo "\\n===> Download and build JRuby\\n"
sleep 3
cd $wrkdir
wget http://jruby.org.s3.amazonaws.com/downloads/1.7.1/jruby-bin-1.7.1.tar.gz || exit $?
tar xfz jruby-bin-1.7.1.tar.gz
git clone git://github.com/jruby/jruby.git || exit $?
mv jruby jruby_src
mv jruby-1.7.1 jruby
cd jruby_src
git checkout 1.7.1


# Jython

echo "\\n===> Download and build Jython\\n"
sleep 3
cd $wrkdir
wget -O jython-installer-2.5.3-java.jar \
  "http://search.maven.org/remotecontent?filepath=org/python/jython-installer/2.5.3/jython-installer-2.5.3.jar" \
   || exit $?
wget -O jython-2.5.3-sources.jar \
  "http://search.maven.org/remotecontent?filepath=org/python/jython/2.5.3/jython-2.5.3-sources.jar" \
   || exit $?
java -jar jython-installer-2.5.3-java.jar -s -d jython || exit $?
cd jython
unzip -f ../jython-2.5.3-sources.jar


# Lua

echo "\\n===> Download and build Lua\\n"
sleep 3
cd $wrkdir
wget http://www.lua.org/ftp/lua-5.2.1.tar.gz || exit $?
tar xfz lua-5.2.1.tar.gz
mv lua-5.2.1 lua
cd lua
case `uname -s` in
    *BSD) $MYMAKE bsd || exit $?;;
    Darwin) $MYMAKE macosx || exit $?;;
    Linux) $MYMAKE linux || exit $?;;
    *) $MYMAKE generic || exit $?;;
esac


# Luajit

echo "\\n===> Download and build LuaJIT\\n"
sleep 3
cd $wrkdir
wget http://luajit.org/download/LuaJIT-2.0.0.tar.gz || exit $?
tar xfz LuaJIT-2.0.0.tar.gz
mv LuaJIT-2.0.0 luajit
cd luajit
$MYMAKE || exit $?


# Download and build PyPy

echo "\\n===> Download PyPy\\n"
sleep 3
cd $wrkdir
wget https://bitbucket.org/pypy/pypy/get/release-1.9.tar.bz2 || exit $?
bunzip2 -c - release-1.9.tar.bz2 | tar xf -
mv pypy-pypy-* pypy
cd pypy/pypy/translator/goal/
echo "\\n===> Build normal PyPy\\n"
sleep 3
$PYTHON translate.py -Ojit --output=pypy-jit-standard || exit $?
echo "\\n===> Build PyPy without optimisations\\n"
sleep 3
$PYTHON translate.py -O2 --translation-jit  --output=pypy-jit-no-object-optimizations targetpypystandalone.py --no-objspace-std-withcelldict --no-objspace-std-withmapdict --no-objspace-std-withmethodcache || exit $?


# Converge 2
#
# This needs PyPy to have been downloaded, hence why it's out of order.

echo "\\n===> Download and build Converge 2\\n"
sleep 3
cd $wrkdir
wget http://convergepl.org/releases/2.0/converge-2.0.tar.bz2 || exit $?
bunzip2 -c - converge-2.0.tar.bz2 | tar xf -
mv converge-2.0 converge2
cd converge2
PYPY_SRC=$wrkdir/pypy/ ./configure || exit $?
$MYMAKE regress || exit $?


# Ruby

echo "\\n===> Download and build Ruby\\n"
sleep 3
cd $wrkdir
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p327.tar.gz || exit $?
tar xfz ruby-1.9.3-p327.tar.gz
mv ruby-1.9.3-p327 ruby
cd ruby
./configure || exit $?
$MYMAKE || exit $?


# Download the remaining benchmarks

echo "\\n===> Download and build misc benchmarks\\n"

t=`mktemp -d`
cd $t
wget http://labs.oracle.com/people/mario/java_benchmarking/richdbsrc.zip || exit $?
unzip richdbsrc.zip || exit $?
mv Benchmark.java Program.java COM/sun/labs/kanban/richards_deutsch_acc_virtual/ || exit $?
cd COM/sun/labs/kanban/richards_deutsch_acc_virtual || exit $?
mv Richards.java richards.java || exit $?
patch < $wrkdir/patches/java_richards.patch || exit $?
cp *.java $wrkdir/benchmarks || exit $?
rm -fr $t

t=`mktemp -d`
cd $t
wget http://hotpy.googlecode.com/svn-history/r96/trunk/benchmarks/java/dhry.java \
  http://hotpy.googlecode.com/svn-history/r96/trunk/benchmarks/java/GlobalVariables.java \
  http://hotpy.googlecode.com/svn-history/r96/trunk/benchmarks/java/DhrystoneConstants.java \
  http://hotpy.googlecode.com/svn-history/r96/trunk/benchmarks/java/Record_Type.java || exit $?
patch < $wrkdir/patches/java_dhrystone.patch || exit $?
mv dhry.java dhrystone.java
cp *.java $wrkdir/benchmarks
rm -fr $t
