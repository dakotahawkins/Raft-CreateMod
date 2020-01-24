# Get a random color for use in mod logging.

Function Get-ModColor() {
    # One of R, G, or B must be 0x00, other two are random. Hopefully the result contrasts well with
    # the grey console background.
    [Int[]] $RGB = @(0, 0, 0)
    [Int] $StartingIndex = Get-Random -Maximum 3
    $RGB[$StartingIndex] = Get-Random -Maximum (0xFF + 1)
    $RGB[($StartingIndex + 1) % 3] = Get-Random -Maximum (0xFF + 1)

    Return ,@($RGB)
}

Function Get-ColorString([Int[]] $RGB) {
    Return ("0x{0:X2}{1:X2}{2:X2}" -f $RGB[0], $RGB[1], $RGB[2])
}

Export-ModuleMember -Function Get-ModColor
Export-ModuleMember -Function Get-ColorString
