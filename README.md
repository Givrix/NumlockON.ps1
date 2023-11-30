# NumlockON.ps1
Set Numpad lock as enabled by default and on every profile on a given Windows system (7 to 11), including login prompt.

Enables numlock on every local, remote, system and defaut account by editing the registry hives
Probably overkill, but works fine as an immediate task, from GPO on an Active Directory domain.
(Configure the task using NT Authory\System as a user, and set maximal priviledges)

Thanks PDQ for base script https://www.pdq.com/blog/modifying-the-registry-users-powershell/
