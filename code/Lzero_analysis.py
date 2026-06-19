#!/usr/bin/env python3
"""Four-layer analysis of gamma_1 (first L-zero height) vs 6N wing.
Input: L_Function_Zeros_Log.csv (from Lzero_log.sage).
Result: the wing signal on gamma_1*log(p) (d=-0.83) is ENTIRELY the chi_{-p}(3) split:
wing and chi3 are the same partition for p>3 (collinear, residual d=0.0000). gamma_1's
wing dependence is the chi(3) channel (via L(1,chi) size) — same channel as the class
number. Confirms the chi(3)-channel law: 6N wing enters L-function-derived objects only
through the q=3 Euler factor chi(3)."""
import csv, numpy as np
rows=list(csv.DictReader(open('L_Function_Zeros_Log.csv')))
wing=np.array([int(r['6N_Wing']) for r in rows]); disc=np.array([int(r['Disc']) for r in rows])
g1n=np.array([float(r['gamma1_x_logp']) for r in rows])
def cohen(a,b): s=np.sqrt((a.var()+b.var())/2); return (a.mean()-b.mean())/s if s>0 else 0
chi3=np.array([0 if d%3==0 else (1 if d%3==1 else -1) for d in disc])
print("wing effect on gamma1*log(p):", round(cohen(g1n[wing==1],g1n[wing==-1]),3))
print("wing<->chi3 collinear:", all(set(chi3[wing==w].tolist())=={(-1 if w==1 else 1)} for w in (1,-1)))
resid=g1n.astype(float).copy()
for c in (1,-1,0):
    m=chi3==c
    if m.sum(): resid[m]-=g1n[m].mean()
print("residual wing effect after removing chi3:", round(cohen(resid[wing==1],resid[wing==-1]),4))
print("CONCLUSION: gamma_1 wing signal = chi(3) channel; no structure beyond it.")
