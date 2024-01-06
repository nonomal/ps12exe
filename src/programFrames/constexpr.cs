// Simple PowerShell host created by Ingo Karstein (http://blog.karstein-consulting.com)
// Reworked and GUI support by Markus Scholtes

using System;
using System.Collections.Generic;
using System.Text;
using System.Globalization;
using System.Reflection;
#if noConsole
	using System.Windows.Forms;
	using System.Drawing;
#endif
#if winFormsDPIAware
	using System.Runtime.Versioning;
#endif

// not displayed in details tab of properties dialog, but embedded to file
#if Resources
	[assembly: AssemblyDescription("$description")]
	[assembly: AssemblyCompany("$company")]
	[assembly: AssemblyTitle("$title")]
	[assembly: AssemblyProduct("$product")]
	[assembly: AssemblyCopyright("$copyright")]
	[assembly: AssemblyTrademark("$trademark")]
#endif
#if version
	[assembly: AssemblyVersion("$version")]
	[assembly: AssemblyFileVersion("$version")]
#endif
#if winFormsDPIAware
	[assembly: TargetFrameworkAttribute(".NETFramework,Version=v4.7,Profile=Client")]
#endif

namespace PSRunnerNS {
	internal class PSRunner {
		private static int Main() {
			#if UNICODEEncoding && !noConsole
			System.Console.OutputEncoding = new System.Text.UnicodeEncoding();
			#endif

			#if!noVisualStyles && noConsole
			Application.EnableVisualStyles();
			#endif

			#if noConsole
				// load assembly:AssemblyTitle
				AssemblyTitleAttribute titleAttribute = (AssemblyTitleAttribute) Attribute.GetCustomAttribute(Assembly.GetExecutingAssembly(), typeof (AssemblyTitleAttribute));
				string title;
				if (titleAttribute != null)
					title = titleAttribute.Title;
				else
					title = System.AppDomain.CurrentDomain.FriendlyName;
				// 弹窗输出$ConstResult
				MessageBox.Show("$ConstResult", title, MessageBoxButtons.OK);
			#else
				// 控制台输出$ConstResult
				System.Console.WriteLine("$ConstResult");
			#endif
			return 0;
		}
	}
}
