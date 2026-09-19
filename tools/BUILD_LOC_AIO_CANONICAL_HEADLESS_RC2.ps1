param(
    [string]$IncludeDir = "C:\Program Files (x86)\AmiBroker\Formulas\Include",
    [string]$RepoRoot = "E:\WyckoffVSA"
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$RuntimeFiles = @(
    "WyckoffVSA_RuntimeConfig_v0.2.afl",
    "WyckoffVSA_Core_Runtime_v0.2.afl",
    "WyckoffVSA_Candidate_Runtime_v0.2.afl",
    "WyckoffVSA_StructureLocation_Runtime_v0.2.afl",
    "WyckoffVSA_Confirmation_Runtime_v0.2.afl",
    "WyckoffVSA_Event_StoppingClimacticAbsorption_Runtime_v0.2.afl",
    "WyckoffVSA_Event_SupplyTest_Runtime_v0.2.afl",
    "WyckoffVSA_Event_SpringShakeout_Runtime_v0.2.afl",
    "WyckoffVSA_Event_UpthrustUTAD_Runtime_v0.2.afl",
    "WyckoffVSA_Event_SOSLPS_Runtime_v0.2.afl",
    "WyckoffVSA_StructuralSequence_PhaseA_Runtime_v0.2.afl",
    "WyckoffVSA_StructuralSequence_PhaseA_Snapshot_Runtime_v0.2.afl",
    "WyckoffVSA_RangeContext_SOWLPSY_Runtime_v0.2.afl",
    "WyckoffVSA_PhaseContext_InputFacade_Runtime_v0.2.afl",
    "WyckoffVSA_PhaseContext_Runtime_v0.2.afl",
    "WyckoffVSA_PhaseContext_PublicSnapshot_Runtime_v0.2.afl",
    "WyckoffVSA_PhaseContext_ConsumerFacade_Runtime_v0.2.afl",
    "WyckoffVSA_CompositeIndicator_Runtime_v0.2.afl"
)

function Write-NoBom([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Missing-RuntimeFiles {
    $m = @()
    foreach ($f in $RuntimeFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $IncludeDir $f))) {
            $m += $f
        }
    }
    return $m
}

# If generated Runtime v0.2 files are missing, try the project's approved builders.
$missing = Missing-RuntimeFiles
if ($missing.Count -gt 0) {
    $phaseBuilder = Join-Path $RepoRoot "tools\BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.2.ps1"

    if (Test-Path -LiteralPath $phaseBuilder) {
        Write-Host "Runtime v0.2 files missing. Running approved Phase/Composite builder..."
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $phaseBuilder -IncludeDir $IncludeDir
        if ($LASTEXITCODE -ne 0) {
            throw "Approved Phase/Composite runtime builder failed."
        }
    }
}

$missing = Missing-RuntimeFiles
if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing Runtime v0.2 files:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host ("  - " + $_) -ForegroundColor Red }
    Write-Host ""
    throw "Install/build the Runtime v0.2 Phase/Composite stack first."
}

function Remove-FunctionCalls {
    param(
        [string]$Text,
        [string[]]$Names
    )

    foreach ($name in $Names) {
        while ($true) {
            $pattern = "(?m)^[ \t]*" + [regex]::Escape($name) + "[ \t]*\("
            $match = [regex]::Match($Text, $pattern)
            if (-not $match.Success) { break }

            $start = $match.Index
            $open = $Text.IndexOf("(", $match.Index)
            if ($open -lt 0) { throw "Malformed call: $name" }

            $depth = 0
            $inString = $false
            $escape = $false
            $i = $open

            for (; $i -lt $Text.Length; $i++) {
                $ch = $Text[$i]

                if ($inString) {
                    if ($escape) {
                        $escape = $false
                        continue
                    }
                    if ($ch -eq '\') {
                        $escape = $true
                        continue
                    }
                    if ($ch -eq '"') {
                        $inString = $false
                    }
                    continue
                }

                if ($ch -eq '"') {
                    $inString = $true
                    continue
                }

                if ($ch -eq '(') { $depth++ }
                elseif ($ch -eq ')') {
                    $depth--
                    if ($depth -eq 0) {
                        $i++
                        break
                    }
                }
            }

            if ($depth -ne 0) {
                throw "Unbalanced parentheses while removing $name"
            }

            while ($i -lt $Text.Length -and [char]::IsWhiteSpace($Text[$i])) {
                $i++
            }
            if ($i -lt $Text.Length -and $Text[$i] -eq ';') {
                $i++
            }

            # Consume one trailing newline if present.
            if ($i -lt $Text.Length -and $Text[$i] -eq "`r") { $i++ }
            if ($i -lt $Text.Length -and $Text[$i] -eq "`n") { $i++ }

            $Text = $Text.Remove($start, $i - $start)
        }
    }

    return $Text
}

function Remove-StatementAssignment {
    param(
        [string]$Text,
        [string]$Variable
    )

    $pattern = "(?ms)^[ \t]*" + [regex]::Escape($Variable) + "[ \t]*=.*?;"
    return [regex]::Replace($Text, $pattern, "")
}

Write-Host "Building LOC AIO canonical HEADLESS Runtime v0.2 stack..."
Write-Host ("IncludeDir: " + $IncludeDir)

foreach ($f in $RuntimeFiles) {
    $src = Join-Path $IncludeDir $f
    $dstName = "LIO_HEADLESS_" + $f
    $dst = Join-Path $IncludeDir $dstName

    $text = Get-Content -LiteralPath $src -Raw

    # Explicit topological order is controlled by the RC2 top-level AFL.
    # Remove all nested include directives from each headless module.
    $text = [regex]::Replace(
        $text,
        '(?m)^[ \t]*#include(?:_once)?[^\r\n]*(?:\r?\n)?',
        ''
    )

    # Remove presentation calls only. Analytical arrays / loops / state
    # machines remain byte-for-byte otherwise.
    $text = Remove-FunctionCalls $text @(
        "AddColumn",
        "AddTextColumn",
        "AddMultiTextColumn",
        "Plot",
        "PlotShapes",
        "PlotText"
    )

    # Remove presentation/scanner-entry assignments that could override
    # the locked Loc All in one selection authority.
    $text = Remove-StatementAssignment $text "Filter"
    $text = Remove-StatementAssignment $text "Title"

    # Do not let included modules change the legacy sort.
    $text = [regex]::Replace(
        $text,
        '(?ms)^[ \t]*SetSortColumns[ \t]*\(.*?\)[ \t]*;',
        ''
    )

    $header = @"
/*
    AUTO-GENERATED LOC AIO HEADLESS RUNTIME.
    Source oracle: $f
    Builder: BUILD_LOC_AIO_CANONICAL_HEADLESS_RC2.ps1
    Changes are presentation/inclusion isolation only:
    - nested #include directives removed;
    - AddColumn/AddTextColumn/AddMultiTextColumn/Plot* removed;
    - Filter/Title/SetSortColumns presentation assignments removed.
    Analytical formulas, loops, thresholds and state machines are not rewritten.
*/
"@

    $text = $header + $text

    # Fail-closed validation.
    $forbidden = @(
        "AddColumn(",
        "AddTextColumn(",
        "AddMultiTextColumn(",
        "Plot(",
        "PlotShapes(",
        "PlotText("
    )
    foreach ($bad in $forbidden) {
        if ($text.Contains($bad)) {
            throw "Headless validation failed in $dstName; remaining token: $bad"
        }
    }

    if ([regex]::IsMatch($text, '(?m)^[ \t]*#include(?:_once)?')) {
        throw "Headless validation failed in $dstName; nested include remains."
    }

    Write-NoBom $dst $text
    $sha = (Get-FileHash -Algorithm SHA256 -LiteralPath $dst).Hash
    Write-Host ("HEADLESS OK: {0}  SHA256={1}" -f $dstName, $sha)
}

Write-Host ""
Write-Host "LOC AIO canonical headless stack build = PASS" -ForegroundColor Green
Write-Host "Next: open Loc_AllInOne_Wyckoff_Final_v1.0_RC2_CANONICAL.afl and Verify Syntax."
