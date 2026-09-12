param(
    [string]$IncludeDir = "C:\Program Files (x86)\AmiBroker\Formulas\Include",
    [string]$FormulaDir = "C:\Program Files (x86)\AmiBroker\Formulas\afl"
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function P([string]$name) { Join-Path $IncludeDir $name }
function PF([string]$name) { Join-Path $FormulaDir $name }

function Require-File([string]$name) {
    $path = P $name
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing required file: $path"
    }
}

function Write-Utf8NoBom([string]$path, [string]$text) {
    [System.IO.File]::WriteAllText($path, $text, $Utf8NoBom)
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        throw "UTF-8 BOM verification failed: $path"
    }
}

function Build-RuntimeFile(
    [string]$SourceName,
    [string]$TargetName,
    [hashtable]$Replacements
) {
    $sourcePath = P $SourceName
    $targetPath = P $TargetName
    Require-File $SourceName

    $text = Get-Content -LiteralPath $sourcePath -Raw
    foreach ($old in $Replacements.Keys) {
        if (-not $text.Contains($old)) {
            throw ("Expected source text not found in {0}: {1}" -f $SourceName, $old)
        }
        $text = $text.Replace($old, $Replacements[$old])
    }

    $header = @"
/*
    AUTO-GENERATED RUNTIME v0.2 VARIANT.
    Source oracle: $SourceName
    Builder: BUILD_WVRC_PHASE_COMPOSITE_RUNTIME_STACK_v0.2.2.ps1
    Runtime-only dependency redirection. Analytical formulas are unchanged.
    Encoding: UTF-8 WITHOUT BOM for AmiBroker 6.20.01 compatibility testing.
    DO NOT treat this generated file as a canonical v0.1/v1.0 source.
*/
"@
    $text = $header + $text

    $forbidden = @(
        "<WyckoffVSA_Core_v1.0.afl>",
        "<WyckoffVSA_Candidate_v1.0.afl>",
        "<WyckoffVSA_StructureLocation_v1.0.afl>",
        "<WyckoffVSA_Confirmation_v1.0.afl>",
        "<WyckoffVSA_Event_StoppingClimacticAbsorption_v0.1.afl>",
        "<WyckoffVSA_Event_SupplyTest_v1.0.afl>",
        "<WyckoffVSA_Event_SpringShakeout_v0.1.afl>",
        "<WyckoffVSA_Event_UpthrustUTAD_v0.1.afl>",
        "<WyckoffVSA_Event_SOSLPS_v0.1.afl>",
        "<WyckoffVSA_StructuralSequence_PhaseA_v0.1.afl>",
        "<WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl>",
        "<WyckoffVSA_RangeContext_SOWLPSY_v0.1.afl>",
        "<WyckoffVSA_PhaseContext_InputFacade_v0.1.afl>",
        "<WyckoffVSA_PhaseContext_v0.1.afl>",
        "<WyckoffVSA_PhaseContext_PublicSnapshot_v0.1.afl>",
        "<WyckoffVSA_PhaseContext_ConsumerFacade_v0.1.afl>"
    )
    foreach ($bad in $forbidden) {
        if ($text.Contains($bad)) {
            throw ("Runtime dependency isolation failed in {0}; canonical include remains: {1}" -f $TargetName, $bad)
        }
    }

    Write-Utf8NoBom $targetPath $text
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetPath).Hash
    Write-Host ("GENERATED NO-BOM: {0}  SHA256={1}" -f $TargetName, $hash)
}

Write-Host "Building Wyckoff VSA Runtime v0.2 Phase/Composite stack..."
Write-Host "Builder revision: v0.2.2 / 20260912-C / UTF8-NO-BOM"
Write-Host "Include directory: $IncludeDir"
Write-Host "Formula directory: $FormulaDir"

if (-not (Test-Path -LiteralPath $FormulaDir)) {
    New-Item -ItemType Directory -Path $FormulaDir -Force | Out-Null
}

Require-File "WyckoffVSA_RuntimeConfig_v0.2.afl"
Require-File "WyckoffVSA_Core_Runtime_v0.2.afl"
Require-File "WyckoffVSA_Candidate_Runtime_v0.2.afl"
Require-File "WyckoffVSA_StructureLocation_Runtime_v0.2.afl"

Build-RuntimeFile "WyckoffVSA_Confirmation_v1.0.afl" "WyckoffVSA_Confirmation_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_StructureLocation_v1.0.afl>' = '#include_once <WyckoffVSA_StructureLocation_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_Event_StoppingClimacticAbsorption_v0.1.afl" "WyckoffVSA_Event_StoppingClimacticAbsorption_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_Confirmation_v1.0.afl>' = '#include_once <WyckoffVSA_Confirmation_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_Event_SupplyTest_v1.0.afl" "WyckoffVSA_Event_SupplyTest_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_Confirmation_v1.0.afl>' = '#include_once <WyckoffVSA_Confirmation_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_Event_SpringShakeout_v0.1.afl" "WyckoffVSA_Event_SpringShakeout_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_Confirmation_v1.0.afl>' = '#include_once <WyckoffVSA_Confirmation_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_Event_UpthrustUTAD_v0.1.afl" "WyckoffVSA_Event_UpthrustUTAD_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_Confirmation_v1.0.afl>' = '#include_once <WyckoffVSA_Confirmation_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_Event_SOSLPS_v0.1.afl" "WyckoffVSA_Event_SOSLPS_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_Confirmation_v1.0.afl>' = '#include_once <WyckoffVSA_Confirmation_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_StructuralSequence_PhaseA_v0.1.afl" "WyckoffVSA_StructuralSequence_PhaseA_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_Event_StoppingClimacticAbsorption_v0.1.afl>' = '#include_once <WyckoffVSA_Event_StoppingClimacticAbsorption_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl" "WyckoffVSA_StructuralSequence_PhaseA_Snapshot_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_StructuralSequence_PhaseA_v0.1.afl>' = '#include_once <WyckoffVSA_StructuralSequence_PhaseA_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_RangeContext_SOWLPSY_v0.1.afl" "WyckoffVSA_RangeContext_SOWLPSY_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_StructuralSequence_PhaseA_Snapshot_v0.1.afl>' = '#include_once <WyckoffVSA_StructuralSequence_PhaseA_Snapshot_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_PhaseContext_InputFacade_v0.1.afl" "WyckoffVSA_PhaseContext_InputFacade_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_Event_SupplyTest_v1.0.afl>' = '#include_once <WyckoffVSA_Event_SupplyTest_Runtime_v0.2.afl>';
    '#include_once <WyckoffVSA_Event_SpringShakeout_v0.1.afl>' = '#include_once <WyckoffVSA_Event_SpringShakeout_Runtime_v0.2.afl>';
    '#include_once <WyckoffVSA_Event_UpthrustUTAD_v0.1.afl>' = '#include_once <WyckoffVSA_Event_UpthrustUTAD_Runtime_v0.2.afl>';
    '#include_once <WyckoffVSA_Event_SOSLPS_v0.1.afl>' = '#include_once <WyckoffVSA_Event_SOSLPS_Runtime_v0.2.afl>';
    '#include_once <WyckoffVSA_RangeContext_SOWLPSY_v0.1.afl>' = '#include_once <WyckoffVSA_RangeContext_SOWLPSY_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_PhaseContext_v0.1.afl" "WyckoffVSA_PhaseContext_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_PhaseContext_InputFacade_v0.1.afl>' = '#include_once <WyckoffVSA_PhaseContext_InputFacade_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_PhaseContext_PublicSnapshot_v0.1.afl" "WyckoffVSA_PhaseContext_PublicSnapshot_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_PhaseContext_v0.1.afl>' = '#include_once <WyckoffVSA_PhaseContext_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_PhaseContext_ConsumerFacade_v0.1.afl" "WyckoffVSA_PhaseContext_ConsumerFacade_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_PhaseContext_PublicSnapshot_v0.1.afl>' = '#include_once <WyckoffVSA_PhaseContext_PublicSnapshot_Runtime_v0.2.afl>'
}
Build-RuntimeFile "WyckoffVSA_CompositeIndicator_v0.1.afl" "WyckoffVSA_CompositeIndicator_Runtime_v0.2.afl" @{
    '#include_once <WyckoffVSA_PhaseContext_ConsumerFacade_v0.1.afl>' = '#include_once <WyckoffVSA_PhaseContext_ConsumerFacade_Runtime_v0.2.afl>';
    'WCI_RuntimeLastBarIsProvisional = ParamToggle("Composite: last bar provisional","No|Yes",0);' = 'WCI_RuntimeLastBarIsProvisional = WVRC_LastBarProvisional;'
}

$confirmationProbe = @'
/* Runtime v0.2 generated-stack first-layer sanity probe. */
#pragma nocache
SetBarsRequired(sbrAll,sbrAll);
#include_once <WyckoffVSA_RuntimeConfig_v0.2.afl>
#include_once <WyckoffVSA_Confirmation_Runtime_v0.2.afl>
Filter = 1;
AddTextColumn(Name(),"PROBE Symbol");
AddColumn(DateTime(),"PROBE Date",formatDateTime);
AddColumn(BarIndex(),"PROBE BarIndex",1.0);
AddColumn(WVRC_ConfigValid,"Runtime Config Valid",1.0);
AddColumn(SL_ConfigValid,"SL Config Valid",1.0);
AddColumn(NoDemandCandidateCode,"No Demand Code",1.0);
AddColumn(NoSupplyCandidateCode,"No Supply Code",1.0);
AddTextColumn("CONFIRMATION_RUNTIME_V02_FIRST_LAYER_PROBE_20260912_C","PROBE VERSION");
'@
Write-Utf8NoBom (PF "WyckoffVSA_Confirmation_Runtime_v0.2_Probe.afl") $confirmationProbe
Write-Host "INSTALLED PROBE: WyckoffVSA_Confirmation_Runtime_v0.2_Probe.afl"

Write-Host ""
Write-Host "Runtime Phase/Composite stack build complete."
Write-Host "Generated runtime files verified UTF-8 WITHOUT BOM."
Write-Host "Canonical v0.1/v1.0 files were READ ONLY and were not modified."
Write-Host "First diagnostic if Composite stays blank: WyckoffVSA_Confirmation_Runtime_v0.2_Probe.afl"
