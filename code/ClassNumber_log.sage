#!/usr/bin/env sage
# -*- coding: sage -*-
"""
Class-Number Well-Log  ----  for SageMath 9.3   (run:  sage ClassNumber_log.sage)

Target: imaginary quadratic field K = Q(sqrt(-p)) for primes p on the 6N corridors (p>3).
Record the class number h(-p) and the congruence "noise" labels needed to strip the
known structure BEFORE any 6N-wing claim is made.

WHY THE EXTRA COLUMN (read before running):
  h(-p) is governed by the Dirichlet class-number formula, h ~ (sqrt(p)/pi) * L(1, chi_{-p}).
  Two known confounders must be stripped in the downstream three-layer analysis:
    (1) PARITY / 2-part: fixed by genus theory via p mod 8 (and p mod 4, which also
        decides whether the fundamental discriminant is -p or -4p). -> columns Mod_4/Mod_8.
    (2) SCALE: h grows like sqrt(p). Comparing raw h between wings mostly measures the
        sqrt(p) size of the primes, NOT any arithmetic asymmetry. -> column h_over_sqrt_p
        = h / sqrt(p), i.e. h normalised to the L(1,chi) scale. THIS is the clean observable.
  Direct left-vs-right comparison of raw h WILL show a large spurious gap from sqrt(p).
  The honest probe asks whether h/sqrt(p) (the L(1,chi) fluctuation) depends on the wing.

Fundamental discriminant convention:
  p == 3 (mod 4):  disc = -p     (so K = Q(sqrt(-p)), disc squarefree-odd case)
  p == 1 (mod 4):  disc = -4p
  We record Disc so the analysis can stratify on it directly.

Checkpointing: appends row-by-row, flushes each curve, skips primes already in the CSV.
"""

import csv, os, time
from sage.all import primes, QuadraticField, sqrt

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
    P_MAX = 50000          # upper limit on p
    OUT   = 'ClassNumber_Log.csv'
    # --------------------------

    header = ['Prime_p','6N_Wing','Mod_4','Mod_8','Mod_24',
              'Disc','Class_Number_h','h_over_sqrt_p']
    done = load_done(OUT)
    new_file = not os.path.exists(OUT)
    fout = open(OUT, 'a', newline='')
    writer = csv.writer(fout)
    if new_file:
        writer.writerow(header); fout.flush()

    ps = [p for p in primes(5, P_MAX)]      # primes >3 are automatically on 6N+-1
    print("Total target primes (3 < p < %d): %d ; already done: %d"
          % (P_MAX, len(ps), len(done)))

    t0 = time.time(); n_ok = 0
    for p in ps:
        if p in done:
            continue
        K = QuadraticField(-p, 'a')
        h = K.class_number()                 # exact class number, no certainty issues here
        disc = K.discriminant()              # -p if p=3 mod4, -4p if p=1 mod4
        h_norm = float(h) / float(sqrt(p))   # normalise away the sqrt(p) scale
        writer.writerow([p, wing_of(p), p % 4, p % 8, p % 24,
                         int(disc), int(h), '%.6f' % h_norm])
        fout.flush()
        n_ok += 1
        if n_ok % 200 == 0:
            print("  ...%d new done (p=%d), %.1fs elapsed, h=%d"
                  % (n_ok, p, time.time()-t0, h))
    fout.close()
    print("DONE. wrote/updated %s" % OUT)

if __name__ == '__main__':
    main()
