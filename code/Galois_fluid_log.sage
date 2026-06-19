#!/usr/bin/env sage
# -*- coding: sage -*-
"""
Galois Fluid Isotopes Well-Log  ----  for SageMath 9.3   (run:  sage Galois_fluid_log.sage)

Target: for each prime p on the 6N corridors (p>3), the elliptic curve E_p : y^2 = x^3 - p,
and its Frobenius traces a_7(E_p), a_13(E_p) (the "isotopes" extracted at temperatures l=7,13).

WHAT THE ANALYSIS WILL ASK (and the CSO's prediction):
  a_l(E_p) is the l-th local coefficient of the L-function of E_p. By the chi(3)-channel
  result (companion note, Zenodo 20761924), the 6N wing (= p mod 3) can reach any
  L-function-derived quantity ONLY through the q=3 Euler factor chi_p(3). The isotopes
  a_7 and a_13 live in the q=7 and q=13 factors, so the wing should have NO effect on them.
  More directly: a_l(E_p) is governed by p mod l (the reduction of E_p mod l), and by CRT
  p mod l is independent of p mod 3 = the wing. So the wing-vs-a_l distributions should be
  indistinguishable -- this probe re-confirms CRT independence rather than piercing it.

  To make the test honest we ALSO record Mod_7 and Mod_13. The downstream analysis uses
  them as a POSITIVE CONTROL: a_l MUST depend strongly on p mod l (its real controller).
  If that positive control fires while the wing does not, the instrument is proven working
  and the wing-null is meaningful (not just "a_l is all noise").

Fields: Prime_p, 6N_Wing, Mod_24, Mod_7, Mod_13, a_7, a_13.
  (a_l via E.ap(l); instant. Curve has good reduction at 7,13 for all p coprime to them;
   a_l is still defined and recorded otherwise -- E_p has bad reduction only at 2,3,p.)

Checkpointing: append row-by-row, flush each, skip primes already present.
"""

import csv, os, time
from sage.all import primes, EllipticCurve

def wing_of(p):
    return +1 if p % 6 == 1 else -1

def load_done(path):
    done = set()
    if os.path.exists(path):
        with open(path, newline='') as f:
            for row in csv.DictReader(f):
                try: done.add(int(row['Prime_p']))
                except Exception: pass
    return done

def main():
    # -------- tunables --------
    P_MAX = 20000
    OUT = 'Galois_Fluid_Isotopes_Log.csv'
    LS = [7, 13]
    # --------------------------

    header = ['Prime_p','6N_Wing','Mod_24','Mod_7','Mod_13','a_7','a_13']
    done = load_done(OUT)
    new = not os.path.exists(OUT)
    fout = open(OUT, 'a', newline=''); w = csv.writer(fout)
    if new:
        w.writerow(header); fout.flush()

    ps = [p for p in primes(5, P_MAX)]
    print("Total target primes (3 < p < %d): %d ; already done: %d" % (P_MAX, len(ps), len(done)))
    t0 = time.time(); n = 0
    for p in ps:
        if p in done: continue
        E = EllipticCurve([0, 0, 0, 0, -p])     # y^2 = x^3 - p
        # a_l: trace of Frobenius at l. E.ap(l) works at good primes; E_p has bad reduction
        # only at 2,3,p, so for l in {7,13} (p != 7,13 handled below) ap is the good-reduction trace.
        try:
            a7 = int(E.ap(7))
        except Exception:
            a7 = ''      # only if p == 7 (bad reduction); recorded blank
        try:
            a13 = int(E.ap(13))
        except Exception:
            a13 = ''     # only if p == 13
        w.writerow([p, wing_of(p), p % 24, p % 7, p % 13, a7, a13])
        fout.flush()
        n += 1
        if n % 500 == 0:
            print("  ...%d done (p=%d), %.1fs, a7=%s a13=%s" % (n, p, time.time()-t0, a7, a13))
    fout.close()
    print("DONE. wrote/updated %s" % OUT)

if __name__ == '__main__':
    main()
