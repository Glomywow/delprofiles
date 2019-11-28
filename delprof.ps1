Get-WmiObject win32_userprofile -Filter 'Special=False' | 
    ForEach-Object{
        $SID = [System.Security.Principal.SecurityIdentifier]$_.SID
        $NtAccount = $SID.Translate([System.Security.Principal.NTAccount])
        $_ | Add-Member -MemberType NoteProperty -Name NtAccount -Value $NtAccount
        $_ | Add-Member -MemberType NoteProperty -Name Domain -Value ($NtAccount -split '\\')[0]
        $_ #pass the updated object
    } |
    Where-Object{
        #-not $_.Loaded -and #skips loaded profiles
        $_.lastusetime -and # skips unused profiles
        $_.Domain -notmatch 'NT SERVICE|LOCAL SERVICE' -and
        $_.ConvertToDateTime($_.lastusetime) -gt [datetime]::Today.AddDays(-180) -and
        $_.localpath # skips blank paths
    } |
    Select-Object Domain, NtAccount, LastUseTime, LocalPath

#Change "Select" to "ForEach-Object{ $_.Delete()}" to remove the profiles.
