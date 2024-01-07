function GetAssembly($name, $otherinfo) {
	$n = New-Object System.Reflection.AssemblyName(@($name, $otherinfo) -ne $null -join ",")
	try {
		[System.AppDomain]::CurrentDomain.Load($n).Location
	}
	catch {
		$Error.Remove(0)
	}
}
$referenceAssembies = @()
# 绝不要直接使用 System.Private.CoreLib.dll，因为它是netlib的内部实现，而不是公共API
# [int].Assembly.Location 等基础类型的程序集也是它。
$referenceAssembies += GetAssembly "mscorlib"
$referenceAssembies += GetAssembly "Syste.Runtime"
$referenceAssembies += GetAssembly "System.Management.Automation"

# If noConsole is true, add System.Windows.Forms.dll and System.Drawing.dll to the reference assemblies
if ($noConsole) {
	$referenceAssembies += GetAssembly "System.Windows.Forms"
	$referenceAssembies += GetAssembly "System.Drawing"
}
else {
	$referenceAssembies += GetAssembly "System.Console"
	$referenceAssembies += GetAssembly "Microsoft.PowerShell.ConsoleHost"
}

# If in winpwsh, add System.Core.dll to the reference assemblies
if ($PSVersionTable.PSEdition -ne "Core") {
	$referenceAssembies += GetAssembly "System.Core" "Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
}

[string[]]$Constants = @()

$Constants += $threadingModel
if ($lcid) { $Constants += "culture" }
if ($noError) { $Constants += "noError" }
if ($noConsole) { $Constants += "noConsole" }
if ($noOutput) { $Constants += "noOutput" }
if ($resourceParams.version) { $Constants += "version" }
if ($resourceParams.Count) { $Constants += "Resources" }
if ($credentialGUI) { $Constants += "credentialGUI" }
if ($noVisualStyles) { $Constants += "noVisualStyles" }
if ($exitOnCancel) { $Constants += "exitOnCancel" }
if ($UNICODEEncoding) { $Constants += "UNICODEEncoding" }
if ($winFormsDPIAware) { $Constants += "winFormsDPIAware" }

. $PSScriptRoot\BuildFrame.ps1

if (-not $TempDir) {
	$TempDir = $TempTempDir = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()
	New-Item -Path $TempTempDir -ItemType Directory | Out-Null
}
$TempDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TempDir)

$Content | Set-Content $TempDir\main.ps1 -Encoding UTF8 -NoNewline
if ($iconFile -match "^(https?|ftp)://") {
	Invoke-WebRequest -Uri $iconFile -OutFile $TempDir\icon.ico
	if (!(Test-Path $TempDir\icon.ico -PathType Leaf)) {
		Write-Error "Icon file $iconFile failed to download!"
		return
	}
	$iconFile = "$TempDir\icon.ico"
}
elseif ($iconFile) {
	# retrieve absolute path independent if path is given relative oder absolute
	$iconFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($iconFile)

	if (!(Test-Path $iconFile -PathType Leaf)) {
		Write-Error "Icon file $iconFile not found!"
		return
	}
}
