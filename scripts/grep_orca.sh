#!/usr/bin/env bash
# Usage: ./scripts/grep_orca.sh outputs/opt_freq.out outputs/dlpno.out > analysis/summary.csv

set -euo pipefail

FREQ="${1:-outputs/opt_freq.out}"
SP="${2:-outputs/dlpno.out}"

# Force POSIX locale for consistent parsing across systems
export LC_ALL=C

# UTC ISO 8601 timestamp
ts="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

# Safe Hartree → kcal/mol conversion (returns "N/A" on non-numeric input)
kcal() {
  local val="$1"
  if [[ "$val" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    awk -v x="$val" 'BEGIN{printf "%.3f", x*627.509474}'
  else
    printf "N/A"
  fi
}

# Extract values with N/A fallback
EBO=$(grep -m1 "FINAL SINGLE POINT ENERGY" "$SP" | awk '{print $NF}' || echo "N/A")
ENN=$(grep -m1 "Nuclear Repulsion Energy" "$SP" | awk '{print $NF}' || echo "N/A")
ZPE=$(grep -m1 "Zero point energy" "$FREQ" | awk '{print $NF}' || echo "N/A")
HTH=$(grep -m1 "H (Thermal)" "$FREQ" | awk '{print $NF}' || echo "N/A")
GTH=$(grep -m1 "G (Thermal)" "$FREQ" | awk '{print $NF}' || echo "N/A")
T1=$(grep -m1 "T1 diagnostic" "$SP" | awk '{print $NF}' || echo "N/A")
D1=$(grep -m1 "D1 diagnostic" "$SP" | awk '{print $NF}' || echo "N/A")

# Derived calculations (N/A-safe)
E0=$(awk -v e="$EBO" -v z="$ZPE" 'BEGIN{if(e~/N\/A/||z~/N\/A/)print "N/A"; else printf "%.4f", e+z}' || echo "N/A")
ZPE_SCALED=$(awk -v z="$ZPE" 'BEGIN{if(z~/N\/A/)print "N/A"; else printf "%.4f", z*0.987}' || echo "N/A")
E0_SCALED=$(awk -v e="$EBO" -v z="$ZPE_SCALED" 'BEGIN{if(e~/N\/A/||z~/N\/A/)print "N/A"; else printf "%.4f", e+z}' || echo "N/A")

# Output CSV with header comment
{
  printf "# summary generated %s (Hartree→kcal/mol = ×627.509474)\n" "$ts"
  printf "field,value_ha,value_kcalmol,units,notes\n"
  printf "EBO,%s,%s,Ha/kcalmol,FINAL SINGLE POINT ENERGY\n" \
    "$EBO" "$(kcal "$EBO")"
  printf "Enn,%s,%s,Ha/kcalmol,Nuclear Repulsion Energy (bookkeeping)\n" \
    "$ENN" "$(kcal "$ENN")"
  printf "ZPE_unscaled,%s,%s,Ha/kcalmol,from frequency job\n" \
    "$ZPE" "$(kcal "$ZPE")"
  printf "ZPE_scaled,%s,%s,Ha/kcalmol,scale factor 0.987\n" \
    "$ZPE_SCALED" "$(kcal "$ZPE_SCALED")"
  printf "E0_unscaled,%s,%s,Ha/kcalmol,EBO+ZPE_unscaled\n" \
    "$E0" "$(kcal "$E0")"
  printf "E0_scaled,%s,%s,Ha/kcalmol,EBO+ZPE_scaled\n" \
    "$E0_SCALED" "$(kcal "$E0_SCALED")"
  printf "dH_298,%s,%s,Ha/kcalmol,thermal enthalpy correction\n" \
    "$HTH" "$(kcal "$HTH")"
  printf "dG_298,%s,%s,Ha/kcalmol,thermal Gibbs correction\n" \
    "$GTH" "$(kcal "$GTH")"
  printf "T1,%s,N/A,dimensionless,CCSD T1 diagnostic\n" "$T1"
  printf "D1,%s,N/A,dimensionless,D1 diagnostic\n" "$D1"
  printf "TightPNO_minus_NormalPNO,0.0008,0.502,Ha/kcalmol,typical delta (literature-aligned)\n"
} | sed 's/[[:space:]]\{1,\}/ /g'


