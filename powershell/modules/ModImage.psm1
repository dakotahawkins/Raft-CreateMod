# Create placeholder banner and icon JPGs.

using namespace System.Drawing
Add-Type -AssemblyName System.Drawing

$FontCollection = [Text.PrivateFontCollection]::new()
$FontCollection.AddFontFile("$PSScriptRoot\..\data\chinese_rocks\chinese rocks rg.ttf")
$LoadedFont = `
    [Font]::new($FontCollection.Families[0], 100.0, [FontStyle]::Regular, [GraphicsUnit]::Pixel)
$StringFormat = [StringFormat]::new([StringFormatFlags]::NoClip -bor [StringFormatFlags]::NoWrap)
$StringFormat.LineAlignment = [StringAlignment]::Center
$StringFormat.Alignment = [StringAlignment]::Center

Function Get-ScaledFont([Graphics] $Graphics, [SizeF] $Size, [String] $ModName) {
    [SizeF] $RealSize = $Graphics.MeasureString($ModName, $LoadedFont)
    [Float] $HeightScaleRatio = $Size.Height / $RealSize.Height
    [Float] $WidthScaleRatio = $Size.Width / $RealSize.Width
    [Float] $ScaleRatio = [Math]::Min($HeightScaleRatio, $WidthScaleRatio)

    Return [Font]::new(`
        $LoadedFont.FontFamily, `
        $LoadedFont.Size * $ScaleRatio, `
        $LoadedFont.Style, `
        [GraphicsUnit]::Pixel `
    )
}

Function Get-Bitmap([String] $ModName, [Int[]] $ModColor, [Int] $Width, [Int] $Height) {
    $Banner = [Bitmap]::new($Width, $Height)
    $BrushBg = [Brushes]::DarkGray
    $BrushFg = [SolidBrush]::new([Color]::FromArgb($ModColor[0], $ModColor[1], $ModColor[2]))
    [Graphics] $Graphics = [Graphics]::FromImage($Banner)
    $Graphics.FillRectangle($BrushBg, 0, 0, $Banner.Width, $Banner.Height)
    $TextRectangle = [RectangleF]::new(10, 10, $Width - 20, $Height - 20)
    $Graphics.DrawString( `
        $ModName, `
        (Get-ScaledFont -Graphics $Graphics -Size $TextRectangle.Size -ModName $ModName), `
        $BrushFg, `
        $TextRectangle, `
        $StringFormat `
    )
    Return $Banner
}

Function Get-ModBanner([String] $ModName, [Int[]] $ModColor) {
    Return Get-Bitmap -ModName $ModName -ModColor $ModColor -Width 660 -Height 200
}

Function Get-ModIcon([String] $ModName, [Int[]] $ModColor) {
    Return Get-Bitmap -ModName $ModName -ModColor $ModColor -Width 256 -Height 256
}

Export-ModuleMember -Function Get-ModBanner
Export-ModuleMember -Function Get-ModIcon
