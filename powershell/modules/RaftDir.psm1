# Get Raft's installation directory with Get-RaftDir.

using namespace System.Text.RegularExpressions

Function Get-SteamAppsDir() {
    ForEach ($key in @("HKLM:\SOFTWARE\Wow6432Node", "HKLM:\SOFTWARE")) {
        [String] $steamKey = "$key\Valve\Steam"
        If (Test-Path $steamKey) {
            [String] $steamDir = `
                ("{0}\steamapps" -f $(Get-ItemProperty -Path $steamKey).InstallPath)
            If (Test-Path $steamDir) {
                Return $steamDir
            }
        }
    }

    Write-Error -Exception `
        ([System.IO.FileNotFoundException]::new("Could not find Steam apps directory.")) `
        -ErrorAction Stop
}

Function Get-SteamLibraryPaths() {
    [String] $steamAppsDir = Get-SteamAppsDir
    [String[]] $steamLibraryPaths = @($steamAppsDir)

    # Find alternate library paths
    [String] $libraryFoldersFile = "$steamAppsDir\libraryfolders.vdf"
    If (Test-Path $libraryFoldersFile) {
        (Get-Content $libraryFoldersFile) | `
            Select-String '^\s*"\d+"\s+"([^"]+)"\s*$' -AllMatches | `
                ForEach-Object { $_.Matches } | `
                    ForEach-Object { [Regex]::Unescape($_.Groups[1].Value) } | `
                        Where-Object { Test-Path "$_\steamapps" } | `
                            ForEach-Object { $steamLibraryPaths += "$_\steamapps" }
    }

    Return $steamLibraryPaths
}

Function Get-RaftDir() {
    ForEach ($steamLibraryPath in Get-SteamLibraryPaths) {
        [String] $raftManifest = "$steamLibraryPath\appmanifest_648800.acf"
        [String] $raftPath = "$steamLibraryPath\common\Raft"
        If ((Test-Path $raftManifest) -And (Test-Path $raftPath)) {
            Return $raftPath
        }
    }

    Write-Error -Exception `
        ([System.IO.FileNotFoundException]::new("Could not find Raft directory.")) `
        -ErrorAction Stop
}

Export-ModuleMember -Function Get-RaftDir
