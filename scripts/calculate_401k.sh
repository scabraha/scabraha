MAX_CONTRIBUTION_AMOUNT=23500
remainingMonths=$1
ytdContrib=$2
checkTotal=$3
perentages=(0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23)

echo "| Percentage\t| Total\t\t|"
echo "---------------------------------"
hitLimit=false
for t in ${perentages[@]}; do
  monthlyContribution=$(echo "$checkTotal * $t" | bc -l)
  leftToContribute=$(echo "$monthlyContribution * $remainingMonths" | bc -l)
  total=$(echo "$leftToContribute + $ytdContrib" | bc -l)
  if [ "$hitLimit" = false ] && (( $(echo "$total > $MAX_CONTRIBUTION_AMOUNT" | bc -l) )); then
    echo "---------------------------------"
    hitLimit=true
  fi
  echo "| $t\t\t| $total\t|"
done
