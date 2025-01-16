﻿if ($UIMode -eq 'Auto' -or -not $UIMode) {
	$DarkMode = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue
	$DarkMode = $DarkMode -eq 0
}
else {
	$DarkMode = $UIMode -eq 'Dark'
}

function Set-DarkMode($set) {
	function ForEachControl($Control, $RunScriptBlock) {
		$Script:refs.Values | Where-Object { $_.GetType().Name -eq $Control } | ForEach-Object $RunScriptBlock
	}
	if ($set) {
		$Script:refs.MainForm.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#333333')
		$Script:refs.MainForm.ForeColor = [System.Drawing.ColorTranslator]::FromHtml('#FFFFFF')
		ForEachControl 'TextBox' {
			$_.BackColor = 'WindowFrame'
			$_.ForeColor = 'Window'
			$_.BorderStyle = 'FixedSingle'
		}
		ForEachControl 'Button' {
			$_.BackColor = 'WindowFrame'
			$_.FlatStyle = 'Flat'
		}
		ForEachControl 'CheckBox' {
			$_.ForeColor = 'Window'
			$_.FlatStyle = 'Flat'
		}
		ForEachControl 'GroupBox' {
			$_.ForeColor = 'Window'
		}
		$color = 0x181818
	}
	else {
		$Script:refs.MainForm.BackColor = 'Control'
		$Script:refs.MainForm.ForeColor = 'ControlText'
		ForEachControl 'TextBox' {
			$_.BackColor = 'Window'
			$_.ForeColor = 'WindowText'
			$_.BorderStyle = 'Fixed3D'
		}
		ForEachControl 'Button' {
			$_.BackColor = 'Control'
			$_.FlatStyle = 'Standard'
		}
		ForEachControl 'CheckBox' {
			$_.ForeColor = 'ControlText'
			$_.FlatStyle = 'Standard'
		}
		ForEachControl 'GroupBox' {
			$_.ForeColor = 'WindowText'
		}
		$color = 0xeff4f9
	}
	# DWMWA_USE_IMMERSIVE_DARK_MODE
	[ps12exeGUI.Dwm]::SetWindowAttribute($Script:refs.MainForm.Handle, 20, $set)
	# DWMWA_BORDER_COLOR
	$color = (($color -band 0xff) -shl 16) + ($color -band 0xff00) + (($color -shr 16) -band 0xff)
	[ps12exeGUI.Dwm]::SetWindowAttribute($Script:refs.MainForm.Handle, 34, $color)
}

Set-DarkMode $DarkMode
