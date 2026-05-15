#!/bin/bash

# Usage:
# ./401k_calculator.sh <YTD_401k_pretax> <remaining_paychecks> <YTD_megabackdoor> <paycheck_amount>
# Example:
# ./401k_calculator.sh 10000 10 5000 5000

FEDERAL_PRETAX_LIMIT=24500
FEDERAL_OVERALL_LIMIT=72000
EMPLOYER_MATCH_RATE=0.5

YTD_PRETAX=$1
REMAINING_PAYCHECKS=$2
YTD_MEGA=$3
PAYCHECK_AMOUNT=$4

if [ -z "$YTD_PRETAX" ] || [ -z "$REMAINING_PAYCHECKS" ] || [ -z "$YTD_MEGA" ] || [ -z "$PAYCHECK_AMOUNT" ]; then
    echo "Usage: $0 <YTD_401k_pretax> <remaining_paychecks> <YTD_megabackdoor> <paycheck_amount>"
    exit 1
fi

# Calculate employer match so far
EMPLOYER_MATCH_SO_FAR=$(echo "$YTD_PRETAX * $EMPLOYER_MATCH_RATE" | bc)

# Calculate contribution room left for pretax
PRETAX_LEFT=$(echo "$FEDERAL_PRETAX_LIMIT - $YTD_PRETAX" | bc)
if (( $(echo "$PRETAX_LEFT < 0" | bc) )); then PRETAX_LEFT=0; fi

# Calculate total contributed so far
TOTAL_SO_FAR=$(echo "$YTD_PRETAX + $EMPLOYER_MATCH_SO_FAR + $YTD_MEGA" | bc)

# Calculate overall room left
OVERALL_LEFT=$(echo "$FEDERAL_OVERALL_LIMIT - $TOTAL_SO_FAR" | bc)
if (( $(echo "$OVERALL_LEFT < 0" | bc) )); then OVERALL_LEFT=0; fi

# Calculate employer match for the rest of the year if you max out pretax
EMPLOYER_MATCH_POTENTIAL=$(echo "$PRETAX_LEFT * $EMPLOYER_MATCH_RATE" | bc)

# Calculate maximum pretax per paycheck
if (( "$REMAINING_PAYCHECKS" == 0 )); then
    PRETAX_PER_PAYCHECK=0
else
    PRETAX_PER_PAYCHECK=$(echo "$PRETAX_LEFT / $REMAINING_PAYCHECKS" | bc)
fi

# Calculate maximum after-tax (mega backdoor Roth) contribution per paycheck
AFTER_TAX_LEFT=$(echo "$OVERALL_LEFT - $PRETAX_LEFT - $EMPLOYER_MATCH_POTENTIAL" | bc)
if (( "$REMAINING_PAYCHECKS" == 0 )); then
    MEGA_PER_PAYCHECK=0
else
    MEGA_PER_PAYCHECK=$(echo "$AFTER_TAX_LEFT / $REMAINING_PAYCHECKS" | bc)
fi
if (( $(echo "$MEGA_PER_PAYCHECK < 0" | bc) )); then MEGA_PER_PAYCHECK=0; fi

# Calculate percentage of paycheck for each
PRETAX_PERCENT=$(echo "scale=2; ($PRETAX_PER_PAYCHECK / $PAYCHECK_AMOUNT) * 100" | bc)
MEGA_PERCENT=$(echo "scale=2; ($MEGA_PER_PAYCHECK / $PAYCHECK_AMOUNT) * 100" | bc)

echo "---- 401k Contribution Calculator ----"
echo "Remaining Pre-tax 401k Contribution Room: \$${PRETAX_LEFT}"
echo "Remaining Mega Backdoor Roth Contribution Room: \$${AFTER_TAX_LEFT}"
echo "Employer Match Received So Far: \$${EMPLOYER_MATCH_SO_FAR}"
echo "Employer Match Remaining Potential This Year: \$${EMPLOYER_MATCH_POTENTIAL}"
echo
echo "Max Pre-tax 401k per paycheck: \$${PRETAX_PER_PAYCHECK} (${PRETAX_PERCENT}% of your paycheck)"
echo "Max Mega Backdoor Roth per paycheck: \$${MEGA_PER_PAYCHECK} (${MEGA_PERCENT}% of your paycheck)"
echo
echo "To hit the federal limits and maximize employer match, you would contribute:"
echo "- Up to ${PRETAX_PERCENT}% pre-tax 401k per paycheck"
echo "- Up to ${MEGA_PERCENT}% after-tax (mega backdoor) per paycheck"
