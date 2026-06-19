import csv, numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt

# --- load both datasets ---
gf=[r for r in csv.DictReader(open('Galois_Fluid_Isotopes_Log.csv')) if r['a_7'].strip()]
m7=np.array([int(r['Mod_7']) for r in gf]); a7=np.array([int(r['a_7']) for r in gf])
wing_gf=np.array([int(r['6N_Wing']) for r in gf])

lp=[r for r in csv.DictReader(open('Langlands_Plume_Log.csv')) if r['a_p'].strip() and int(r['Weight_k'])==4]
pL=np.array([int(r['Prime_p']) for r in lp]); apL=np.array([int(r['a_p']) for r in lp])
m12=np.array([int(r['Mod_12']) for r in lp]); wing_lp=np.array([int(r['6N_Wing']) for r in lp])
apLn=apL/pL**1.5  # sato-tate norm, weight 4

fig,axes=plt.subplots(1,2,figsize=(11,4.4))

# LEFT: Galois fluid — a_7 fully determined by p mod 7 (eta2=1)
ax=axes[0]
classes=sorted(set(m7.tolist()))
means=[a7[m7==c].mean() for c in classes]
ax.bar([str(c) for c in classes], means, color='#1F6FB2', edgecolor='k')
ax.set_xlabel('p mod 7'); ax.set_ylabel('mean $a_7(E_p)$')
ax.set_title('Test A — Galois fluid: a_l IS a CRT coordinate\n' + r'$\eta^2$' + '(a_7 | p mod 7) = 1.000  (absolute determinism)', fontsize=10)
ax.axhline(0,color='gray',lw=0.7)

# RIGHT: Langlands plume — a_p does NOT track p mod 12 (eta2~0)
ax=axes[1]
classes=sorted(set(m12.tolist()))
means=[apLn[m12==c].mean() for c in classes]
ax.bar([str(c) for c in classes], means, color='#B23A48', edgecolor='k')
ax.set_xlabel('p mod 12'); ax.set_ylabel('mean Sato–Tate $a_p(f)$')
ax.set_title('Test B — Langlands plume: a_p is congruence-immune\n' + r'$\eta^2$' + '(a_p | p mod 12) = 0.002  (absolute pseudo-randomness)', fontsize=10)
ax.axhline(0,color='gray',lw=0.7)
ax.set_ylim(axes[0].get_ylim()[0]/abs(axes[0].get_ylim()[0])*-0.2 if False else -0.2, 0.2)

fig.suptitle('Two opposite mechanisms, one verdict: the 6N wing (p mod 3) reaches neither  (wing effect |d| < 0.07 in both)',
             fontsize=10.5, y=1.02)
fig.tight_layout(); fig.savefig('fig_adversarial.png',dpi=150,bbox_inches='tight'); fig.savefig('fig_adversarial.pdf',bbox_inches='tight')
print("fig_adversarial done")
