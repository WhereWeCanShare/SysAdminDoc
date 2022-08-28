Get-CimInstance -ClassName Win32_Desktop
Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*"
Get-CimInstance -ClassName Win32_ComputerSystem
Get-CimInstance -ClassName Win32_OperatingSystem
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
