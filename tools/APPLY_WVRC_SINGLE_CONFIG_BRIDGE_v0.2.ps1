param(
    [string]$IncludeDir = "C:\Program Files (x86)\AmiBroker\Formulas\Include",
    [switch]$Restore
)

$ErrorActionPreference = "Stop"
$BackupSuffix = ".pre-wvrc-v0.2.bak"

function Get-Path([string]$Name) {
    Join-Path $IncludeDir $Name
}

function Backup-Once([string]$Path) {
    $bak = $Path + $BackupSuffix
    if (-not (Test-Path $bak)) {
        Copy-Item -LiteralPath $Path -Destination $bak -Force
    }
}

function Replace-RegexOrThrow(
    [string]$FileName,
    [string]$Pattern,
    [string]$Replacement,
    [string]$Marker
) {
    $path = Get-Path $FileName
    if (-not (Test-Path $path)) {
        throw "Missing required AFL file: $path"
    }

    $text = Get-Content -LiteralPath $path -Raw
    if ($text.Contains($Marker)) {
        Write-Host "SKIP already bridged: $FileName"
        return
    }

    $regex = [regex]::new($Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $regex.IsMatch($text)) {
        throw "Expected source block not found in $FileName. No changes written."
    }

    Backup-Once $path
    $newText = $regex.Replace($text, $Replacement, 1)
    Set-Content -LiteralPath $path -Value $newText -Encoding UTF8
    Write-Host "PATCHED: $FileName"
}

$files = @(
    "WyckoffVSA_Core_v1.0.afl",
    "WyckoffVSA_StructureLocation_v1.0.afl",
    "WyckoffVSA_CompositeIndicator_v0.1.afl",
    "WyckoffVSA_RelativeStrengthContext_v0.1.afl",
    "WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl",
    "WyckoffVSA_MarketScanner_v0.1.afl"
)

if ($Restore) {
    foreach ($name in $files) {
        $path = Get-Path $name
        $bak = $path + $BackupSuffix
        if (Test-Path $bak) {
            Copy-Item -LiteralPath $bak -Destination $path -Force
            Write-Host "RESTORED: $name"
        } else {
            Write-Host "NO BACKUP: $name"
        }
    }
    Write-Host "Restore complete."
    exit 0
}

Write-Host "Applying Wyckoff VSA Runtime v0.2 Single Configuration Authority bridge..."
Write-Host "Include directory: $IncludeDir"

$coreReplacement = @'
// WVRC_BRIDGE_V02 CORE
WVRC_CoreUseCentralConfig = Nz(VarGet("WVRC_UseCentralConfig"),0)==1;
if (WVRC_CoreUseCentralConfig)
{
    VolumeLookback = WVRC_VolumeLookback;
    SpreadLookback = WVRC_SpreadLookback;
    ATRPeriod = WVRC_ATRPeriod;
    HighEffortThreshold = WVRC_HighEffortRVOL;
    LowEffortThreshold = WVRC_LowEffortRVOL;
    LowDirectionalResultThreshold = WVRC_LowDirectionalResultATR;
    HighDirectionalResultThreshold = WVRC_HighDirectionalResultATR;
    ShowDebugTitle = WVRC_ShowDebugTitle;
}
else
{
    VolumeLookback = Param("Volume Lookback", 20, 2, 200, 1);
    SpreadLookback = Param("Spread Lookback", 20, 2, 200, 1);
    ATRPeriod = Param("ATR Period", 14, 2, 200, 1);
    HighEffortThreshold = Param("High Effort RVOL", 1.80, 0.01, 10, 0.05);
    LowEffortThreshold = Param("Low Effort RVOL", 0.75, 0, 10, 0.05);
    LowDirectionalResultThreshold = Param("Low Directional Result ATR", 0.35, 0, 10, 0.05);
    HighDirectionalResultThreshold = Param("High Directional Result ATR", 0.80, 0.01, 10, 0.05);
    ShowDebugTitle = ParamToggle("Show Debug Title", "No|Yes", 0);
}
'@
Replace-RegexOrThrow \
    "WyckoffVSA_Core_v1.0.afl" \
    'VolumeLookback\s*=\s*Param\("Volume Lookback".*?ShowDebugTitle\s*=\s*ParamToggle\("Show Debug Title".*?\);' \
    $coreReplacement \
    "WVRC_BRIDGE_V02 CORE"

$slReplacement = @'
// WVRC_BRIDGE_V02 STRUCTURE_LOCATION
WVRC_SLUseCentralConfig = Nz(VarGet("WVRC_UseCentralConfig"),0)==1;
if (WVRC_SLUseCentralConfig)
{
    SL_S_Lookback = WVRC_ShortLookback;
    SL_M_Lookback = WVRC_MediumLookback;
    SL_L_Lookback = WVRC_LongLookback;
    SL_PivotLeft = WVRC_PivotLeft;
    SL_PivotRight = WVRC_PivotRight;
}
else
{
    SL_S_Lookback = Param("SL Short Lookback",20,2,500,1);
    SL_M_Lookback = Param("SL Medium Lookback",60,2,500,1);
    SL_L_Lookback = Param("SL Long Lookback",120,2,500,1);
    SL_PivotLeft = Param("SL Pivot Left",3,1,20,1);
    SL_PivotRight = Param("SL Pivot Right",3,1,20,1);
}
'@
Replace-RegexOrThrow \
    "WyckoffVSA_StructureLocation_v1.0.afl" \
    'SL_S_Lookback\s*=\s*Param\("SL Short Lookback".*?SL_PivotRight\s*=\s*Param\("SL Pivot Right".*?\);' \
    $slReplacement \
    "WVRC_BRIDGE_V02 STRUCTURE_LOCATION"

$compositeReplacement = @'
// WVRC_BRIDGE_V02 COMPOSITE
WVRC_CompositeUseCentralConfig = Nz(VarGet("WVRC_UseCentralConfig"),0)==1;
if (WVRC_CompositeUseCentralConfig)
    WCI_RuntimeLastBarIsProvisional = WVRC_LastBarProvisional;
else
    WCI_RuntimeLastBarIsProvisional = ParamToggle("Composite: last bar provisional","No|Yes",0);
'@
Replace-RegexOrThrow \
    "WyckoffVSA_CompositeIndicator_v0.1.afl" \
    'WCI_RuntimeLastBarIsProvisional\s*=\s*ParamToggle\("Composite: last bar provisional","No\|Yes",0\);' \
    $compositeReplacement \
    "WVRC_BRIDGE_V02 COMPOSITE"

$rsReplacement = @'
// WVRC_BRIDGE_V02 RELATIVE_STRENGTH
WVRC_RSUseCentralConfig = Nz(VarGet("WVRC_UseCentralConfig"),0)==1;
if (WVRC_RSUseCentralConfig)
{
    WRS_MarketBenchmarkSymbol = WVRC_RSMarketSymbol;
    WRS_GroupBenchmarkSymbol = WVRC_RSGroupSymbol;
    WRS_AdjustmentBasisDeclaration = WVRC_RSAdjustmentBasisDeclaration;
    WRS_AdjustmentBasisStatusScalar = WVRC_RSAdjustmentBasisStatus;
    WRS_RuntimeLastBarIsProvisional = WVRC_LastBarProvisional;
}
else
{
    WRS_MarketBenchmarkSymbol = ParamStr("RS Market Benchmark","");
    WRS_GroupBenchmarkSymbol = ParamStr("RS Group Benchmark","");
    WRS_AdjustmentBasisDeclaration = ParamStr("RS Adjustment Basis","NOT VERIFIED");
    WRS_AdjustmentBasisStatusScalar = Param("RS Adjustment Basis Status: 0=unverified 1=compatible 2=incompatible",0,0,2,1);
    WRS_RuntimeLastBarIsProvisional = ParamToggle("RS: last bar provisional","No|Yes",0);
}
'@
Replace-RegexOrThrow \
    "WyckoffVSA_RelativeStrengthContext_v0.1.afl" \
    'WRS_MarketBenchmarkSymbol\s*=\s*ParamStr\("RS Market Benchmark",""\);.*?WRS_RuntimeLastBarIsProvisional\s*=\s*ParamToggle\("RS: last bar provisional","No\|Yes",0\);' \
    $rsReplacement \
    "WVRC_BRIDGE_V02 RELATIVE_STRENGTH"

$selectionReplacement = @'
// WVRC_BRIDGE_V02 CROSS_SYMBOL_SELECTION
WVRC_SelectionUseCentralConfig = Nz(VarGet("WVRC_UseCentralConfig"),0)==1;
if (WVRC_SelectionUseCentralConfig)
{
    WXS_RequestedMarketSymbol = WVRC_SelectionMarketSymbol;
    WXS_RequestedGroupSymbol = WVRC_SelectionGroupSymbol;
}
else
{
    WXS_RequestedMarketSymbol = ParamStr("Selection: Market benchmark symbol","");
    WXS_RequestedGroupSymbol = ParamStr("Selection: Group benchmark symbol","");
}
'@
Replace-RegexOrThrow \
    "WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl" \
    'WXS_RequestedMarketSymbol\s*=\s*ParamStr\("Selection: Market benchmark symbol",""\);\s*WXS_RequestedGroupSymbol\s*=\s*ParamStr\("Selection: Group benchmark symbol",""\);' \
    $selectionReplacement \
    "WVRC_BRIDGE_V02 CROSS_SYMBOL_SELECTION"

$scannerReplacement = @'
// WVRC_BRIDGE_V02 MARKET_SCANNER
WVRC_ScannerUseCentralConfig = Nz(VarGet("WVRC_UseCentralConfig"),0)==1;
if (WVRC_ScannerUseCentralConfig)
    WSCN_RequireFullTopDown = WVRC_RequireFullTopDown;
else
    WSCN_RequireFullTopDown = ParamToggle("Scanner: require Full Top-Down profile","No|Yes",0);
'@
Replace-RegexOrThrow \
    "WyckoffVSA_MarketScanner_v0.1.afl" \
    'WSCN_RequireFullTopDown\s*=\s*ParamToggle\("Scanner: require Full Top-Down profile","No\|Yes",0\);' \
    $scannerReplacement \
    "WVRC_BRIDGE_V02 MARKET_SCANNER"

Write-Host ""
Write-Host "Bridge installation complete."
Write-Host "Original files were backed up once with suffix $BackupSuffix"
Write-Host "To restore legacy files:"
Write-Host "  powershell -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Restore"
Write-Host ""
Write-Host "Next native check: open WyckoffVSA_PerformanceRuntime_CompatibilityHarness_v0.2.afl"
Write-Host "and verify that only numbered WVRC Parameters are required in runtime mode."
