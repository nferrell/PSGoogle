function Remove-GSGroupMember {
    <#
    .SYNOPSIS
    Removes members from a group
    
    .DESCRIPTION
    Removes members from a group
    
    .PARAMETER Identity
    The email or unique Id of the group to remove members from
    
    .PARAMETER Member
    The member or array of members to remove from the target group
    
    .EXAMPLE
    Remove-GSGroupMember -Identity admins -Member joe.smith,mark.taylor -Confirm:$false

    Removes members Joe Smith and Mark Taylor from the group admins@domain.com and skips asking for confirmation
    #>
    [cmdletbinding(SupportsShouldProcess = $true,ConfirmImpact = "High")]
    Param
    (
        [parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [Alias('GroupEmail','Group','Email')]
        [String]
        $Identity,
        [parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,Position = 1)]
        [Alias("PrimaryEmail","UserKey","Mail","User","UserEmail")]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Member
    )
    Begin {
        $serviceParams = @{
            Scope       = 'https://www.googleapis.com/auth/admin.directory.group'
            ServiceType = 'Google.Apis.Admin.Directory.directory_v1.DirectoryService'
        }
        $service = New-GoogleService @serviceParams
    }
    Process {
        if ($Identity -notlike "*@*.*") {
            $Identity = "$($Identity)@$($Script:PSGSuite.Domain)"
        }
        foreach ($G in $Member) {
            try {
                if ($G -notlike "*@*.*") {
                    $G = "$($G)@$($Script:PSGSuite.Domain)"
                }
                if ($PSCmdlet.ShouldProcess("Removing member '$G' from group '$Identity'")) {
                    Write-Verbose "Removing member '$G' from group '$Identity'"
                    $request = $service.Members.Delete($Identity,$G)
                    $request.Execute()
                    Write-Verbose "Member '$G' has been successfully removed"
                }
            }
            catch {
                if ($ErrorActionPreference -eq 'Stop') {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
                else {
                    Write-Error $_
                }
            }
        }
    }
}