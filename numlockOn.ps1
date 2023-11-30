# NumlockON.ps1
# Enables numlock on every local, remote, system and defaut account by editing the registry hives
# Probably overkill, but works fine as an immediate task, from GPO on an Active Directory domain.
# (Configure the task using NT Authory\System as a user, and set maximal priviledges)

# Thanks PDQ for base script https://www.pdq.com/blog/modifying-the-registry-users-powershell/
 
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
   
 
    # InitialKeyboardIndicators should be 2 for Numlock enabled, 0 for disabled, 2147483650 for last state
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
# Enable Numlock for the default profile
Set-Itemproperty -path "registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard" -Name 'InitialKeyboardIndicators' -value '2'
# Set for System accounts that could mess up with the numlock on login prompt
Set-Itemproperty -path 'registry::HKEY_USERS\S-1-5-18\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -value '2'
Set-Itemproperty -path 'registry::HKEY_USERS\S-1-5-19\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -value '2'
Set-Itemproperty -path 'registry::HKEY_USERS\S-1-5-20\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -value '2'
