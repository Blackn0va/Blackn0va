#requires -Version 7.0
<#
.SYNOPSIS
    Erzeugt die Statistik-Karten des GitHub-Profils – öffentliche UND private Repositories.

.DESCRIPTION
    Zweck
        Zählt über die GitHub-GraphQL-API die eigenen Projekte und die eigenen Commits auf den
        Standardzweigen und schreibt daraus:
          assets/stats-dark.svg, assets/stats-light.svg          Karte „GitHub in Zahlen“
          assets/languages-dark.svg, assets/languages-light.svg  Karte „Sprachen“
          assets/stats.json                                      Vergleichsstand für den nächsten Lauf
          README.md                                              Block zwischen den stats-Markierungen

    WICHTIG
        - Das Profil ist öffentlich, die Actions-Protokolle des Profil-Repositories auch. Das Skript
          nennt deshalb nirgends den Namen eines privaten Repositories – nicht auf den Karten, nicht
          in stats.json, nicht im Protokoll. Es gibt nur Summen aus.
        - Fail-closed: Sinkt die Commit-Zahl oder fallen die privaten Projekte auf 0, fehlt dem
          Token fast immer das Leserecht auf private Repositories. Dann wird nichts geschrieben.
          Bewusst übergehen (etwa nach dem Löschen eines Repositories) mit -Erzwingen.
        - Ein Ausschlussname, der zu keinem Repository passt, bricht ebenfalls ab. Sonst kämen die
          ausgeschlossenen Commits nach einer Umbenennung unbemerkt zurück in die Zahl.
        - Ändert sich nichts, bleibt jede Datei unangetastet – der Workflow committet dann nichts.

    Was zählt
        Projekte  eigene Repositories ohne Forks, ohne das Profil-Repository und ohne die
                  ausgeschlossenen
        Commits   Commits mit dem Konto als Autor auf dem Standardzweig jedes eigenen Repositories
                  außer den ausgeschlossenen; in Forks zählen nur die eigenen
        Sprachen  Codeumfang laut GitHub-Linguist (vendorte Ordner zählt GitHub nicht mit)

    Voraussetzungen
        - PowerShell 7 und die GitHub CLI (gh)
        - Lokal: gh ist angemeldet (gh auth status) und darf private Repositories lesen
        - In GitHub Actions: GH_TOKEN aus dem Secret STATS_TOKEN – Fine-grained Token für alle
          eigenen Repositories mit „Contents: Read-only“ und „Metadata: Read-only“

    Warum die Datei ein BOM hat
        Windows PowerShell 5.1 liest Dateien ohne BOM als ANSI, die Umlaute in Texten und
        Kommentaren zerfielen dann. Mit BOM lesen 5.1 und 7 die Datei gleich.

    Exitcodes
        0 sauber (geschrieben oder nichts zu tun) · 1 Fehler, nichts geschrieben

.EXAMPLE
    pwsh -File scripts/Statistik-aktualisieren.ps1 -Probelauf -AusgeschlosseneRepos 'repo-a'
    Zählt und zeigt die Summen, schreibt nichts.

.EXAMPLE
    pwsh -File scripts/Statistik-aktualisieren.ps1 -AusgeschlosseneRepos 'repo-a,repo-b'
    Zählt und schreibt Karten, stats.json und den README-Block.
#>
[CmdletBinding()]
param(
    # Nur zählen und anzeigen, nichts schreiben.
    [switch] $Probelauf,

    # Kommaliste von Repository-Namen, die nicht mitzählen. Standard ist die Umgebungsvariable
    # STATS_EXCLUDE_REPOS; im Workflow kommt sie aus einem Secret, damit der Name privat bleibt.
    [string] $AusgeschlosseneRepos = $env:STATS_EXCLUDE_REPOS,

    # Konto, dessen Zahlen gezählt werden. Das Token muss genau diesem Konto gehören.
    [string] $Konto = 'Blackn0va',

    # Sinkende Zahlen trotzdem schreiben, etwa nach dem Löschen eines Repositories.
    [switch] $Erzwingen
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

$inActions = $env:GITHUB_ACTIONS -eq 'true'

function Schritt([string] $Text) { Write-Host "==> $Text" -ForegroundColor Cyan }
function Hinweis([string] $Text) { Write-Host "    $Text" -ForegroundColor Gray }
function Warnen([string] $Text) {
    if ($inActions) { Write-Host "::warning::$Text" } else { Write-Host "WARNUNG: $Text" -ForegroundColor Yellow }
}
function Fehler([string] $Text) {
    if ($inActions) { Write-Host "::error::$Text" } else { Write-Host "FEHLER: $Text" -ForegroundColor Red }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$assetsDir = Join-Path $repoRoot 'assets'
$statsPath = Join-Path $assetsDir 'stats.json'
$readmePath = Join-Path $repoRoot 'README.md'

$de = [System.Globalization.CultureInfo]::GetCultureInfo('de-DE')
$inv = [System.Globalization.CultureInfo]::InvariantCulture
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# Feste Zuordnung Sprache → Farbplatz. WOZU: Die Farbe gehört zur Sprache, nicht zu ihrem Rang –
# überholt PHP irgendwann Java, tauschen die beiden die Plätze im Balken, aber nicht die Farben.
# Sprachen, die hier fehlen, landen in „Sonstige“. Mehr als acht Plätze gibt die Palette nicht her.
$languageSlots = [ordered]@{
    'Java'       = 0
    'C++'        = 1
    'PHP'        = 2
    'C#'         = 3
    'JavaScript' = 4
    'Python'     = 5
    'PowerShell' = 6
    'HTML'       = 7
}

# Farben je Darstellung. Die Sprachfarben sind die acht Kategorie-Plätze der dataviz-Referenzpalette,
# für die hellen und die dunklen Kartenflächen getrennt gestuft. Gemessen am 2026-11-14 mit
# validate_palette.js gegen #f6f8fa und #161b22: alle Pflichtprüfungen bestanden; Magenta liegt hell
# unter 3:1 und braucht deshalb die Legende mit Namen und Anteil, die die Karte ohnehin hat.
$themes = [ordered]@{
    dark  = @{
        Surface   = '#161b22'
        Border    = '#30363d'
        Text      = '#f0f6fc'
        Text2     = '#9198a1'
        Muted     = '#848d97'
        Other     = '#6e7681'
        Languages = @('#d95926', '#3987e5', '#9085e9', '#199e70', '#c98500', '#0ca30c', '#d55181', '#e66767')
    }
    light = @{
        Surface   = '#f6f8fa'
        Border    = '#d1d9e0'
        Text      = '#1f2328'
        Text2     = '#59636e'
        Muted     = '#656d76'
        Other     = '#8c959f'
        Languages = @('#eb6834', '#2a78d6', '#6250d6', '#1baf7a', '#eda100', '#008300', '#e87ba4', '#e34948')
    }
}

# FALLE: Der Operator -f formatiert mit der aktuellen Kultur. Auf einem deutschen Rechner würde aus
# 12.5 dann „12,5“ – und jede SVG-Koordinate wäre kaputt. Zahlen für SVG laufen deshalb hier durch.
function Format-Coordinate([double] $Value) {
    return $Value.ToString('0.##', $inv)
}

function Format-Count([long] $Value) {
    return $Value.ToString('N0', $de)
}

function Format-Share([double] $Value) {
    return $Value.ToString('N1', $de) + "`u{00A0}%"
}

function ConvertTo-XmlText([string] $Value) {
    return [System.Security.SecurityElement]::Escape($Value)
}

# FALLE: ConvertFrom-Json macht aus ISO-Zeitstempeln von sich aus DateTime-Werte. -DateKind String
# schaltet das erst ab PowerShell 7.5 ab, die Runner haben teils 7.4. Deshalb beide Formen annehmen.
function ConvertTo-IsoDate($Value) {
    if ($Value -is [datetime]) {
        return $Value.ToUniversalTime().ToString('yyyy-MM-dd', $inv)
    }
    return ([string]$Value).Substring(0, 10)
}

function Invoke-GitHubGraphQl {
    param(
        [Parameter(Mandatory)] [string] $Query,
        [hashtable] $Variables = @{}
    )
    $body = @{ query = $Query; variables = $Variables } | ConvertTo-Json -Depth 5 -Compress
    # WOZU: Anfrage über stdin statt -f/-F. Die Abfrage enthält Anführungszeichen, und deren
    # Weitergabe an native Programme unterscheidet sich zwischen PowerShell-Fassungen.
    $raw = $body | & gh api graphql --input -
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "GitHub-Abfrage fehlgeschlagen (gh beendet mit $exitCode)."
    }
    $result = ($raw -join "`n") | ConvertFrom-Json -AsHashtable
    if ($result.ContainsKey('errors') -and $result['errors']) {
        throw "GitHub-Abfrage lieferte Fehler: $(($result['errors'] | ForEach-Object { $_['message'] }) -join ' | ')"
    }
    return $result['data']
}

$svgFont = "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif"

function New-StatsSvg([System.Collections.IDictionary] $T, [System.Collections.IDictionary] $S, [string] $DateText) {
    # Vorher standen rechts neben der Hauptzahl Säulen je Jahr. Neben den 1.600 Commits von 2026
    # schrumpften alle älteren Jahre zu flachen Strichen und sahen nach Stillstand aus – auf Wunsch
    # am 2026-11-14 entfernt. commitsByYear bleibt in stats.json, die Kachel „Commits <Jahr>“ braucht es.
    $years = @($S.commitsByYear.Keys)
    $currentYear = $years[-1]
    $commits = Format-Count $S.commits
    $commitsYear = Format-Count ([long]$S.commitsByYear[$currentYear])
    $title = "GitHub in Zahlen: $commits Commits, davon $commitsYear im Jahr $currentYear; " +
        "$($S.projects) Projekte, davon $($S.projectsPrivate) privat; auf GitHub seit $($S.memberSince)."
    $yearsOnGitHub = [int]$currentYear - [int]$S.memberSince

    return @"
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="240" viewBox="0 0 400 240" role="img" aria-labelledby="t d">
  <title id="t">GitHub in Zahlen</title>
  <desc id="d">$(ConvertTo-XmlText $title)</desc>
  <style>
    text { font-family: $svgFont; }
    .h { font-size: 15px; font-weight: 600; fill: $($T.Text); }
    .sub { font-size: 12px; fill: $($T.Text2); }
    .hero { font-size: 48px; font-weight: 600; fill: $($T.Text); letter-spacing: -1px; }
    .val { font-size: 22px; font-weight: 600; fill: $($T.Text); }
    .lab { font-size: 12.5px; fill: $($T.Text2); }
    .note { font-size: 11px; fill: $($T.Muted); }
  </style>
  <rect x="0.5" y="0.5" width="399" height="239" rx="10" fill="$($T.Surface)" stroke="$($T.Border)"/>
  <text x="20" y="32" class="h">GitHub in Zahlen</text>
  <text x="20" y="51" class="sub">öffentliche und private Repositories · Stand $DateText</text>

  <text x="18" y="112" class="hero">$commits</text>
  <text x="20" y="134" class="lab">Commits gesamt</text>

  <line x1="20" y1="160.5" x2="380" y2="160.5" stroke="$($T.Border)"/>
  <text x="20" y="192" class="val">$commitsYear</text>
  <text x="20" y="212" class="lab">Commits $currentYear</text>
  <text x="145" y="192" class="val">$($S.projects)</text>
  <text x="145" y="212" class="lab">Projekte</text>
  <text x="145" y="228" class="note">$($S.projectsPrivate) davon privat</text>
  <text x="270" y="192" class="val">$yearsOnGitHub</text>
  <text x="270" y="212" class="lab">Jahre auf GitHub</text>
  <text x="270" y="228" class="note">seit $($S.memberSince)</text>
</svg>
"@
}

function New-LanguagesSvg([System.Collections.IDictionary] $T, [System.Collections.IDictionary] $S) {
    $items = @($S.languages)
    $barLeft = 20.0
    $barWidth = 360.0
    $gap = 2.0
    $usable = $barWidth - $gap * ($items.Count - 1)

    $segments = [System.Collections.Generic.List[string]]::new()
    $legend = [System.Collections.Generic.List[string]]::new()
    $x = $barLeft
    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $color = if ($null -eq $item.slot) { $T.Other } else { $T.Languages[$item.slot] }
        $w = $usable * $item.share / 100.0
        if ($w -gt 0) {
            $segments.Add("    <rect x=`"$(Format-Coordinate $x)`" y=`"70`" width=`"$(Format-Coordinate $w)`" height=`"8`" fill=`"$color`"><title>$(ConvertTo-XmlText $item.name): $(Format-Share $item.share)</title></rect>")
            $x += $w + $gap
        }

        # Legende in zwei Spalten, Reihenfolge wie im Balken.
        $col = $i % 2
        $row = [Math]::Floor($i / 2)
        $lx = 20.0 + $col * 190
        $ly = 114.0 + $row * 32
        $legend.Add("  <circle cx=`"$(Format-Coordinate ($lx + 5))`" cy=`"$(Format-Coordinate ($ly - 4.5))`" r=`"5`" fill=`"$color`"/>")
        $legend.Add("  <text x=`"$(Format-Coordinate ($lx + 18))`" y=`"$(Format-Coordinate $ly)`" class=`"name`">$(ConvertTo-XmlText $item.name)</text>")
        $legend.Add("  <text x=`"$(Format-Coordinate ($lx + 170))`" y=`"$(Format-Coordinate $ly)`" class=`"share`" text-anchor=`"end`">$(Format-Share $item.share)</text>")
    }

    $desc = 'Sprachen nach Codeumfang: ' + (($items | ForEach-Object { "$($_.name) $(Format-Share $_.share)" }) -join ', ') + '.'

    return @"
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="240" viewBox="0 0 400 240" role="img" aria-labelledby="t d">
  <title id="t">Sprachen</title>
  <desc id="d">$(ConvertTo-XmlText $desc)</desc>
  <style>
    text { font-family: $svgFont; }
    .h { font-size: 15px; font-weight: 600; fill: $($T.Text); }
    .sub { font-size: 12px; fill: $($T.Text2); }
    .name { font-size: 13px; fill: $($T.Text); }
    .share { font-size: 13px; fill: $($T.Text2); }
    .note { font-size: 11px; fill: $($T.Muted); }
  </style>
  <defs>
    <clipPath id="bar"><rect x="20" y="70" width="360" height="8" rx="4"/></clipPath>
  </defs>
  <rect x="0.5" y="0.5" width="399" height="239" rx="10" fill="$($T.Surface)" stroke="$($T.Border)"/>
  <text x="20" y="32" class="h">Sprachen</text>
  <text x="20" y="51" class="sub">nach Codeumfang in $($S.projects) Projekten</text>
  <g clip-path="url(#bar)">
$($segments -join "`n")
  </g>
$($legend -join "`n")
  <text x="20" y="222" class="note">Zählung von GitHub, ohne eingebundenen Fremdcode</text>
</svg>
"@
}

function New-ReadmeBlock([System.Collections.IDictionary] $S, [string] $DateText) {
    $years = @($S.commitsByYear.Keys)
    $currentYear = $years[-1]
    $statsAlt = "GitHub in Zahlen, Stand $DateText`: $(Format-Count $S.commits) Commits, davon " +
        "$(Format-Count ([long]$S.commitsByYear[$currentYear])) im Jahr $currentYear; $($S.projects) Projekte, " +
        "davon $($S.projectsPrivate) privat; auf GitHub seit $($S.memberSince)."
    $langAlt = 'Sprachen nach Codeumfang: ' + (($S.languages | ForEach-Object { "$($_.name) $(Format-Share $_.share)" }) -join ', ') + '.'
    return @"
<!-- stats:start -->
<!-- Dieser Block wird von scripts/Statistik-aktualisieren.ps1 geschrieben – Änderungen hier gehen beim nächsten Lauf verloren. -->
<div align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/stats-dark.svg">
  <img src="assets/stats-light.svg" width="400" alt="$(ConvertTo-XmlText $statsAlt)">
</picture>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/languages-dark.svg">
  <img src="assets/languages-light.svg" width="400" alt="$(ConvertTo-XmlText $langAlt)">
</picture>
</div>
<!-- stats:end -->
"@
}

function New-Outputs([System.Collections.IDictionary] $S, [string] $IsoDate, [string] $Readme) {
    $dateText = [datetime]::ParseExact($IsoDate, 'yyyy-MM-dd', $inv).ToString('dd.MM.yyyy', $de)
    $outputs = [ordered]@{}
    foreach ($name in $themes.Keys) {
        $outputs[(Join-Path $assetsDir "stats-$name.svg")] = New-StatsSvg $themes[$name] $S $dateText
        $outputs[(Join-Path $assetsDir "languages-$name.svg")] = New-LanguagesSvg $themes[$name] $S
    }

    $record = [ordered]@{ updated = $IsoDate }
    foreach ($key in $S.Keys) {
        $record[$key] = $S[$key]
    }
    $outputs[$statsPath] = $record | ConvertTo-Json -Depth 5

    $pattern = [regex]::new('<!-- stats:start -->.*?<!-- stats:end -->', 'Singleline')
    $match = $pattern.Match($Readme)
    if (-not $match.Success) {
        throw 'Im README fehlen die Markierungen <!-- stats:start --> und <!-- stats:end -->.'
    }
    $outputs[$readmePath] = $Readme.Substring(0, $match.Index) + (New-ReadmeBlock $S $dateText) +
        $Readme.Substring($match.Index + $match.Length)

    # Alles mit LF und abschließendem Zeilenumbruch, wie im Repository (.gitattributes).
    foreach ($key in @($outputs.Keys)) {
        $outputs[$key] = ($outputs[$key] -replace "`r`n", "`n").TrimEnd("`n") + "`n"
    }
    return $outputs
}

try {
    Schritt "Konto prüfen"
    if ($inActions -and -not $env:GH_TOKEN) {
        Fehler 'GH_TOKEN ist leer – das Secret STATS_TOKEN fehlt im Repository. Nichts geschrieben.'
        exit 1
    }
    $viewer = (Invoke-GitHubGraphQl -Query 'query { viewer { id login createdAt } }')['viewer']
    if ($viewer['login'] -ne $Konto) {
        Fehler "Das Token gehört zu „$($viewer['login'])“, gezählt werden soll „$Konto“."
        exit 1
    }
    $memberSince = [int](ConvertTo-IsoDate $viewer['createdAt']).Substring(0, 4)
    $berlin = [System.TimeZoneInfo]::FindSystemTimeZoneById('Europe/Berlin')
    $today = [System.TimeZoneInfo]::ConvertTimeFromUtc([datetime]::UtcNow, $berlin)
    $currentYear = $today.Year
    Hinweis "$Konto, auf GitHub seit $memberSince"

    Schritt 'Repositories und Commits zählen'
    $yearFields = ($memberSince..$currentYear | ForEach-Object {
            'y{0}: history(author: {{ id: $authorId }}, since: "{0}-01-01T00:00:00Z", until: "{0}-12-31T23:59:59Z") {{ totalCount }}' -f $_
        }) -join "`n              "
    $repoQuery = @'
query($authorId: ID!, $cursor: String) {
  viewer {
    repositories(first: 20, after: $cursor, ownerAffiliations: OWNER, orderBy: { field: NAME, direction: ASC }) {
      pageInfo { hasNextPage endCursor }
      nodes {
        name
        isPrivate
        isFork
        languages(first: 30) { edges { size node { name } } }
        defaultBranchRef {
          target {
            ... on Commit {
              total: history(author: { id: $authorId }) { totalCount }
              __YEARS__
            }
          }
        }
      }
    }
  }
}
'@.Replace('__YEARS__', $yearFields)

    $repos = [System.Collections.Generic.List[hashtable]]::new()
    $cursor = $null
    do {
        $connection = (Invoke-GitHubGraphQl -Query $repoQuery -Variables @{ authorId = $viewer['id']; cursor = $cursor })['viewer']['repositories']
        foreach ($node in $connection['nodes']) {
            $repos.Add($node)
        }
        $cursor = $connection['pageInfo']['endCursor']
    } while ($connection['pageInfo']['hasNextPage'])

    $excluded = @($AusgeschlosseneRepos -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    $names = @($repos | ForEach-Object { $_['name'] })
    $unmatched = @($excluded | Where-Object { $names -notcontains $_ })
    if ($unmatched.Count -gt 0) {
        # Namen bewusst nicht ausgeben: Sie stammen aus einem Secret und können private Repos nennen.
        Fehler "$($unmatched.Count) Ausschlussname(n) passt/passen zu keinem eigenen Repository. Nichts geschrieben."
        exit 1
    }

    $commitsByYear = [ordered]@{}
    foreach ($y in $memberSince..$currentYear) {
        $commitsByYear["$y"] = [long]0
    }
    [long]$commits = 0
    $projectsPublic = 0
    $projectsPrivate = 0
    $languageBytes = @{}
    foreach ($repo in $repos) {
        if ($excluded -contains $repo['name']) {
            continue
        }
        $branch = $repo['defaultBranchRef']
        if ($null -ne $branch -and $null -ne $branch['target']) {
            $target = $branch['target']
            $commits += [long]$target['total']['totalCount']
            foreach ($y in @($commitsByYear.Keys)) {
                $commitsByYear[$y] += [long]$target["y$y"]['totalCount']
            }
        }
        if ($repo['isFork'] -or $repo['name'] -eq $Konto) {
            continue
        }
        if ($repo['isPrivate']) { $projectsPrivate++ } else { $projectsPublic++ }
        foreach ($edge in $repo['languages']['edges']) {
            $language = $edge['node']['name']
            $languageBytes[$language] = ($languageBytes[$language] ?? [long]0) + [long]$edge['size']
        }
    }

    # Jahre vor dem ersten eigenen Commit tragen nichts bei – die Säulen beginnen beim ersten Commit.
    $firstActive = @($commitsByYear.Keys | Where-Object { $commitsByYear[$_] -gt 0 } | Select-Object -First 1)
    $trimmed = [ordered]@{}
    $started = $false
    foreach ($y in $commitsByYear.Keys) {
        if ($firstActive.Count -gt 0 -and $y -eq $firstActive[0]) { $started = $true }
        if ($started -or $y -eq "$currentYear") { $trimmed[$y] = $commitsByYear[$y] }
    }

    # Die fünf größten zugeordneten Sprachen einzeln, alles andere als „Sonstige“.
    [double]$totalBytes = ($languageBytes.Values | Measure-Object -Sum).Sum
    $languages = [System.Collections.Generic.List[object]]::new()
    if ($totalBytes -gt 0) {
        $top = @($languageBytes.GetEnumerator() |
                Where-Object { $languageSlots.Contains($_.Key) } |
                Sort-Object -Property @{ Expression = 'Value'; Descending = $true }, @{ Expression = 'Key' } |
                Select-Object -First 5)
        [double]$shown = 0
        foreach ($entry in $top) {
            $share = [Math]::Round(100.0 * $entry.Value / $totalBytes, 1)
            $languages.Add([ordered]@{ name = $entry.Key; slot = $languageSlots[$entry.Key]; share = $share })
            $shown += $share
        }
        $rest = [Math]::Round(100.0 - $shown, 1)
        if ($rest -gt 0) {
            $languages.Add([ordered]@{ name = 'Sonstige'; slot = $null; share = $rest })
        }
    }

    $stats = [ordered]@{
        projects        = $projectsPublic + $projectsPrivate
        projectsPublic  = $projectsPublic
        projectsPrivate = $projectsPrivate
        commits         = $commits
        commitsByYear   = $trimmed
        memberSince     = $memberSince
        languages       = $languages
    }

    Hinweis "Projekte: $($stats.projects) ($projectsPublic öffentlich, $projectsPrivate privat)"
    Hinweis "Commits: $(Format-Count $commits), davon $currentYear`: $(Format-Count $trimmed["$currentYear"])"
    Hinweis "Je Jahr: $(($trimmed.Keys | ForEach-Object { "$_=$($trimmed[$_])" }) -join ' ')"
    Hinweis "Sprachen: $(($languages | ForEach-Object { "$($_.name) $(Format-Share $_.share)" }) -join ', ')"
    Hinweis "Ausgeschlossen: $($excluded.Count) Repository/Repositories"

    $previous = $null
    if (Test-Path -LiteralPath $statsPath) {
        $previous = Get-Content -LiteralPath $statsPath -Raw | ConvertFrom-Json -AsHashtable
    }
    if ($null -ne $previous -and -not $Erzwingen) {
        if ($commits -lt [long]$previous['commits']) {
            Fehler "Commits sinken von $(Format-Count $previous['commits']) auf $(Format-Count $commits) – fehlt dem Token das Leserecht auf private Repositories? Nichts geschrieben (bewusst: -Erzwingen)."
            exit 1
        }
        if ([int]$previous['projectsPrivate'] -gt 0 -and $projectsPrivate -eq 0) {
            Fehler 'Keine privaten Projekte mehr sichtbar – fehlt dem Token das Leserecht? Nichts geschrieben (bewusst: -Erzwingen).'
            exit 1
        }
    }

    Schritt 'Karten erzeugen'
    $readme = (Get-Content -LiteralPath $readmePath -Raw) -replace "`r`n", "`n"

    # WOZU: Erst mit dem bisherigen Datum rendern. Ist dann alles gleich, hat sich keine Zahl
    # geändert – das Datum bleibt stehen und der Workflow findet nichts zu committen.
    $unchanged = $false
    if ($null -ne $previous -and $previous['updated']) {
        $candidate = New-Outputs $stats (ConvertTo-IsoDate $previous['updated']) $readme
        $unchanged = $true
        foreach ($path in $candidate.Keys) {
            $existing = if (Test-Path -LiteralPath $path) { (Get-Content -LiteralPath $path -Raw) -replace "`r`n", "`n" } else { $null }
            if ($existing -ne $candidate[$path]) {
                $unchanged = $false
                break
            }
        }
    }
    if ($unchanged) {
        Hinweis 'Keine Änderung – nichts zu schreiben.'
        exit 0
    }

    $outputs = New-Outputs $stats $today.ToString('yyyy-MM-dd', $inv) $readme
    if ($Probelauf) {
        Hinweis "Probelauf – würde $($outputs.Count) Dateien schreiben:"
        foreach ($path in $outputs.Keys) {
            Hinweis "  $([System.IO.Path]::GetRelativePath($repoRoot, $path))"
        }
        exit 0
    }

    $null = New-Item -ItemType Directory -Force -Path $assetsDir
    foreach ($path in $outputs.Keys) {
        [System.IO.File]::WriteAllText($path, $outputs[$path], $utf8NoBom)
        Hinweis "geschrieben: $([System.IO.Path]::GetRelativePath($repoRoot, $path))"
    }
    exit 0
} catch {
    Fehler $_.Exception.Message
    exit 1
}
