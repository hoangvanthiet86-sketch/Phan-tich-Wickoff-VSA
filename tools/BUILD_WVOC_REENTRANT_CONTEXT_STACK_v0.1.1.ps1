param(
    [string]$IncludeDir = "C:\Program Files (x86)\AmiBroker\Formulas\Include"
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function P([string]$name) { Join-Path $IncludeDir $name }

function Require-File([string]$name) {
    $path = P $name
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing required source: $path"
    }
}

function Write-Utf8NoBom([string]$path,[string]$text) {
    [System.IO.File]::WriteAllText($path,$text,$Utf8NoBom)
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        throw "UTF-8 BOM verification failed: $path"
    }
}

function Remove-Section([string]$text,[string]$title) {
    $escaped = [regex]::Escape($title)
    $pattern = '(?s)_SECTION_BEGIN\("' + $escaped + '"\);.*?_SECTION_END\(\);'
    $next = [regex]::Replace($text,$pattern,'')
    if ($next -eq $text) {
        throw "Expected section not found: $title"
    }
    return $next
}

function Remove-OutputStatements([string]$text) {
    $lines = $text -split "\r?\n"
    $out = New-Object System.Collections.Generic.List[string]
    $skip = $false

    foreach ($line in $lines) {
        $trim = $line.TrimStart()

        if (-not $skip) {
            $startsOutput =
                $trim.StartsWith("AddColumn(") -or
                $trim.StartsWith("AddTextColumn(") -or
                $trim.StartsWith("AddMultiTextColumn(") -or
                $trim.StartsWith("Plot(") -or
                $trim.StartsWith("SetChartOptions(") -or
                $trim.StartsWith("Filter =") -or
                $trim.StartsWith("Title =")

            if ($startsOutput) {
                if (-not $trim.Contains(";")) { $skip = $true }
                continue
            }
        }
        else {
            if ($trim.Contains(";")) { $skip = $false }
            continue
        }

        $out.Add($line)
    }

    if ($skip) { throw "Unterminated presentation/output statement while stripping source." }
    return ($out -join [Environment]::NewLine)
}

function Strip-DirectivesAndSections([string]$text) {
    $lines = $text -split "\r?\n"
    $out = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        $trim = $line.Trim()
        if ($trim.StartsWith("#include")) { continue }
        if ($trim.StartsWith("#pragma")) { continue }
        if ($trim.StartsWith("SetBarsRequired(")) { continue }
        if ($trim.StartsWith("_SECTION_BEGIN(")) { continue }
        if ($trim.StartsWith("_SECTION_END(")) { continue }
        $out.Add($line)
    }
    return ($out -join [Environment]::NewLine)
}

function Split-FunctionsAndBody([string]$text,[string]$sourceName) {
    $lines = $text -split "\r?\n"
    $helpers = New-Object System.Collections.Generic.List[string]
    $body = New-Object System.Collections.Generic.List[string]

    $i = 0
    while ($i -lt $lines.Count) {
        $line = $lines[$i]
        if ($line -match '^\s*function\s+[A-Za-z_][A-Za-z0-9_]*\s*\(') {
            $block = New-Object System.Collections.Generic.List[string]
            $depth = 0
            $opened = $false

            while ($i -lt $lines.Count) {
                $current = $lines[$i]
                $block.Add($current)

                $opens = ([regex]::Matches($current,'\{')).Count
                $closes = ([regex]::Matches($current,'\}')).Count
                if ($opens -gt 0) { $opened = $true }
                $depth += $opens - $closes
                $i++

                if ($opened -and $depth -eq 0) { break }
            }

            if (-not $opened -or $depth -ne 0) {
                throw "Function extraction failed in $sourceName"
            }

            $helpers.Add(($block -join [Environment]::NewLine))
            $helpers.Add("")
            continue
        }

        $body.Add($line)
        $i++
    }

    return @{
        Helpers = ($helpers -join [Environment]::NewLine)
        Body = ($body -join [Environment]::NewLine)
    }
}

function Normalize-Source([string]$name) {
    Require-File $name
    $text = Get-Content -LiteralPath (P $name) -Raw

    switch ($name) {
        "WyckoffVSA_Core_Runtime_v0.2.afl" {
            $text = Remove-Section $text "11. Chart Output"
            $text = Remove-Section $text "12. Exploration"
        }
        "WyckoffVSA_Confirmation_v1.0.afl" {
            $text = Remove-Section $text "25. Confirmation exploration"
        }
        "WyckoffVSA_Event_StoppingClimacticAbsorption_v0.1.afl" {
            $text = Remove-Section $text "49. Effort Result Event exploration"
        }
        "WyckoffVSA_Event_SupplyTest_v1.0.afl" {
            $text = Remove-Section $text "29. Supply Test Event exploration"
        }
        "WyckoffVSA_Event_SpringShakeout_v0.1.afl" {
            $text = Remove-Section $text "33. Spring Shakeout exploration"
        }
        "WyckoffVSA_Event_UpthrustUTAD_v0.1.afl" {
            $text = Remove-Section $text "37. Upthrust exploration"
        }
        "WyckoffVSA_Event_SOSLPS_v0.1.afl" {
            $text = Remove-Section $text "43. SOS LPS exploration"
        }
        "WyckoffVSA_StructuralSequence_PhaseA_v0.1.afl" {
            $text = Remove-Section $text "52. Structural Sequence exploration"
        }
        "WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl" {
            $text = Remove-Section $text "55. D29 snapshot exploration"
        }
        "WyckoffVSA_RangeContext_SOWLPSY_v0.1.afl" {
            $text = Remove-Section $text "65. SOW/LPSY exploration"
        }
        "WyckoffVSA_PhaseContext_PublicSnapshot_v0.1.afl" {
            $text = Remove-Section $text "76. Phase Context public Exploration contract"
        }
        "WyckoffVSA_CompositeIndicator_v0.1.afl" {
            $text = Remove-Section $text "85. Composite exploration-first public interface"
            $old = 'WCI_RuntimeLastBarIsProvisional = ParamToggle("Composite: last bar provisional","No|Yes",0);'
            if (-not $text.Contains($old)) {
                throw "Composite runtime Param binding text not found."
            }
            $text = $text.Replace($old,'WCI_RuntimeLastBarIsProvisional = WVRC_LastBarProvisional;')
        }
    }

    # Mixed analytical/presentation sections are retained, then only output calls are removed.
    $text = Remove-OutputStatements $text
    $text = Strip-DirectivesAndSections $text

    return $text
}

$sources = @(
    "WyckoffVSA_Core_Runtime_v0.2.afl",
    "WyckoffVSA_Candidate_Runtime_v0.2.afl",
    "WyckoffVSA_StructureLocation_Runtime_v0.2.afl",
    "WyckoffVSA_Confirmation_v1.0.afl",
    "WyckoffVSA_Event_StoppingClimacticAbsorption_v0.1.afl",
    "WyckoffVSA_Event_SupplyTest_v1.0.afl",
    "WyckoffVSA_Event_SpringShakeout_v0.1.afl",
    "WyckoffVSA_Event_UpthrustUTAD_v0.1.afl",
    "WyckoffVSA_Event_SOSLPS_v0.1.afl",
    "WyckoffVSA_StructuralSequence_PhaseA_v0.1.afl",
    "WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl",
    "WyckoffVSA_RangeContext_SOWLPSY_v0.1.afl",
    "WyckoffVSA_PhaseContext_InputFacade_v0.1.afl",
    "WyckoffVSA_PhaseContext_v0.1.afl",
    "WyckoffVSA_PhaseContext_PublicSnapshot_v0.1.afl",
    "WyckoffVSA_PhaseContext_ConsumerFacade_v0.1.afl",
    "WyckoffVSA_CompositeIndicator_v0.1.afl"
)

$allHelpers = New-Object System.Collections.Generic.List[string]
$allBody = New-Object System.Collections.Generic.List[string]

foreach ($source in $sources) {
    Write-Host "Processing $source"
    $normalized = Normalize-Source $source
    $split = Split-FunctionsAndBody $normalized $source

    if ($split.Helpers.Trim().Length -gt 0) {
        $allHelpers.Add("/* Helpers from $source */")
        $allHelpers.Add($split.Helpers)
    }

    $allBody.Add("/* Analytical body from $source */")
    $allBody.Add($split.Body)
    $allBody.Add("")
}


# Fail closed on duplicate helper function names across the flattened stack.
$helperCombinedForAudit = ($allHelpers -join [Environment]::NewLine)
$functionNames = [regex]::Matches(
    $helperCombinedForAudit,
    '(?m)^\s*function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('
) | ForEach-Object { $_.Groups[1].Value }

$duplicates = $functionNames | Group-Object | Where-Object { $_.Count -gt 1 }
if ($duplicates) {
    $names = ($duplicates | ForEach-Object { $_.Name }) -join ", "
    throw "Duplicate helper function names detected: $names"
}

$helperHeader = @"
/*
    AUTO-GENERATED One-Click Context Helpers v0.1.
    Builder: BUILD_WVOC_REENTRANT_CONTEXT_STACK_v0.1.1.ps1
    Helper definitions only. No analytical execution.
    Generated UTF-8 without BOM.
*/
"@

$bodyHeader = @"
/*
    AUTO-GENERATED One-Click Context Body v0.1.
    Builder: BUILD_WVOC_REENTRANT_CONTEXT_STACK_v0.1.ps1
    Analytical execution body only. No helper definitions, Params, output columns,
    plots, Filter assignments or include directives.

    This file is intentionally designed for repeated context execution under
    different timeframe/foreign contexts. It must not be protected by include-once semantics.
*/
"@

$helpersText = $helperHeader + [Environment]::NewLine + ($allHelpers -join [Environment]::NewLine)
$bodyText = $bodyHeader + [Environment]::NewLine + ($allBody -join [Environment]::NewLine)

$forbiddenBody = @(
    "#include",
    "#pragma",
    "SetBarsRequired(",
    "function ",
    "AddColumn(",
    "AddTextColumn(",
    "AddMultiTextColumn(",
    "Plot(",
    "SetChartOptions(",
    "Filter =",
    "Param(",
    "ParamToggle(",
    "ParamStr("
)

foreach ($bad in $forbiddenBody) {
    if (($allBody -join [Environment]::NewLine).Contains($bad)) {
        throw "Generated analytical body contains forbidden token: $bad"
    }
}

$requiredBody = @(
    "RobustATR",
    "NoDemandCandidateCode",
    "SL_PivotHighEventCode",
    "WPC_L_ContextPresent",
    "WPCF_L_PublicActive",
    "WPCF_CurrentRangeContextCount",
    "WCI_ContextMultiplicityCode",
    "WCI_PhaseStateCode",
    "WCI_FamilyHypothesisCode",
    "WCI_DirectionalContextCode"
)

foreach ($need in $requiredBody) {
    if (-not $bodyText.Contains($need)) {
        throw "Generated body missing required analytical surface: $need"
    }
}

if ($helpersText.Contains("AddColumn(") -or $helpersText.Contains("Filter =")) {
    throw "Generated helper file unexpectedly contains presentation/output code."
}

$helpersPath = P "WyckoffVSA_OneClickContextHelpers_Generated_v0.1.afl"
$bodyPath = P "WyckoffVSA_OneClickContextBody_Generated_v0.1.afl"

Write-Utf8NoBom $helpersPath $helpersText
Write-Utf8NoBom $bodyPath $bodyText

$helpersHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $helpersPath).Hash
$bodyHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $bodyPath).Hash

Write-Host ""
Write-Host "WVOC re-entrant context build complete. BUILDER=v0.1.1"
Write-Host ("HELPERS SHA256={0}" -f $helpersHash)
Write-Host ("BODY    SHA256={0}" -f $bodyHash)
Write-Host "Canonical sources were read only."
Write-Host "Next gate: native compile probe before any One-Click production entrypoint."
