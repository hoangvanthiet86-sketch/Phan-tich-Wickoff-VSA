param(
    [string]$IncludeDir = "C:\Program Files (x86)\AmiBroker\Formulas\Include",
    [switch]$Restore
)

$ErrorActionPreference = "Stop"
$BackupSuffix = ".pre-wvrc-v0.2.bak"

function Resolve-AflPath([string]$Name) {
    return Join-Path $IncludeDir $Name
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
        $path = Resolve-AflPath $name
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

$compositeReplacement = @'
// WVRC_BRIDGE_V02 COMPOSITE
WVRC_CompositeUseCentralConfig = Nz(VarGet("WVRC_UseCentralConfig"),0)==1;
if (WVRC_CompositeUseCentralConfig)
    WCI_RuntimeLastBarIsProvisional = WVRC_LastBarProvisional;
else
    WCI_RuntimeLastBarIsProvisional = ParamToggle("Composite: last bar provisional","No|Yes",0);
'@

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

$scannerReplacement = @'
// WVRC_BRIDGE_V02 MARKET_SCANNER
WVRC_ScannerUseCentralConfig = Nz(VarGet("WVRC_UseCentralConfig"),0)==1;
if (WVRC_ScannerUseCentralConfig)
    WSCN_RequireFullTopDown = WVRC_RequireFullTopDown;
else
    WSCN_RequireFullTopDown = ParamToggle("Scanner: require Full Top-Down profile","No|Yes",0);
'@

$patches = @(
    [pscustomobject]@{
        File = "WyckoffVSA_Core_v1.0.afl"; Marker = "WVRC_BRIDGE_V02 CORE";
        Pattern = 'VolumeLookback\s*=\s*Param\("Volume Lookback".*?ShowDebugTitle\s*=\s*ParamToggle\("Show Debug Title".*?\);';
        Replacement = $coreReplacement
    },
    [pscustomobject]@{
        File = "WyckoffVSA_StructureLocation_v1.0.afl"; Marker = "WVRC_BRIDGE_V02 STRUCTURE_LOCATION";
        Pattern = 'SL_S_Lookback\s*=\s*Param\("SL Short Lookback".*?SL_PivotRight\s*=\s*Param\("SL Pivot Right".*?\);';
        Replacement = $slReplacement
    },
    [pscustomobject]@{
        File = "WyckoffVSA_CompositeIndicator_v0.1.afl"; Marker = "WVRC_BRIDGE_V02 COMPOSITE";
        Pattern = 'WCI_RuntimeLastBarIsProvisional\s*=\s*ParamToggle\("Composite: last bar provisional","No\|Yes",0\);';
        Replacement = $compositeReplacement
    },
    [pscustomobject]@{
        File = "WyckoffVSA_RelativeStrengthContext_v0.1.afl"; Marker = "WVRC_BRIDGE_V02 RELATIVE_STRENGTH";
        Pattern = 'WRS_MarketBenchmarkSymbol\s*=\s*ParamStr\("RS Market Benchmark",""\);.*?WRS_RuntimeLastBarIsProvisional\s*=\s*ParamToggle\("RS: last bar provisional","No\|Yes",0\);';
        Replacement = $rsReplacement
    },
    [pscustomobject]@{
        File = "WyckoffVSA_CrossSymbolSelectionContext_Consumer_v0.1.afl"; Marker = "WVRC_BRIDGE_V02 CROSS_SYMBOL_SELECTION";
        Pattern = 'WXS_RequestedMarketSymbol\s*=\s*ParamStr\("Selection: Market benchmark symbol",""\);\s*WXS_RequestedGroupSymbol\s*=\s*ParamStr\("Selection: Group benchmark symbol",""\);';
        Replacement = $selectionReplacement
    },
    [pscustomobject]@{
        File = "WyckoffVSA_MarketScanner_v0.1.afl"; Marker = "WVRC_BRIDGE_V02 MARKET_SCANNER";
        Pattern = 'WSCN_RequireFullTopDown\s*=\s*ParamToggle\("Scanner: require Full Top-Down profile","No\|Yes",0\);';
        Replacement = $scannerReplacement
    }
)

Write-Host "Applying Wyckoff VSA Runtime v0.2 Single Configuration Authority bridge..."
Write-Host "Include directory: $IncludeDir"

# Preflight every file and pattern before writing anything.
foreach ($p in $patches) {
    $path = Resolve-AflPath $p.File
    if (-not (Test-Path $path)) {
        throw "Missing required AFL file: $path"
    }
    $text = Get-Content -LiteralPath $path -Raw
    if ($text.Contains($p.Marker)) {
        continue
    }
    $regex = [regex]::new($p.Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $regex.IsMatch($text)) {
        throw "Preflight failed: expected source block not found in $($p.File). No files were modified."
    }
}

foreach ($p in $patches) {
    $path = Resolve-AflPath $p.File
    $text = Get-Content -LiteralPath $path -Raw
    if ($text.Contains($p.Marker)) {
        Write-Host "SKIP already bridged: $($p.File)"
        continue
    }

    $bak = $path + $BackupSuffix
    if (-not (Test-Path $bak)) {
        Copy-Item -LiteralPath $path -Destination $bak -Force
    }

    $regex = [regex]::new($p.Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $newText = $regex.Replace($text, $p.Replacement, 1)
    Set-Content -LiteralPath $path -Value $newText -Encoding UTF8
    Write-Host "PATCHED: $($p.File)"
}

Write-Host ""
Write-Host "Bridge installation complete."
Write-Host "Legacy originals are backed up once with suffix: $BackupSuffix"
Write-Host "The bridge is conditional: Runtime v0.2 consumes WVRC_*; standalone legacy formulas keep legacy Params."
Write-Host ""
Write-Host "Restore command:"
Write-Host "powershell -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Restore"
Write-Host ""
Write-Host "Next native check: run WyckoffVSA_PerformanceRuntime_CompatibilityHarness_v0.2.afl on DTP."
