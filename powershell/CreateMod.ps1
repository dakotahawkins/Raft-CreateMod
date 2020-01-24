using namespace System.Drawing

Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [Alias("Name")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        If (-Not (
            $_ -Match '^[a-zA-Z0-9]' -And `
            $_ -Match '[a-zA-Z0-9]$' -And `
            $_ -Match '^[a-zA-Z0-9 ]+$'
        )) {
            Throw [System.ArgumentException] "Invalid name."
        }
        return $true
    })]
    [String] $ModName,

    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        If (-Not (Test-Path -PathType Container $_)) {
            Throw [System.ArgumentException] "Path does not exist or is not a directory."
        }
        return $true
    })]
    [System.IO.FileInfo] $Path,

    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        If ($_ -NotMatch '^[\w ]+$') {
            Throw [System.ArgumentException] "Invalid author name."
        }
        return $true
    })]
    [String] $AuthorName,

    [Parameter(Position = 3, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        If ($_ -NotMatch '^\w+$') {
            Throw [System.ArgumentException] "Invalid GitHub user name."
        }
        return $true
    })]
    [String] $GitHubUserName,

    [Parameter(Position = 4, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        If ($_ -NotMatch '^[\w-]+$') {
            Throw [System.ArgumentException] "Invalid GitHub project name."
        }
        return $true
    })]
    [String] $GitHubProjectName,

    [Parameter(Position = 5, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String] $ModDescription
)
$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\modules\ModColor.psm1"
Import-Module "$PSScriptRoot\modules\ModImage.psm1"
Import-Module "$PSScriptRoot\modules\RaftDir.psm1"

[String] $ModNameNoSpace = ($ModName -replace ' +', '')

# Make sure the mod doesn't already exist on disk.
[String] $ModPath = "{0}\{1}" -f $Path, $ModNameNoSpace
If (Test-Path $ModPath) {
    Write-Error -Exception `
        ([System.IO.IOException]::new("$ModPath already exists."))
}

# Make sure the mod probably doesn't already exist on the server.
[String] $ModVersionUrl = ( `
    "https://www.raftmodding.com/api/v1/mods/{0}/version.txt" -f `
        ($ModName -replace ' +', '-').ToLowerInvariant() `
)
Try {
    [Int] $StatusCode = `
        (Invoke-WebRequest -Uri $ModVersionUrl -UseBasicParsing -DisableKeepAlive).StatusCode
    If ($StatusCode -eq 200) {
        Write-Error -Exception `
            ([System.IO.IOException]::new( `
                "$ModVersionUrl already exists, mod name likely taken." `
            ))
    } ElseIf ($StatusCode -ne 404) {
        Write-Error -Exception `
            ([System.IO.IOException]::new( `
                "Unexpected status $StatusCode returned when attempting to access $ModVersionUrl" `
            ))
    }
}
Catch [System.Net.WebException] {
    [Int] $StatusCode = $_.Exception.Response.StatusCode
    If ($StatusCode -ne 404) {
        Write-Error -Exception `
            ([System.IO.IOException]::new( `
                "Unexpected status $StatusCode returned when attempting to access $ModVersionUrl" `
            ))
    }
}

[Int[]] $ModColor = (Get-ModColor)

# Get hashtable of strings to find and replace
[Hashtable] $Replacements = @{}
Get-Content -Path "$PSScriptRoot\data\guid-replacements.txt" | `
    Where-Object { $_.Trim() -ne '' } | `
        ForEach-Object {
            $Replacements[$_] = [guid]::NewGuid().ToString().ToUpperInvariant()
        }
$Replacements.Add("ModName", $ModName)
$Replacements.Add("ModName-NoSpace", $ModNameNoSpace)
$Replacements.Add("ModVersionUrl", $ModVersionUrl)
$Replacements.Add("ModColor", (Get-ColorString -RGB $ModColor))
$Replacements.Add("RaftDir", (Get-RaftDir))
$Replacements.Add("AppDataDir", (Get-ChildItem Env:AppData).Value)
$Replacements.Add("Year", (Get-Date -Format yyyy))
$Replacements.Add("AuthorName", $AuthorName)
$Replacements.Add("AuthorName-NoSpace", ($AuthorName -replace ' +', ''))
$Replacements.Add("GitHubUserName", $GitHubUserName)
$Replacements.Add("GitHubProjectName", $GitHubProjectName)
$Replacements.Add("ModDescription", $ModDescription)

# Copy template/* to mod dir
Copy-Item -Path "$PSScriptRoot\..\template" -Destination $ModPath -Recurse

# Rename project and solution files in destination
Move-Item `
    -Path "$ModPath\mod.sln" `
    -Destination "$ModPath\$ModNameNoSpace.sln"
Move-Item `
    -Path "$ModPath\mod\mod.cs" `
    -Destination "$ModPath\mod\$ModNameNoSpace.cs"
Move-Item `
    -Path "$ModPath\mod\mod.csproj" `
    -Destination "$ModPath\mod\$ModNameNoSpace.csproj"
Move-Item `
    -Path "$ModPath\mod" `
    -Destination "$ModPath\$ModNameNoSpace"

# Make replacements in destination files
ForEach ($File in (Get-ChildItem "$ModPath" -File -Recurse)) {
    $Replacements.GetEnumerator() | ForEach-Object {
        ((Get-Content -Path $File.FullName -Raw) -Replace "@$($_.key)@", $_.Value) | `
            Set-Content -Path $File.FullName -NoNewline
    }
}

# Generate placeholder banner and icon
(Get-ModBanner -ModName $ModName -ModColor $ModColor).Save( `
    "$ModPath\ModResources\banner.jpg", `
    [Imaging.ImageFormat]::Jpeg `
)
(Get-ModIcon -ModName $ModName -ModColor $ModColor).Save( `
    "$ModPath\ModResources\icon.jpg", `
    [Imaging.ImageFormat]::Jpeg `
)

# Initialize the new repository
& git @('-C', $ModPath, 'init', '.')
& git @('-C', $ModPath, 'remote', 'add', 'origin', "https://github.com/$GitHubUserName/$GitHubProjectName.git")
& git @('-C', $ModPath, 'submodule', 'add', '../../dakotahawkins/raft-prepare-release.git', 'utils/raft-prepare-release')
& git @('-C', $ModPath, 'submodule', 'update', '--init', '--recursive')
& git @('-C', $ModPath, 'add', '-A')
& git @('-C', $ModPath, 'add', '-f', 'release\.gitignore')
& git @('-C', $ModPath, 'commit', '-m', 'Initial Commit')

# TODO: tag/prepare pre-release, push, tell the user what to do next
