# Takes a mint.com transactions csv and generates a category pivot table to show you your spending for the current month.
# The advatage of using this over Mint's reports are that Mint reports don't show subcategories or allow you to filter out categories.
# Optional parameters: 
# -startDate 1/1/2001
# -file "c:\path\to\.csv"
# Matthew Henry 3/15/2018
param
(
  $startDate = (get-date).tostring("MM/1/yyyy"),
  $file = "transactions.csv"
)
$categoriesToSkip = @("Paycheck", "Transfer")
echo $startDate

$startDate = [datetime]$startDate
$endDate = $startDate.AddMonths(1)

$rows = Import-CSV $file
# Filter by date
$rows = $rows | Where-Object -FilterScript { ([datetime]$_.Date).Date -ge $startDate -and ([datetime]$_.Date).Date -lt $endDate}
# Filter out categories
$rows = $rows | Where-Object -FilterScript { $categoriesToSkip -notcontains $_.Category }
# Generate pivot table
$table = @{}
Foreach ($row IN $rows)
{
	$amount = [decimal]$row.Amount
	if ($row."Transaction Type" -eq "debit")
	{
		$amount = -1*$amount
	}
	if ($table[$row.Category])
	{
		$table[$row.Category] = $amount  + $table[$row.Category]
	}
	else
	{
		$table[$row.Category] = $amount 
	}
}
$table.GetEnumerator() | sort Value
$total = 0
$table.GetEnumerator() | % {$total += $_.Value}
echo "TOTAL: $total"
$s = $startDate.tostring('MM/1/yyyy')
$e = $endDate.tostring('MM/1/yyyy')
echo "(from $s to $e)"
