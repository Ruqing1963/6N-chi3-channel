#!/usr/bin/env sage
# -*- coding: sage -*-
"""
Langlands Plume Well-Log : Level-6 newforms  ----  for SageMath 9.3
(run:  sage Langlands_plume_log.sage)

Target: cusp-form newforms of level Gamma0(6), weights k = 2,4,6. For each newform f and each
prime p on the 6N corridors (3 < p < 5000), record the Hecke eigenvalue a_p(f).

CSO NOTES (read before running):
  * Level 6 = 2*3 governs the BAD primes p=2,3. For every prime p coprime to 6 (i.e. every
    6N+-1 prime), a_p is the GOOD-reduction Hecke eigenvalue; the "level-6 gene" imposes no
    p-mod-3-dependent structure on these a_p. The prediction is therefore null: the 6N wing
    will not split a_p. This run is an adversarial test of the chi(3)-channel principle with
    the most favourable possible object (one that natively carries 6).
  * DIMENSION WARNING: S_2(Gamma0(6)) has dimension 0 (genus of X_0(6) is 0) -> there are NO
    weight-2 newforms at level 6. The script handles an empty Newforms list gracefully and
    records which (k, form_index) actually exist. Weights 4 and 6 do contain newforms.
  * a_p is rational here (these newform spaces are 1-dimensional Galois orbits with rational
    eigenvalues), so a_p is written as an integer/rational directly.

We also record p % 3 (= the wing) and p % 12 so the analysis can test what a_p REALLY tracks
(positive/negative controls), exactly as in the Galois-fluid addendum.

Checkpointing: append row-by-row, flush each; resumable by (Weight_k, Form_Index, Prime_p).
"""

import csv, os, time
from sage.all import Newforms, Gamma0, primes

def wing_of(p):
    return +1 if p % 6 == 1 else -1

def load_done(path):
    done = set()
    if os.path.exists(path):
        with open(path, newline='') as f:
            for row in csv.DictReader(f):
                try:
                    done.add((int(row['Weight_k']), int(row['Form_Index']), int(row['Prime_p'])))
                except Exception:
                    pass
    return done

def main():
    # -------- tunables --------
    P_MAX = 5000
    WEIGHTS = [2, 4, 6]
    OUT = 'Langlands_Plume_Log.csv'
    # --------------------------

    header = ['Prime_p', '6N_Wing', 'Mod_12', 'Weight_k', 'Form_Index', 'a_p']
    done = load_done(OUT)
    new = not os.path.exists(OUT)
    fout = open(OUT, 'a', newline=''); w = csv.writer(fout)
    if new:
        w.writerow(header); fout.flush()

    ps = [p for p in primes(5, P_MAX)]
    print("Target primes (3 < p < %d): %d" % (P_MAX, len(ps)))

    for k in WEIGHTS:
        try:
            forms = Newforms(Gamma0(6), k, names='a')
        except Exception as e:
            print("  weight %d: Newforms() raised %r -- skipping" % (k, e))
            continue
        print("  weight %d: %d newform(s) at level 6" % (k, len(forms)))
        if len(forms) == 0:
            print("    (expected for k=2: S_2(Gamma0(6)) is 0-dimensional)")
            continue
        for idx, f in enumerate(forms):
            t0 = time.time(); n = 0
            for p in ps:
                if (k, idx, p) in done:
                    continue
                try:
                    ap = f[p]                       # p-th Hecke eigenvalue (p coprime to level)
                    # eigenvalues are rational here; coerce to int when integral
                    try:
                        ap_out = int(ap)
                    except Exception:
                        ap_out = str(ap)
                except Exception:
                    ap_out = ''
                w.writerow([p, wing_of(p), p % 12, k, idx, ap_out])
                fout.flush(); n += 1
            print("    form (k=%d, idx=%d): wrote %d rows, %.1fs" % (k, idx, n, time.time()-t0))
    fout.close()
    print("DONE. wrote/updated %s" % OUT)

if __name__ == '__main__':
    main()
