[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$PathLike = "*",
    [UInt64]$SessionId,
    [ValidateSet("List", "CloseSession")]
    [string]$Mode = "List"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Get-Command Get-SmbOpenFile -ErrorAction Stop | Out-Null
    $matching = @(Get-SmbOpenFile | Where-Object {
        if ($SessionId -ne 0 -and $_.SessionId -ne $SessionId) { return $false }
        if ([string]$_.Path -notlike $PathLike) { return $false }
        return $true
    })

    if ($matching.Count -eq 0) {
        Write-Host "No matching SMB open files found." -ForegroundColor DarkGray
        exit 0
    }

    $sessions = @($matching |
        Group-Object SessionId |
        Sort-Object Count -Descending |
        Select-Object @{
            Name = "SessionId"
            Expression = { $_.Group[0].SessionId }
        }, @{
            Name = "ClientComputerName"
            Expression = { [string]$_.Group[0].ClientComputerName }
        }, @{
            Name = "ClientUserName"
            Expression = { [string]$_.Group[0].ClientUserName }
        }, @{
            Name = "OpenFileCount"
            Expression = { $_.Count }
        }, @{
            Name = "SamplePath"
            Expression = { [string]$_.Group[0].Path }
        })

    $sessions | Format-Table -AutoSize | Out-String | Write-Host

    if ($Mode -eq "CloseSession") {
        $sessionIds = @($sessions | Select-Object -ExpandProperty SessionId)
        if ($PSCmdlet.ShouldProcess("matching SMB sessions", "Close sessions $($sessionIds -join ', ')")) {
            foreach ($id in $sessionIds) {
                Close-SmbSession -SessionId $id -Force
            }
        }
    }
}
catch {
    Write-Error @"
find_and_kick_smb_holder.ps1 requires the Windows SMB Server PowerShell cmdlets.

Run it on the SMB file server, or on an admin workstation with:
  - Get-SmbOpenFile
  - Close-SmbSession

Original error: $($_.Exception.Message)
"@
    exit 1
}
