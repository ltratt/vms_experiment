#! /bin/sh

missing=0
check_for () {
	which $1 > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: can't find $1 binary"
        missing=1
    fi
}

check_for cc
check_for g++
check_for bunzip2
check_for git
check_for hg
check_for python
check_for svn
check_for unzip
check_for xml2-config
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

java -version 2>&1 | tail -n 1 | grep "OpenJDK .*Server VM (build 24.79-b02, mixed mode)" > /dev/null 2> /dev/null
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
  http://web.archive.org/web/20050825101121/http://www.sunlabs.com/people/mario/java_benchmarking/index.html
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
wget https://raw.githubusercontent.com/ltratt/supuner/master/supuner || exit $?
wget https://raw.githubusercontent.com/ltratt/srep/master/srep || exit $?
chmod a+x srep supuner

echo "\\n===> Fetching and building multitime\\n"

wget http://tratt.net/laurie/src/multitime/releases/multitime-1.3.tar.gz || exit $?
tar xfz multitime-1.3.tar.gz
cd multitime-1.3
./configure || exit $?
make || exit $?
cp multitime ..


# CPython

echo "\\n===> Download and build CPython\\n"
sleep 3
CPYTHONV=2.7.9
cd $wrkdir
wget http://python.org/ftp/python/${CPYTHONV}/Python-${CPYTHONV}.tgz || exit $?
tar xfz Python-${CPYTHONV}.tgz || exit $?
mv Python-${CPYTHONV} cpython
cd cpython
./configure || exit $?
$MYMAKE || exit $?
cp $wrkdir/cpython/Lib/test/pystone.py $wrkdir/benchmarks/dhrystone.py


# JRuby

echo "\\n===> Download and build JRuby\\n"
sleep 3
JRUBYV=1.7.20.1
cd $wrkdir
wget http://jruby.org.s3.amazonaws.com/downloads/${JRUBYV}/jruby-bin-${JRUBYV}.tar.gz || exit $?
tar xfz jruby-bin-${JRUBYV}.tar.gz
git clone git://github.com/jruby/jruby.git || exit $?
mv jruby jruby_src
mv jruby-${JRUBYV} jruby
cd jruby_src
git checkout ${JRUBYV}


# Jython

echo "\\n===> Download and build Jython\\n"
sleep 3
cd $wrkdir
JYTHONV=2.7.0
wget -O jython-installer-${JYTHONV}-java.jar \
  "http://search.maven.org/remotecontent?filepath=org/python/jython-installer/${JYTHONV}/jython-installer-${JYTHONV}.jar" \
   || exit $?
wget -O jython-${JYTHONV}-sources.jar \
  "http://search.maven.org/remotecontent?filepath=org/python/jython/${JYTHONV}/jython-${JYTHONV}-sources.jar" \
   || exit $?
java -jar jython-installer-${JYTHONV}-java.jar -s -d jython || exit $?
cd jython
unzip -fo ../jython-${JYTHONV}-sources.jar


# Lua

echo "\\n===> Download and build Lua\\n"
sleep 3
LUAV=5.3.1
cd $wrkdir
wget http://www.lua.org/ftp/lua-${LUAV}.tar.gz || exit $?
tar xfz lua-${LUAV}.tar.gz
mv lua-${LUAV} lua
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
LUAJITV=2.0.4
cd $wrkdir
wget http://luajit.org/download/LuaJIT-${LUAJITV}.tar.gz || exit $?
tar xfz LuaJIT-${LUAJITV}.tar.gz
mv LuaJIT-${LUAJITV} luajit
cd luajit
CFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT $MYMAKE || exit $?


# PHP

echo "\\n===> Download and build PHP\\n"
sleep 3
PHPV=5.6.10
cd $wrkdir
wget -O php-${PHPV}.tar.bz2 http://uk3.php.net/get/php-${PHPV}.tar.bz2/from/this/mirror || exit $?
bunzip2 -c - php-${PHPV}.tar.bz2 | tar xf - || exit $?
mv php-${PHPV} php
cd php
./configure || exit $?
$MYMAKE || exit $?


# Download and build PyPy

echo "\\n===> Download PyPy\\n"
sleep 3
PYPYV=2.6.0
cd $wrkdir
wget https://bitbucket.org/pypy/pypy/downloads/pypy-${PYPYV}-src.tar.bz2 || exit $?
bunzip2 -c - pypy-${PYPYV}-src.tar.bz2 | tar xf -
mv pypy-${PYPYV}-src pypy
cd pypy/pypy/goal/
echo "\\n===> Build normal PyPy\\n"
sleep 3
usession=`mktemp -d`
PYPY_USESSION_DIR=$usession $PYTHON ../../rpython/bin/rpython -Ojit --no-shared --output=pypy || exit $?
rm -rf $usession


# Ruby

echo "\\n===> Download and build Ruby\\n"
sleep 3
RUBYV=2.2.2
cd $wrkdir
wget ftp://ftp.ruby-lang.org/pub/ruby/2.2/ruby-${RUBYV}.tar.gz || exit $?
tar xfz ruby-${RUBYV}.tar.gz
mv ruby-${RUBYV} ruby
cd ruby
./configure --prefix=$wrkdir/ruby_inst || exit $?
$MYMAKE install || exit $?


# V8

echo "\\n===> Download and build V8\\n"
cd $wrkdir
V8_V=4.5.75
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
PATH=depot_tools:$PATH fetch v8 || exit $?
cd v8
git checkout ${V8_V} || exit $?
make native || exit $?


# Download the remaining benchmarks

echo "\\n===> Download and build misc benchmarks\\n"

t=`mktemp -d`
cd $t
wget http://www.wolczko.com/richdbsrc.zip || exit $?
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
