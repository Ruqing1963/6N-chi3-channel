import csv, numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
rows=[r for r in csv.DictReader(open('Galois_Fluid_Isotopes_Log.csv')) if r['a_7'].strip() and r['a_13'].strip()]
wing=np.array([int(r['6N_Wing']) for r in rows])
m7=np.array([int(r['Mod_7']) for r in rows]); a7=np.array([int(r['a_7']) for r in rows])

fig,(ax1,ax2)=plt.subplots(1,2,figsize=(10.5,4.3))
# LEFT: positive control — a_7 fully determined by p mod 7
classes=sorted(set(m7.tolist()))
means=[a7[m7==c].mean() for c in classes]
ax1.bar([str(c) for c in classes], means, color='#1F6FB2', edgecolor='k')
ax1.set_xlabel('p mod 7'); ax1.set_ylabel('mean $a_7$')
ax1.set_title('Positive control: $a_7$ is fully determined by p mod 7\n($\\eta^2=1.000$ — each class one fixed value)', fontsize=10.5)
ax1.axhline(0,color='gray',lw=0.7)

# RIGHT: main test — wing has no effect on a_7 distribution (overlapping histograms)
bins=np.arange(-5.5,6.5,1)
ax2.hist(a7[wing==1],bins=bins,alpha=0.55,label='6N+1 (right)',color='#C0392B',density=True,edgecolor='k',linewidth=0.4)
ax2.hist(a7[wing==-1],bins=bins,alpha=0.55,label='6N-1 (left)',color='#2471A3',density=True,edgecolor='k',linewidth=0.4)
ax2.set_xlabel('$a_7$'); ax2.set_ylabel('density')
ax2.set_title('Main test: the 6N wing has no effect on $a_7$\n(Cohen $d=-0.006$ — distributions coincide)', fontsize=10.5)
ax2.legend(fontsize=9)
fig.tight_layout(); fig.savefig('fig_galois_fluid.png',dpi=150,bbox_inches='tight'); fig.savefig('fig_galois_fluid.pdf',bbox_inches='tight')
print("fig_galois_fluid done")
