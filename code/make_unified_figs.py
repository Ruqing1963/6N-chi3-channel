import numpy as np, csv
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt

# ---- Figure 1: the three theatres, before vs after stripping the known channel ----
theatres=['E_p rank\n(Theatre 0)','h(-p) class no.\n(Theatre I)','gamma_1 zero\n(Theatre II)']
before=[0.022, 1.363, 0.829]      # |Cohen d| raw-ish (E_p already ~0 even raw; others large after scale-norm)
after =[0.022, 0.005, 0.000]      # |Cohen d| after removing the known channel
# note: E_p was already ~0 even at layer1 (root number confound gave ~0 net); show honestly
x=np.arange(3); w=0.36
fig,ax=plt.subplots(figsize=(8.4,4.6))
b1=ax.bar(x-w/2, before, w, label='before stripping known channel', color='#C0392B', edgecolor='k')
b2=ax.bar(x+w/2, after,  w, label='after stripping (root number / q=3 / chi(3))', color='#27AE60', edgecolor='k')
ax.axhline(0.8, ls='--', color='gray', lw=1, label="large-effect threshold (|d|=0.8)")
ax.set_xticks(x); ax.set_xticklabels(theatres)
ax.set_ylabel("|Cohen's d| : 6N wing effect")
ax.set_title("Across all three theatres, the 6N-wing signal collapses once the\nknown congruence channel is removed")
ax.legend(fontsize=8.5, loc='upper right')
for b,v in zip(b1,before): ax.text(b.get_x()+b.get_width()/2, v+0.02, f'{v:.2f}', ha='center', fontsize=8, fontweight='bold')
for b,v in zip(b2,after):  ax.text(b.get_x()+b.get_width()/2, v+0.02, f'{v:.3f}', ha='center', fontsize=8, fontweight='bold', color='#1E7A3D')
fig.tight_layout(); fig.savefig('fig_three_theatres.png',dpi=150,bbox_inches='tight'); fig.savefig('fig_three_theatres.pdf',bbox_inches='tight')
print("fig_three_theatres done")

# ---- Figure 2: the chi(3) collinearity in Theatre II (gamma_1) ----
rows=list(csv.DictReader(open('L_Function_Zeros_Log.csv')))
wing=np.array([int(r['6N_Wing']) for r in rows]); disc=np.array([int(r['Disc']) for r in rows])
g1n=np.array([float(r['gamma1_x_logp']) for r in rows])
chi3=np.array([0 if d%3==0 else (1 if d%3==1 else -1) for d in disc])
fig,ax=plt.subplots(figsize=(7.6,4.4))
data=[g1n[wing==1], g1n[wing==-1]]
bp=ax.boxplot(data, labels=['6N+1 (right)\nchi(3)=-1','6N-1 (left)\nchi(3)=+1'], patch_artist=True, widths=0.5, showfliers=False)
for patch,c in zip(bp['boxes'],['#C0392B','#2471A3']): patch.set_facecolor(c); patch.set_alpha(0.6)
ax.set_ylabel('gamma_1 * log(p)  (scale-normalised first zero height)')
ax.set_title('Theatre II: the wing split IS the chi(3) split (100% collinear for p>3)\nfirst-zero height is higher on the chi(3)=+1 wing because L(1,chi) is larger there')
ax.text(0.5,0.97,'wing and chi(3) are the same partition — there is no "wing effect" independent of chi(3)',
        transform=ax.transAxes, ha='center', va='top', fontsize=8.5, color='#555', style='italic')
fig.tight_layout(); fig.savefig('fig_chi3_collinear.png',dpi=150,bbox_inches='tight'); fig.savefig('fig_chi3_collinear.pdf',bbox_inches='tight')
print("fig_chi3_collinear done")
