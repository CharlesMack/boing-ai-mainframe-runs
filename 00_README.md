# Caffeine_v1 – First Traceable Research Run
**Boing AI Quantum Research Mainframe v0.9** (conceptual virtual–physical twin)

**Date:** January 11–12, 2026  
**Purpose:** Benchmark high-level correlated electronic structure (gas phase, neutral singlet) as audit-ready example run.  
**Method:** Classical quantum chemistry reference (DLPNO-CCSD(T)/def2-TZVPP//ωB97X-D/def2-TZVP) — future target for hybrid quantum-classical advantage.

**Disclaimer:** Conceptual/simulation-based project. All data and media are illustrative/artistic. Not affiliated with Boeing.

**How to reproduce**  
1. Run `inputs/opt_freq.inp` → `outputs/opt_freq.out` (confirm no imaginary freqs; collect ZPE/thermals).  
2. Run `inputs/dlpno_singlepoint.inp` on optimized geometry → `outputs/dlpno.out`.  
3. `./scripts/grep_orca.sh outputs/opt_freq.out outputs/dlpno.out > analysis/summary.csv`  
4. `./scripts/make_manifest.sh > outputs/manifest.sha256`

See `analysis/notes.md` and `provenance/run_provenance.json` for full details.

