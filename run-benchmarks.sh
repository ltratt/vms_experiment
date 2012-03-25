#! /bin/sh

if [ ! -f multitime ]; then
    $SHELL ./build.sh || exit $?
fi

wrkdir=`pwd`
mkdir -p $wrkdir/results

echo "\\n===> Running PyPy benchmarks\\n"

pyrichards=$wrkdir/pypy/pypy/translator/goal/richards.py

cd $wrkdir/pypy/pypy/translator/goal/
$wrkdir/supuner -e -o $wrkdir/results/pypy-standard-dhrystone-fast $wrkdir/multitime 30 ./pypy-jit-standard -m test.pystone
$wrkdir/supuner -e -o $wrkdir/results/pypy-no-object-optimizations-dhrystone-fast $wrkdir/multitime 30 ./pypy-jit-no-object-optimizations -m test.pystone
$wrkdir/supuner -e -o $wrkdir/results/pypy-standard-dhrystone-slow $wrkdir/multitime 30 ./pypy-jit-standard -m test.pystone 5000000
$wrkdir/supuner -e -o $wrkdir/results/pypy-no-object-optimizations-dhrystone-slow $wrkdir/multitime 30 ./pypy-jit-no-object-optimizations -m test.pystone 5000000

$wrkdir/supuner -e -o $wrkdir/results/pypy-standard-fannkuch-fast $wrkdir/multitime 30 ./pypy-jit-standard $wrkdir/python_benchmarks/fannkuch-redux.py 10
$wrkdir/supuner -e -o $wrkdir/results/pypy-no-object-optimizations-fannkuch-fast $wrkdir/multitime 30 ./pypy-jit-no-object-optimizations $wrkdir/python_benchmarks/fannkuch-redux.py 10
$wrkdir/supuner -e -o $wrkdir/results/pypy-standard-fannkuch-slow $wrkdir/multitime 30 ./pypy-jit-standard $wrkdir/python_benchmarks/fannkuch-redux.py 11
$wrkdir/supuner -e -o $wrkdir/results/pypy-no-object-optimizations-fannkuch-slow $wrkdir/multitime 30 ./pypy-jit-no-object-optimizations $wrkdir/python_benchmarks/fannkuch-redux.py 11

$wrkdir/supuner -e -o $wrkdir/results/pypy-standard-richards-fast $wrkdir/multitime 30 ./pypy-jit-standard richards.py
$wrkdir/supuner -e -o $wrkdir/results/pypy-no-object-optimizations-richards-fast $wrkdir/multitime 30 ./pypy-jit-no-object-optimizations richards.py
$wrkdir/supuner -e -o $wrkdir/results/pypy-standard-richards-slow $wrkdir/multitime 30 ./pypy-jit-standard richards.py 100
$wrkdir/supuner -e -o $wrkdir/results/pypy-no-object-optimizations-richards-slow $wrkdir/multitime 30 ./pypy-jit-no-object-optimizations richards.py


echo "\\n===> Running CPython benchmarks\\n"

cd $wrkdir/Python-2.7.2
$wrkdir/supuner -e -o $wrkdir/results/python-dhrystone-fast $wrkdir/multitime 30 ./python -m test.pystone
$wrkdir/supuner -e -o $wrkdir/results/python-dhrystone-slow $wrkdir/multitime 30 ./python -m test.pystone 5000000

$wrkdir/supuner -e -o $wrkdir/results/python-fannkuch-fast $wrkdir/multitime 30 ./python $wrkdir/python_benchmarks/fannkuch-redux.py 10
$wrkdir/supuner -e -o $wrkdir/results/python-fannkuch-slow $wrkdir/multitime 30 ./python $wrkdir/python_benchmarks/fannkuch-redux.py 11

$wrkdir/supuner -e -o $wrkdir/results/python-richards-fast $wrkdir/multitime 30 ./python $pyrichards
$wrkdir/supuner -e -o $wrkdir/results/python-richards-slow $wrkdir/multitime 30 ./python $pyrichards 100


echo "\\n===> Running Jython benchmarks\\n"

cd $wrkdir/jython
# run jython once to make it bootstrap its libraries
./bin/jython -m test.pystone
# then do the actual benchmarks
$wrkdir/supuner -e -o $wrkdir/results/jython-dhrystone-fast $wrkdir/multitime 30 ./bin/jython -m test.pystone
$wrkdir/supuner -e -o $wrkdir/results/jython-dhrystone-slow $wrkdir/multitime 30 ./bin/jython -m test.pystone 5000000

$wrkdir/supuner -e -o $wrkdir/results/jython-fannkuch-fast $wrkdir/multitime 30 ./bin/jython $wrkdir/python_benchmarks/fannkuch-redux.py 10
$wrkdir/supuner -e -o $wrkdir/results/jython-fannkuch-slow $wrkdir/multitime 30 ./bin/jython $wrkdir/python_benchmarks/fannkuch-redux.py 11

$wrkdir/supuner -e -o $wrkdir/results/jython-richards-fast $wrkdir/multitime 30 ./bin/jython $pyrichards
$wrkdir/supuner -e -o $wrkdir/results/jython-richards-slow $wrkdir/multitime 30 ./bin/jython $pyrichards 100


echo "\\n===> Running Converge 1 benchmarks\\n"

cd $wrkdir/converge1/examples/benchmarks
$wrkdir/supuner -e -o $wrkdir/results/converge1-dhrystone-fast $wrkdir/multitime 30 ../../vm/converge cvstone
$wrkdir/supuner -e -o $wrkdir/results/converge1-dhrystone-slow $wrkdir/multitime 30 ../../vm/converge cvstone 5000000

$wrkdir/supuner -e -o $wrkdir/results/converge1-fannkuch-fast $wrkdir/multitime 30 ../../vm/converge fannkuch-redux 10
$wrkdir/supuner -e -o $wrkdir/results/converge1-fannkuch-slow $wrkdir/multitime 30 ../../vm/converge fannkuch-redux 11

$wrkdir/supuner -e -o $wrkdir/results/converge1-richards-fast $wrkdir/multitime 30 ../../vm/converge richards
$wrkdir/supuner -e -o $wrkdir/results/converge1-richards-slow $wrkdir/multitime 30 ../../vm/converge richards 100


echo "\\n===> Running Converge 2 benchmarks\\n"

cd $wrkdir/converge2/examples/benchmarks
$wrkdir/supuner -e -o $wrkdir/results/converge2-dhrystone-fast $wrkdir/multitime 30 ../../vm/converge cvstone
$wrkdir/supuner -e -o $wrkdir/results/converge2-dhrystone-slow $wrkdir/multitime 30 ../../vm/converge cvstone 5000000

$wrkdir/supuner -e -o $wrkdir/results/converge2-fannkuch-fast $wrkdir/multitime 30 ../../vm/converge fannkuch-redux 10
$wrkdir/supuner -e -o $wrkdir/results/converge2-fannkuch-slow $wrkdir/multitime 30 ../../vm/converge fannkuch-redux 11

$wrkdir/supuner -e -o $wrkdir/results/converge2-richards-fast $wrkdir/multitime 30 ../../vm/converge richards
$wrkdir/supuner -e -o $wrkdir/results/converge2-richards-slow $wrkdir/multitime 30 ../../vm/converge richards 100


echo "\\n===> Running Java benchmarks\\n"

cd $wrkdir/java_benchmarks
$wrkdir/supuner -e -o $wrkdir/results/java-dhrystone-fast $wrkdir/multitime 30 java dhry 50000
$wrkdir/supuner -e -o $wrkdir/results/java-dhrystone-slow $wrkdir/multitime 30 java dhry 5000000

cd $wrkdir/java_benchmarks
$wrkdir/supuner -e -o $wrkdir/results/java-fannkuch-fast $wrkdir/multitime 30 java fannkuchredux 10
$wrkdir/supuner -e -o $wrkdir/results/java-fannkuch-slow $wrkdir/multitime 30 java fannkuchredux 11

cd $wrkdir/java_benchmarks/COM/sun/labs/kanban/richards_deutsch_acc_virtual
$wrkdir/supuner -e -o $wrkdir/results/java-richards-fast $wrkdir/multitime 30 java Richards
$wrkdir/supuner -e -o $wrkdir/results/java-richards-slow $wrkdir/multitime 30 java Richards 100


echo "\\n===> Running Lua benchmarks\\n"

luavm=$wrkdir/lua-5.1.5/src/lua
cd $wrkdir/lua_benchmarks
$wrkdir/supuner -e -o $wrkdir/results/lua-dhrystone-fast $wrkdir/multitime 30 $luavm dhrystone.lua 50000
$wrkdir/supuner -e -o $wrkdir/results/lua-dhrystone-slow $wrkdir/multitime 30 $luavm dhrystone.lua 5000000

cd $wrkdir/lua_benchmarks
$wrkdir/supuner -e -o $wrkdir/results/lua-fannkuch-fast $wrkdir/multitime 30 $luavm fannkuch-redux.lua 10
$wrkdir/supuner -e -o $wrkdir/results/lua-fannkuch-slow $wrkdir/multitime 30 $luavm fannkuch-redux.lua 11

cd $wrkdir/lua_benchmarks
$wrkdir/supuner -e -o $wrkdir/results/lua-richards-fast $wrkdir/multitime 30 $luavm richards_oo_meta.lua 5
$wrkdir/supuner -e -o $wrkdir/results/lua-richards-slow $wrkdir/multitime 30 $luavm richards_oo_meta.lua 100


echo "\\n===> Running LuaJIT benchmarks\\n"

cd $wrkdir/lua_benchmarks
$wrkdir/supuner -e -o $wrkdir/results/luajit-dhrystone-fast $wrkdir/multitime 30 $wrkdir/luajit-2.0/src/luajit dhrystone.lua 50000
$wrkdir/supuner -e -o $wrkdir/results/luajit-dhrystone-slow $wrkdir/multitime 30 $wrkdir/luajit-2.0/src/luajit dhrystone.lua 5000000

cd $wrkdir/lua_benchmarks
$wrkdir/supuner -e -o $wrkdir/results/luajit-fannkuch-fast $wrkdir/multitime 30 $wrkdir/luajit-2.0/src/luajit fannkuch-redux.lua 10
$wrkdir/supuner -e -o $wrkdir/results/luajit-fannkuch-slow $wrkdir/multitime 30 $wrkdir/luajit-2.0/src/luajit fannkuch-redux.lua 11

cd $wrkdir/lua_benchmarks
$wrkdir/supuner -e -o $wrkdir/results/luajit-richards-fast $wrkdir/multitime 30 $wrkdir/luajit-2.0/src/luajit richards_oo_meta.lua 5
$wrkdir/supuner -e -o $wrkdir/results/luajit-richards-slow $wrkdir/multitime 30 $wrkdir/luajit-2.0/src/luajit richards_oo_meta.lua 100
