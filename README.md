# 6N-chi3-channel

**The χ(3) Channel: How the 6N Wing Enters L-Function-Derived Invariants, and Where It Stops**

R. Chen · GUT Geoservice Inc., Montréal · *6N Arithmetic Geodynamics* series · Methodological Note · 2026

---

## What this is

A **methodological note**, not a claim of new arithmetic. Across three independent "theatres" it asks whether the 6N wing of a prime *p* (its class mod 6, equivalently *p* mod 3) controls a high-dimensional invariant built from *p*:

| Theatre | Object | Observable |
|---|---|---|
| 0 | elliptic curve E_p : y² = x³ − p | Mordell–Weil rank |
| I | imaginary quadratic field Q(√−p) | class number h(−p) |
| II | Dirichlet L-function L(s, χ₋ₚ) | first zero height γ₁ |

## The result

In Theatres I and II a **large** wing signal appears (Cohen's *d* = −1.36 and −0.83) that **survives the controls one would normally trust** — scale normalisation (√p, log p) and genus stratification (mod 8). Yet in every theatre the signal collapses to zero once one specific known quantity is removed:

| Theatre | raw \|d\| | scale-norm. | within genus | after known channel |
|---|---|---|---|---|
| 0 — rank E_p | 0.022 | — | — | **0.022** (root number) |
| I — h(−p) | 0.998 | 1.363 | 2.0–2.3 | **0.005** (q=3 Euler factor) |
| II — γ₁ | 0.656 | 0.829 | 0.8–1.4 | **0.000** (χ(3) split) |

**The χ(3)-channel principle.** For primes *p* > 3 the wing partition **is identically** the χ₋ₚ(3) split (verified: 611/611 right ↔ χ(3)=−1, 616/616 left ↔ χ(3)=+1). The mod-3 information of *p* can enter any L-function-derived invariant only through the single local factor χ_p(3); once it is controlled, the wing is noise. The reason is structural: *p* mod 3 has exactly one home in the analytic theory — the value of the mod-3 quadratic character — so any L-function attached to *p* carries it solely in its q=3 Euler factor.

This refines the "CRT information barrier" of the companion note (`6N-crt-barrier`): there the wing was absorbed by a finer congruence; here we name it exactly (the q=3 factor) and explain why it must be the only one.

**The cautionary core:** the discipline that matters is not *"did the signal survive the controls"* but *"what exact known quantity could produce it"* — pursued until the signal is explained or genuinely cannot be. In two theatres a large signal survived the standard controls and dissolved only under mechanism analysis.

## Repository layout

```
6N-chi3-channel/
├── paper/
│   ├── 6N_chi3_Channel_ThreeTheatres.pdf   ← read this first
│   ├── 6N_chi3_Channel_ThreeTheatres.docx
│   └── 6N_chi3_Channel_ThreeTheatres.tex   ← LaTeX source
├── code/
│   ├── Ep_rank.sage                  ← Theatre 0: certified true-rank well-log (SageMath)
│   ├── Ep_three_layer_analysis.py    ← Theatre 0: three-layer analysis (Python)
│   ├── ClassNumber_log.sage          ← Theatre I: class-number well-log (SageMath)
│   ├── Lzero_calibration.sage        ← Theatre II: zero-API calibration (run FIRST)
│   ├── Lzero_log.sage                ← Theatre II: first-zero well-log (PARI lfunzeros)
│   ├── Lzero_analysis.py             ← Theatre II: γ₁ vs wing / χ(3) analysis (Python)
│   └── make_unified_figs.py          ← figures (Python)
├── data/
│   ├── Ep_Rank_Log.csv               ← 1227 curves
│   ├── ClassNumber_Log.csv           ← 5131 primes
│   └── L_Function_Zeros_Log.csv      ← 1227 primes
├── figures/
│   ├── fig_three_theatres.{pdf,png}
│   └── fig_chi3_collinear.{pdf,png}
├── README.md
├── LICENSE
└── CITATION.cff
```

## Running the code

> **Important:** the `.sage` scripts require **SageMath** (run `sage <file>.sage`); they will **not** run under plain Python. The `.py` scripts are pure Python (numpy/matplotlib).

**Theatre II requires a calibration step first** — this repository's history is itself a lesson:
the batch zero-script first failed silently (the `Lfunction_from_character` API is absent in
SageMath 9.3), producing an all-`error` CSV. Run the calibration to confirm the working zero API
(PARI `lfunzeros`) before the batch:

```bash
sage code/Lzero_calibration.sage     # confirms which zero API works
sage code/Lzero_log.sage             # then the batch (delete any prior all-error CSV first)
python3 code/Lzero_analysis.py       # analysis

sage code/ClassNumber_log.sage       # Theatre I
sage code/Ep_rank.sage               # Theatre 0 (see 6N-crt-barrier for full treatment)

python3 code/make_unified_figs.py    # figures
```

## Data dictionaries

**`L_Function_Zeros_Log.csv`** — `Prime_p, 6N_Wing, Mod_24, Disc, Conductor, L_Function_Type, Gamma_1_Height, gamma1_x_logp, Computation_Status`. Use `gamma1_x_logp` (= γ₁·log p) as the scale-normalised observable.

**`ClassNumber_Log.csv`** — `Prime_p, 6N_Wing, Mod_4, Mod_8, Mod_24, Disc, Class_Number_h, h_over_sqrt_p`. Use `h_over_sqrt_p` (= h/√p) as the scale-normalised observable.

**`Ep_Rank_Log.csv`** — `Prime_p, 6N_Wing, Mod_24, Root_Number, True_Rank, Rank_Lo, Rank_Hi, Computation_Status`. Use only `certified` rows.

## Honesty statement

This note reports negative results whose cause is known structure (a single Euler factor). It claims no new theorem and no predictive power over primes. In two theatres a large signal survived the standard controls; it was retained as a finding only until its mechanism was identified, at which point it was reported as explained. External references were checked against primary bibliographic sources.

## License

MIT — see [LICENSE](LICENSE).
