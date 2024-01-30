param(
	[scriptblock]$CheckLocaleData = {
		$null -ne $Script:LocalizeData
	},
	[scriptblock]$FaildLoadLocaleData = {
		param (
			[string]$Localize
		)
		Write-Warning "Failed to load locale data $Localize`nSee $LocalizeDir/README.md for how to add custom locale."
	},
	[scriptblock]$LoadLocaleData = {
		param (
			[string]$Localize
		)
		$Script:LocalizeData = try { &"$LocalizeDir\$Localize.ps1" } catch {}
	},
	[string]$Localize
)

if (!$Localize) {
	# 本机语言
	$Localize = (Get-Culture).Name
}

$LocalizeDir = "$PSScriptRoot/locale"

&$LoadLocaleData $Localize
if (!(&$CheckLocaleData)) {
	$LocalizeList = Get-ChildItem $LocalizeDir | Where-Object { $_.Name -like '*.fbs' } | ForEach-Object { $_.BaseName }
	&$FaildLoadLocaleData $Localize
	$LocalizeHead = $Localize.Split('-')[0]
	$SimilarLocalize = $LocalizeList | Where-Object { $_.StartsWith($LocalizeHead) }
	foreach ($Localize in $SimilarLocalize) {
		&$LoadLocaleData $Localize
		if (&$CheckLocaleData) {
			break
		}
	}
	if (!(&$CheckLocaleData)) { &$LoadLocaleData 'en-UK' }
}
if (!(&$CheckLocaleData)) {
	foreach ($Localize in $LocalizeList) {
		&$LoadLocaleData $Localize
		if (&$CheckLocaleData) {
			break
		}
	}
}
$Script:LocalizeData
