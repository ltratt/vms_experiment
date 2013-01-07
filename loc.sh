#! /bin/sh

if [ ! -f multitime ]; then
    $SHELL ./build.sh || exit $?
fi

wrkdir=`pwd`
dump=`mktemp`

# Converge1

cd $wrkdir/converge1
find . -name "*.[ch]" \
  | grep -vE "err.[ch]|strlcat.[ch]|fgetln.[ch]|strlcpy.[ch]" \
  | grep -v "Modules" \
  | xargs cat > $dump
$wrkdir/srep -m "//.*?$" "" $dump
$wrkdir/srep -m "/\\*.*?\\*/" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump
echo "Converge1 LoC:" `wc -l $dump | cut -d " " -f 1`

# Converge2

cd $wrkdir/converge2
dump=`mktemp`
find . -name "*.py" | grep -v "Modules/" | xargs cat > $dump
$wrkdir/srep -m "#.*?$" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump
echo "Converge2 LoC:" `wc -l $dump | cut -d " " -f 1`

# CPython

cd $wrkdir/cpython
find . -name "*.[ch]" | grep -E "^\./(Include|Python|Objects)" \
  | xargs cat > $dump
$wrkdir/srep -m "//.*?$" "" $dump
$wrkdir/srep -m "/\\*.*?\\*/" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump
echo "CPython LoC:" `wc -l $dump | cut -d " " -f 1`

# JRuby

cd $wrkdir/jruby_src
find . -name "*.java" | grep -E "^\./src/org/jruby" \
  | grep -vE "^\./src/org/jruby/compiler" \
  | grep -vE "^\./src/org/jruby/embed" \
  | grep -vE "^\./src/org/jruby/demo" \
  | grep -vE "^\./src/org/jruby/ext" \
  | grep -vE "^\./src/org/jruby/parser" \
  | grep -vE "^\./src/org/jruby/lexer" \
  | grep -vE "^\./src/org/jruby/management" \
  | grep -vE "^\./src/org/jruby/javasupport" \
  | grep -vE "^\./src/org/jruby/ast" \
  | grep -vE "^\./src/org/jruby/ant" \
  | xargs cat > $dump
$wrkdir/srep -m "//.*?$" "" $dump
$wrkdir/srep -m "/\\*.*?\\*/" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump
echo "JRuby LoC:" `wc -l $dump | cut -d " " -f 1`

# Jython

cd $wrkdir/jython/src
find . -name "*.java" | grep -E "^\./org/python/core" \
  | xargs cat > $dump
$wrkdir/srep -m "//.*?$" "" $dump
$wrkdir/srep -m "/\\*.*?\\*/" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump
echo "Jython LoC:" `wc -l $dump | cut -d " " -f 1`

# Lua

cd $wrkdir/lua/src
find . -name "*.[ch]" | grep -v "luac.c" \
  | xargs cat > $dump
$wrkdir/srep -m "//.*?$" "" $dump
$wrkdir/srep -m "/\\*.*?\\*/" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump
echo "Lua LoC:" `wc -l $dump | cut -d " " -f 1`

# LuaJIT

cd $wrkdir/luajit/src
find . -name "*.[ch]" | grep -v "lib_" | xargs cat > $dump
$wrkdir/srep -m "//.*?$" "" $dump
$wrkdir/srep -m "/\\*.*?\\*/" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump
echo "LuaJIT LoC:" `wc -l $dump | cut -d " " -f 1`

# PyPy

cd $wrkdir/pypy
find . -name "*.py" \
  | grep "\\(interpreter/\\)\\|\\(objspace/std/\\)" \
  | grep -v test \
  | grep -v callbench \
  | grep -v ast\\.py \
  | grep -v tool \
  | grep -v rope \
  | grep -v mapdict\\.py \
  | grep -v celldict\\.py \
  | xargs cat > $dump
$wrkdir/srep -m "#.*?$" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump
echo "PyPy-nonopt LoC:" `wc -l $dump | cut -d " " -f 1`

find . -name "*.py" \
  | grep "\\(mapdict\\.py\\)\\|\\(celldict.py\\)" \
  | xargs cat > $dump
$wrkdir/srep -m "#.*?$" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump

echo "PyPy-opt adds LoC:" `wc -l $dump | cut -d " " -f 1`

# Ruby

cd $wrkdir/ruby
find . -name "*.[ch]" \
  | grep -vE "compile.c|parse.c|reg*.c" \
  | grep -vE "^./doc/" \
  | grep -vE "^./enc/" \
  | grep -vE "^./.?ext/" \
  | grep -vE "^./missing/" \
  | grep -vE "^./symbian/" \
  | grep -vE "^./win32/" \
  | xargs cat > $dump
$wrkdir/srep -m "//.*?$" "" $dump
$wrkdir/srep -m "/\\*.*?\\*/" "" $dump
$wrkdir/srep -m "[ \\t]*$" "" $dump
$wrkdir/srep -m "\\n+" "\n" $dump
echo "Ruby LoC:" `wc -l $dump | cut -d " " -f 1`