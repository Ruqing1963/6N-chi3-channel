#!/usr/bin/env sage
# Minimal calibration: run this FIRST in Sage to confirm the L-function zero API works.
# It tries the methods the main script uses, on one small example (p=5, disc=-20 -> chi mod 20).
# Report which method succeeds; then the batch script will work.

p = 23
K = QuadraticField(-p, 'a')
d = int(K.discriminant())
print("test prime p=%d, discriminant d=%d" % (p, d))

ok = False
# Method A: Lfunction_from_character
try:
    from sage.lfunctions.all import Lfunction_from_character
    chi = kronecker_character(d)
    Lf = Lfunction_from_character(chi)
    zeros = Lf.find_zeros(0, 12, 0.05)
    zeros = [z for z in zeros if z > 1e-6]
    print("Method A (Lfunction_from_character): zeros found =", zeros[:3])
    if zeros: ok = True
except Exception as e:
    print("Method A failed:", repr(e))

# Method B: lcalc interface
if not ok:
    try:
        chi = kronecker_character(d)
        L = lcalc.zeros_of_zeta_function  # placeholder; check lcalc API
        print("Method B: inspect lcalc -", dir(lcalc)[:10])
    except Exception as e:
        print("Method B failed:", repr(e))

# Method C: gp/pari lfun
if not ok:
    try:
        z = gp('lfunzeros(lfuncreate(%d), 12)' % d)
        print("Method C (pari lfunzeros):", z)
        ok = True
    except Exception as e:
        print("Method C failed:", repr(e))

print("CALIBRATION:", "PASS - use the working method above" if ok else "FAILED - report which errors appeared")
