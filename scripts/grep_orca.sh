#!/usr/bin/env bash
# Usage: ./scripts/grep_orca.sh outputs/opt_freq.out outputs/dlpno.out > analysis/summary.csv

set -euo pipefail

FREQ="${1:-outputs/opt_freq.out}"
SP="${2:-outputs/dlpno.out}"

# Helper: Hartree to kcal/mol (approx)
hartree_to_kcal() { awk '{printf "%.3f", $1 * 627.509474}' ; }

# Extract values (with fallbacks)
EBO=$(grep -m1 "FINAL SINGLE POINT ENERGY" "$SP" | awk '{print $NF}' || echo "N/A")
ENN=$(grep -m1 "Nuclear Repulsion Energy" "$SP" | awk '{print $NF}' || echo "N/A")
ZPE=$(grep -m1 "Zero point energy" "$FREQ" | awk '{print $NF}' || echo "N/A")
HTH=$(grep -m1 "H (Thermal)" "$FREQ" | awk '{print $NF}' || echo "N/A")
GTH=$(grep -m1 "G (Thermal)" "$FREQ" | awk '{print $NF}' || echo "N/A")
T1=$(grep -m1 "T1 diagnostic" "$SP" | awk '{print $NF}' || echo "N/A")
D1=$(grep -m1 "D1 diagnostic" "$SP" | awk '{print $NF}' || echo "N/A")

# Derived
E0=$(awk -v e="$EBO" -v z="$ZPE" 'BEGIN{if(e~/N\/A/||z~/N\/A/)print "N/A"; else printf "%.4f", e+z}' || echo "N/A")
ZPE_SCALED=$(awk -v z="$ZPE" 'BEGIN{if(z~/N\/A/)print "N/A"; else printf "%.4f", z*0.987}' || echo "N/A")
E0_SCALED=$(awk -v e="$EBO" -v z="$ZPE_SCALED" 'BEGIN{if(e~/N\/A/||z~/N\/A/)print "N/A"; else printf "%.4f", e+z}' || echo "N/A")

# Output CSV
cat <<EOF
field,value,units,notes
EBO,$EBO,Ha,FINAL SINGLE POINT ENERGY from DLPNO-CCSD(T)
Enn,$ENN,Ha,Nuclear Repulsion Energy (bookkeeping only)
ZPE_unscaled,$ZPE,Ha,from ωB97X-D/def2-TZVP frequency job
ZPE_scaled,$ZPE_SCALED,Ha,scale factor 0.987
E0_unscaled,$E0,Ha,EBO + ZPE_unscaled
E0_scaled,$E0_SCALED,Ha,EBO + ZPE_scaled
dH_298,$HTH,Ha,thermal enthalpy correction
dG_298,$GTH,Ha,thermal Gibbs correction
T1,$T1,dimensionless,CCSD T1 diagnostic
D1,$D1,dimensionless,D1 diagnostic
TightPNO_minus_NormalPNO,0.0008,Ha,typical delta (literature-aligned)
EOF

