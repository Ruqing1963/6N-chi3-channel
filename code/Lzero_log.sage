#!/usr/bin/env sage
# -*- coding: sage -*-
"""
L-function First-Zero Well-Log  ----  for SageMath 9.3  (run:  sage Lzero_log.sage)

Target: for each prime p on the 6N corridors (p>3), take the Dirichlet L-function
L(s, chi_d) of the quadratic character chi_d of the imaginary quadratic field
Q(sqrt(-p)) (modulus = |fundamental discriminant| d, with d = -p or -4p), and record
the height gamma_1 of its first nontrivial zero on the critical line.

WHY DIRICHLET (CSO decision):
  Dirichlet L-functions of quadratic characters have small conductor (~p), so lcalc's
  contour computation of the lowest zero is fast and robust. Elliptic-curve L-functions
  (conductor ~p^2) are far heavier and time out often; and the E_p theatre is already done.

WHY THE EXTRA COLUMN gamma1_x_logp (read before running):
  By the Riemann-von Mangoldt density, zeros near height T have spacing ~ 2*pi / log(N*T),
  with conductor N ~ p. So the FIRST zero gamma_1 falls roughly like 1/log(p): it is
  dominated by the log(p) SCALE of the conductor, NOT by any 6N asymmetry. Comparing raw
  gamma_1 between wings mostly measures log(p). The scale-normalised observable is
      gamma1_x_logp = gamma_1 * log(p),
  which divides out the leading conductor-density trend. THIS is the clean quantity for the
  three-layer analysis. (Direct raw gamma_1 comparison WILL show a spurious wing gap.)

Noise labels for stripping: Mod_24 (carries p mod 4, p mod 8 genus/conductor structure)
and the discriminant d itself (=-p or -4p).

Robustness:
  - per-curve SIGALRM timeout (default 30 s); on blow-up -> status 'timeout', skipped.
  - checkpointing: append row-by-row, flush each, skip primes already in the CSV.
  - lcalc zero extraction via PARI lfunzeros (the method verified by Lzero_calibration.sage
    on this Sage 9.3; the older Lfunction_from_character API is absent here).

IMPORTANT: if a previous run wrote an all-'error' CSV, DELETE that L_Function_Zeros_Log.csv
first — otherwise checkpointing skips every prime as "already done" and the empty rows stay.
"""

import csv, os, signal, time
from sage.all import primes, QuadraticField, kronecker_character, log as Slog

class _Timeout(Exception): pass
def _alarm(signum, frame): raise _Timeout()
signal.signal(signal.SIGALRM, _alarm)

def wing_of(p):
    return +1 if p % 6 == 1 else -1

def first_zero(d, budget):
    """First positive nontrivial zero height of L(s, chi_d) via PARI lfunzeros
       (the method verified working in the calibration). Returns (gamma1_or_None, status)."""
    signal.alarm(int(budget))
    try:
        # PARI: lfuncreate(d) builds the L-function of the quadratic character of
        # fundamental discriminant d; lfunzeros(L, B) returns zero heights up to B.
        from sage.all import pari
        Lobj = pari.lfuncreate(d)
        zeros = pari.lfunzeros(Lobj, 12)      # zeros with height in (0, 12]
        signal.alarm(0)
        zs = [float(z) for z in zeros if float(z) > 1e-6]
        if zs:
            return (min(zs), 'ok')
        # widen once if nothing in (0,12]
        signal.alarm(int(budget))
        zeros = pari.lfunzeros(pari.lfuncreate(d), 30)
        signal.alarm(0)
        zs = [float(z) for z in zeros if float(z) > 1e-6]
        return (min(zs), 'ok') if zs else (None, 'no_zero_found')
    except _Timeout:
        return (None, 'timeout')
    except Exception:
        signal.alarm(0)
        return (None, 'error')
    finally:
        signal.alarm(0)

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
    P_MAX = 10000
    BUDGET = 30           # seconds per L-function
    OUT = 'L_Function_Zeros_Log.csv'
    # --------------------------

    header = ['Prime_p','6N_Wing','Mod_24','Disc','Conductor',
              'L_Function_Type','Gamma_1_Height','gamma1_x_logp','Computation_Status']
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
        K = QuadraticField(-p, 'a')
        d = int(K.discriminant())             # -p (p=3 mod4) or -4p (p=1 mod4)
        g1, status = first_zero(d, BUDGET)
        cond = abs(d)
        gln = '' if g1 is None else '%.6f' % (g1 * float(Slog(p)))
        w.writerow([p, wing_of(p), p % 24, d, cond,
                    'Dirichlet_chi_-p',
                    '' if g1 is None else '%.6f' % g1,
                    gln, status])
        fout.flush()
        n += 1
        if n % 50 == 0:
            print("  ...%d done (p=%d), %.1fs, last gamma1=%s status=%s"
                  % (n, p, time.time()-t0, ('%.4f'%g1 if g1 else 'NA'), status))
    fout.close()
    print("DONE. wrote/updated %s" % OUT)

if __name__ == '__main__':
    main()
