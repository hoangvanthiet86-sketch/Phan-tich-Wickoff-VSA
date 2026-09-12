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
    [hashtable]$Replacements,
    [string[]]$ForbiddenIncludes
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
    Builder: BUILD_WVRC_SCANNER_RUNTIME_STACK_v0.2.3.ps1
    Runtime-only dependency/config redirection. Analytical formulas are unchanged.
    Encoding: UTF-8 WITHOUT BOM for AmiBroker 6.20.01 compatibility.
    Canonical v0.1 files remain reference oracles and are not modified.
*/
"@
    $text = $header + $text

    foreach ($bad in $ForbiddenIncludes) {
        if ($text.Contains($bad)) {
            throw ("Runtime dependency isolation failed in {0}; canonical include remains: {1}" -f $TargetName, $bad)
        }
    }

    Write-Utf8NoBom $targetPath $text
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetPath).Hash
    Write-Host ("GENERATED NO-BOM: {0}  SHA256={1}" -f $TargetName, $hash)
}

Write-Host "Building Wyckoff VSA Runtime v0.2 MTF/RS/Selection/Scanner stack..."
Write-Host "Builder revision: v0.2.3 / 20260912-D"
Write-Host "Include directory: $IncludeDir"
Write-Host "Formula directory: $FormulaDir"

if (-not (Test-Path -LiteralPath $FormulaDir)) {
    New-Item -ItemType Directory -Path $FormulaDir -Force | Out-Null
}

# Native-validated runtime base and Phase/Composite runtime stack must already exist.
Require-File "WyckoffVSA_RuntimeConfig_v0.2.afl"
Require-File "WyckoffVSA_StructureLocation_Runtime_v0.2.afl"
Require-File "WyckoffVSA_CompositeIndicator_Runtime_v0.2.afl"

# Canonical downstream sources are read only.
Require-File "WyckoffVSA_CompositeIndicator_SnapshotPublic_v0.1.afl"
Require-File "WyckoffVSA_MultiTimeframeContext_v0.1.afl"
Require-File "WyckoffVSA_RelativeStrengthContext_v0.1.afl"
Require-File "WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl"
Require-File "WyckoffVSA_CrossSymbolSelectionContext_ConsumerVersionGuard_v0.1.afl"
Require-File "WyckoffVSA_MarketScanner_v0.1.afl"

Build-RuntimeFile \
    "WyckoffVSA_CompositeIndicator_SnapshotPublic_v0.1.afl" \
    "WyckoffVSA_CompositeIndicator_SnapshotPublic_Runtime_v0.2.afl" \
    @{
        '#include_once <WyckoffVSA_CompositeIndicator_v0.1.afl>' = '#include_once <WyckoffVSA_CompositeIndicator_Runtime_v0.2.afl>'
    } \
    @('<WyckoffVSA_CompositeIndicator_v0.1.afl>')

Build-RuntimeFile \
    "WyckoffVSA_MultiTimeframeContext_v0.1.afl" \
    "WyckoffVSA_MultiTimeframeContext_Runtime_v0.2.afl" \
    @{
        '#include_once <WyckoffVSA_CompositeIndicator_SnapshotPublic_v0.1.afl>' = '#include_once <WyckoffVSA_CompositeIndicator_SnapshotPublic_Runtime_v0.2.afl>'
    } \
    @('<WyckoffVSA_CompositeIndicator_SnapshotPublic_v0.1.afl>')

Build-RuntimeFile \
    "WyckoffVSA_RelativeStrengthContext_v0.1.afl" \
    "WyckoffVSA_RelativeStrengthContext_Runtime_v0.2.afl" \
    @{
        '#include_once <WyckoffVSA_StructureLocation_v1.0.afl>' = '#include_once <WyckoffVSA_StructureLocation_Runtime_v0.2.afl>';
        'WRS_MarketBenchmarkSymbol = ParamStr("RS Market Benchmark","");' = 'WRS_MarketBenchmarkSymbol = WVRC_RSMarketSymbol;';
        'WRS_GroupBenchmarkSymbol = ParamStr("RS Group Benchmark","");' = 'WRS_GroupBenchmarkSymbol = WVRC_RSGroupSymbol;';
        'WRS_AdjustmentBasisDeclaration = ParamStr("RS Adjustment Basis","NOT VERIFIED");' = 'WRS_AdjustmentBasisDeclaration = WVRC_RSAdjustmentBasisDeclaration;';
        'WRS_AdjustmentBasisStatusScalar = Param("RS Adjustment Basis Status: 0=unverified 1=compatible 2=incompatible",0,0,2,1);' = 'WRS_AdjustmentBasisStatusScalar = WVRC_RSAdjustmentBasisStatus;';
        'WRS_RuntimeLastBarIsProvisional = ParamToggle("RS: last bar provisional","No|Yes",0);' = 'WRS_RuntimeLastBarIsProvisional = WVRC_LastBarProvisional;'
    } \
    @('<WyckoffVSA_StructureLocation_v1.0.afl>')

Build-RuntimeFile \
    "WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl" \
    "WyckoffVSA_CrossSymbolSelectionContext_Consumer_Runtime_v0.2.afl" \
    @{
        'WXS_RequestedMarketSymbol = ParamStr("Selection: Market benchmark symbol","");' = 'WXS_RequestedMarketSymbol = WVRC_SelectionMarketSymbol;';
        'WXS_RequestedGroupSymbol = ParamStr("Selection: Group benchmark symbol","");' = 'WXS_RequestedGroupSymbol = WVRC_SelectionGroupSymbol;'
    } \
    @()

Build-RuntimeFile \
    "WyckoffVSA_CrossSymbolSelectionContext_ConsumerVersionGuard_v0.1.afl" \
    "WyckoffVSA_CrossSymbolSelectionContext_ConsumerVersionGuard_Runtime_v0.2.afl" \
    @{
        '#include_once <WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl>' = '#include_once <WyckoffVSA_CrossSymbolSelectionContext_Consumer_Runtime_v0.2.afl>'
    } \
    @('<WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl>')

Build-RuntimeFile \
    "WyckoffVSA_MarketScanner_v0.1.afl" \
    "WyckoffVSA_MarketScanner_Runtime_v0.2.afl" \
    @{
        '#include_once <WyckoffVSA_MultiTimeframeContext_v0.1.afl>' = '#include_once <WyckoffVSA_MultiTimeframeContext_Runtime_v0.2.afl>';
        '#include_once <WyckoffVSA_RelativeStrengthContext_v0.1.afl>' = '#include_once <WyckoffVSA_RelativeStrengthContext_Runtime_v0.2.afl>';
        '#include_once <WyckoffVSA_CrossSymbolSelectionContext_ConsumerVersionGuard_v0.1.afl>' = '#include_once <WyckoffVSA_CrossSymbolSelectionContext_ConsumerVersionGuard_Runtime_v0.2.afl>';
        'WSCN_RequireFullTopDown = ParamToggle("Scanner: require Full Top-Down profile","No|Yes",0);' = 'WSCN_RequireFullTopDown = WVRC_RequireFullTopDown;'
    } \
    @(
        '<WyckoffVSA_MultiTimeframeContext_v0.1.afl>',
        '<WyckoffVSA_RelativeStrengthContext_v0.1.afl>',
        '<WyckoffVSA_CrossSymbolSelectionContext_ConsumerVersionGuard_v0.1.afl>'
    )

$probe = @'
/* Wyckoff VSA Runtime v0.2 Scanner equivalence probe. Diagnostic only. */
#pragma nocache
SetBarsRequired(sbrAll,sbrAll);
#include_once <WyckoffVSA_RuntimeConfig_v0.2.afl>
#include_once <WyckoffVSA_MarketScanner_Runtime_v0.2.afl>

Filter = 1;

AddTextColumn(Name(),"PROBE Symbol");
AddColumn(DateTime(),"PROBE Date",formatDateTime);
AddColumn(BarIndex(),"PROBE BarIndex",1.0);
AddColumn(WVRC_ConfigValid,"Runtime Config Valid",1.0);
AddTextColumn(WVRC_RSMarketSymbol,"Runtime RS Market");
AddTextColumn(WVRC_RSGroupSymbol,"Runtime RS Group");
AddTextColumn(WVRC_SelectionMarketSymbol,"Runtime Selection Market");
AddTextColumn(WVRC_SelectionGroupSymbol,"Runtime Selection Group");
AddColumn(WVRC_RequireFullTopDown,"Runtime Full Top-Down",1.0);

AddColumn(WCI_ContextMultiplicityCode,"Composite Multiplicity",1.0);
AddColumn(WCI_PhaseStateCode,"Composite Phase",1.0);
AddColumn(WCI_FamilyHypothesisCode,"Composite Family",1.0);
AddColumn(WCI_RangePosition,"Composite Range Position",1.4);

AddColumn(WMTF_SnapshotContractValid,"MTF Contract Valid",1.0);
AddColumn(WMTF_WeeklySnapshotStatusCode,"MTF Weekly Status",1.0);
AddColumn(WMTF_MonthlySnapshotStatusCode,"MTF Monthly Status",1.0);
AddColumn(WMTF_DirectionalAlignmentCode,"MTF Directional Alignment",1.0);

AddColumn(WRS_ContextValid,"RS Context Valid",1.0);
AddColumn(WRS_ContextStatusCode,"RS Context Status",1.0);
AddColumn(WRS_MarketBenchmarkStatusCode,"RS Market Benchmark Status",1.0);
AddColumn(WRS_StockVsMarketRSStructureCode,"RS Stock vs Market Structure",1.0);
AddColumn(WRS_PriceRSRelationshipCode,"Price RS Relationship",1.0);

AddColumn(WXS_MarketValid,"Selection Market Valid",1.0);
AddColumn(WXS_MarketStatusCode,"Selection Market Status",1.0);
AddColumn(WXS_GroupValid,"Selection Group Valid",1.0);
AddColumn(WXS_GroupStatusCode,"Selection Group Status",1.0);

AddColumn(WSCN_DataEligibilityCode,"Data Eligibility",1.0);
AddColumn(WSCN_ExclusionReasonMask,"Exclusion Mask",1.0);
AddColumn(WSCN_CandidateClassCode,"Candidate Class",1.0);
AddColumn(WSCN_CandidateSideCode,"Candidate Side",1.0);
AddColumn(WSCN_CandidateStageCode,"Candidate Stage",1.0);
AddColumn(WSCN_QualifiedCandidateFlag,"Qualified",1.0);
AddColumn(WSCN_DevelopingCandidateFlag,"Developing",1.0);
AddColumn(WSCN_WatchFlag,"Watch",1.0);
AddColumn(WSCN_ReviewFlag,"Review",1.0);
AddColumn(WSCN_MethodBlockReasonMask,"Method Block Mask",1.0);
AddColumn(WSCN_StockRangeStatusCode,"Range Status",1.0);
AddColumn(WSCN_StockRangePositionValid,"Range Position Valid",1.0);
AddColumn(WSCN_StockRangePosition,"Range Position",1.4);
AddColumn(WSCN_RangeLocationCoherent,"Range Location Coherent",1.0);
AddColumn(WSCN_RangeLocationConflict,"Range Location Conflict",1.0);
AddTextColumn("SCANNER_RUNTIME_V02_PROBE_20260912_D","PROBE VERSION");
'@

Write-Utf8NoBom (PF "WyckoffVSA_MarketScanner_Runtime_v0.2_Probe.afl") $probe
Write-Host "INSTALLED PROBE: WyckoffVSA_MarketScanner_Runtime_v0.2_Probe.afl"

Write-Host ""
Write-Host "Runtime MTF/RS/Selection/Scanner stack build complete."
Write-Host "Generated runtime files verified UTF-8 WITHOUT BOM."
Write-Host "Canonical v0.1 files were READ ONLY and were not modified."
Write-Host "Next native check: WyckoffVSA_MarketScanner_Runtime_v0.2_Probe.afl"
