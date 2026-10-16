param(
    [Parameter(Mandatory)][string]$Base,
    [Parameter(Mandatory)][string]$Overrides,
    [Parameter(Mandatory)][string]$Output
)

$ErrorActionPreference = 'Stop'

$xml = New-Object System.Xml.XmlDocument
$xml.Load($Overrides)
$root = $xml.DocumentElement

$map = @{}
foreach ($c in $root.Color) {
    $map["$($c.Category)|$($c.Name)|$($c.Part)"] = $c
}
$used = New-Object 'System.Collections.Generic.HashSet[string]'

$lines = [System.IO.File]::ReadAllText($Base).Split("`n")
$category = $null
$color = $null

for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s*<Theme ') {
        $line = $line -replace 'Name="[^"]*"', "Name=`"$($root.Name)`"" -replace '(?<=\s)GUID="[^"]*"', "GUID=`"$($root.Guid)`""
    }
    elseif ($line -match '^\s*<Category Name="([^"]+)"') {
        $category = $Matches[1]
    }
    elseif ($line -match '^\s*<Color Name="([^"]+)"') {
        $color = $Matches[1]
    }
    elseif ($line -match '^(\s*)<(Background|Foreground) Type="\w+" Source="\w+" />') {
        $key = "$category|$color|$($Matches[2])"
        if ($map.ContainsKey($key)) {
            $o = $map[$key]
            $line = "$($Matches[1])<$($Matches[2]) Type=`"$($o.Type)`" Source=`"$($o.Source)`" />"
            [void]$used.Add($key)
        }
    }
    $lines[$i] = $line
}

$unused = @($map.Keys | Where-Object { -not $used.Contains($_) })
if ($unused.Count -gt 0) {
    throw "Overrides not found in base theme: $($unused -join '; ')"
}

[System.IO.File]::WriteAllText($Output, ($lines -join "`n"), (New-Object System.Text.UTF8Encoding($false)))
