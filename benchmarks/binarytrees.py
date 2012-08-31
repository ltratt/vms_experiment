# The Computer Language Benchmarks Game
# http://shootout.alioth.debian.org/
#
# contributed by Antoine Pitrou
# modified by Dominique Wahli
# modified by Heinrich Acker

import sys

class Tree(object):
    __slots__ = ["item", "left", "right"] # for CPython
    def __init__(self, item, left, right):
        self.item = item
        self.left = left
        self.right = right

def make_tree(item, depth):
    if depth <= 0: return item
    item2 = item + item
    depth -= 1
    return Tree(item, make_tree(item2 - 1, depth), make_tree(item2, depth))

def check_tree(tree):
    if not isinstance(tree, Tree): return tree
    return tree.item + check_tree(tree.left) - check_tree(tree.right)

def main():
    min_depth = 4
    max_depth = max(min_depth + 2, int(sys.argv[1]))
    stretch_depth = max_depth + 1

    print "stretch tree of depth %d\t check:" % stretch_depth, check_tree(make_tree(0, stretch_depth))

    long_lived_tree = make_tree(0, max_depth)

    iterations = 2**max_depth
    for depth in xrange(min_depth, stretch_depth, 2):

        check = 0
        for i in xrange(1, iterations + 1):
            check += check_tree(make_tree(i, depth)) + check_tree(make_tree(-i, depth))

        print "%d\t trees of depth %d\t check:" % (iterations * 2, depth), check
        iterations /= 4

    print "long lived tree of depth %d\t check:" % max_depth, check_tree(long_lived_tree)

main()
