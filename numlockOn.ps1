$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
 
# Get Username, SID, and location of ntuser.dat for all users
$ProfileList = gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID} | 
    Select  @{name="SID";expression={$_.PSChildName}}, 
            @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}}, 
            @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}
 
# Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
$LoadedHives = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} | Select @{name="SID";expression={$_.PSChildName}}
 
# Get all users that are not currently logged
$UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select @{name="SID";expression={$_.InputObject}}, UserHive, Username
 
# Loop through each profile on the machine
Foreach ($item in $ProfileList) {
    # Load User ntuser.dat if it's not already loaded
    IF ($item.SID -in $UnloadedHives.SID) {
        reg load HKU\$($Item.SID) $($Item.UserHive) | Out-Null
    }
 
    #####################################################################
    # This is where you can read/modify a users portion of the registry 
 
    # This example lists the Uninstall keys for each user registry hive
    $path = "registry::HKEY_USERS\$($Item.SID)\Control Panel\Keyboard"
    if ((Test-path $path) -and (Get-ItemProperty $path).InitialKeyboardIndicators -ne "2"){
        Set-Itemproperty -path $path -Name 'InitialKeyboardIndicators' -value '2'
    }
    
    #####################################################################
 
    # Unload ntuser.dat        
    IF ($item.SID -in $UnloadedHives.SID) {
        ### Garbage collection and closing of ntuser.dat ###
        [gc]::Collect()
        reg unload HKU\$($Item.SID) | Out-Null
    }
}
Set-Itemproperty -path "registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard" -Name 'InitialKeyboardIndicators' -value '2'
Set-Itemproperty -path 'registry::HKEY_USERS\S-1-5-18\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -value '2'
Set-Itemproperty -path 'registry::HKEY_USERS\S-1-5-19\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -value '2'
Set-Itemproperty -path 'registry::HKEY_USERS\S-1-5-20\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -value '2'
if (Test-path 'registry::HKEY_USERS\S-1-5-80-3589385106-520469509-3569633472-84460881-2732306008\Control Panel\Keyboard') {
    Set-Itemproperty -path 'registry::HKEY_USERS\S-1-5-80-3589385106-520469509-3569633472-84460881-2732306008\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -value '2'
}