# The Computer Language Benchmarks Game
# http://shootout.alioth.debian.org/
#
# contributed by Tupteq

import sys

def main():
    cout = sys.stdout.write
    size = int(sys.argv[1])
    xr_size = xrange(size)
    xr_iter = xrange(50)
    bit = 128
    byte_acc = 0
    buf_size = 8192
    buf = [None] * buf_size

    cout("P4\n%d %d\n" % (size, size))

    size = float(size)
    for y in xr_size:
        buf_i = 0
        fy = 2j * y / size - 1j
        for x in xr_size:
            z = 0j
            c = 2. * x / size - 1.5 + fy

            for i in xr_iter:
                z = z * z + c
                if abs(z) >= 2.0:
                    break
            else:
                byte_acc += bit

            if bit > 1:
                bit >>= 1
            else:
                buf[buf_i] = chr(byte_acc)
                buf_i += 1
                bit = 128
                byte_acc = 0

        if bit != 128:
            buf[buf_i] = chr(byte_acc)
            buf_i += 1
            bit = 128
            byte_acc = 0
        
        cout("".join(buf[:buf_i]))

main()
