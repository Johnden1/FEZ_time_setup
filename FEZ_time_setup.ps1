Add-Type -TypeDefinition '
using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace KeyLogger {
  public static class Program {
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;

    private static HookProc hookProc = HookCallback;
    private static IntPtr hookId = IntPtr.Zero;
    private static int keyCode = 0;

    [DllImport("user32.dll")]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    public static int WaitForKey() {
      hookId = SetHook(hookProc);
      Application.Run();
      UnhookWindowsHookEx(hookId);
      return keyCode;
    }

    private static IntPtr SetHook(HookProc hookProc) {
      IntPtr moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
      return SetWindowsHookEx(WH_KEYBOARD_LL, hookProc, moduleHandle, 0);
    }

    private delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
      if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
        keyCode = Marshal.ReadInt32(lParam);
        Application.Exit();
      }
      return CallNextHookEx(hookId, nCode, wParam, lParam);
    }
  }
}
' -ReferencedAssemblies System.Windows.Forms
if (-not [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {	# checks if the script is running as admin
	exit
}

while ($true) {
    $key = [System.Windows.Forms.Keys][KeyLogger.Program]::WaitForKey()
	if ($key -eq "NumPad0") {	# Resets the time to current time
		W32tm /resync /force
	}
    if ($key -eq "NumPad1") {
        #Set-Date -Date "01/01/2023 00:31:55"
		$d = (Get-ChildItem $env:appdata\FEZ\SaveSlot4).CreationTime	# Location of FEZ speedrun save file
        Set-Date -Date $d
    }
	if ($key -eq "NumPad9") {
        #Set-Date -Date "01/01/2023 06:03:18"
        Set-Date -Date ($d + "5:31:18")
    }
	if ($key -eq "NumPad7") {
        #Set-Date -Date "01/01/2023 00:45:45"
        Set-Date -Date ($d + "0:13:45")
    }
	if ($key -eq "NumPad8") {
        #Set-Date -Date "01/01/2023 00:00:09"
        Set-Date -Date ($d + "0:0:9")
    }
	if ($key -eq "NumPad6") {
        #Set-Date -Date "02/01/2023 15:11:25"
        Set-Date -Date ($d.AddDays(1) + "14:39:25")
    }
	if ($key -eq "Decimal") {	# Quits the program
        exit
    }

}

