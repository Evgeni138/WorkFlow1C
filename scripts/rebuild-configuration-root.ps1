[Console]::OutputEncoding=[System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"
# Пути — плейсхолдеры; укажите реальные перед использованием.
$src = "{{SRC_ROOT}}"                       # корень выгрузки, например D:\WorkFlow\<project>\src
$ws1 = "{{WS1_ROOT}}\src\Configuration.xml" # эталонная версия Configuration.xml (полный файл)
$ourTrunc = "$src\Configuration.xml.truncated.bak"
$outXml = "$src\Configuration.xml"
$headCount = 57
$tailStart = 57 # 0-based index for line 58
$tailEnd = 307  # 0-based index for line 308 (inclusive)

$dirToTag = [ordered]@{
    "AccountingRegisters"="AccountingRegister"
    "AccumulationRegisters"="AccumulationRegister"
    "BusinessProcesses"="BusinessProcess"
    "Catalogs"="Catalog"
    "ChartsOfAccounts"="ChartOfAccounts"
    "ChartsOfCalculationTypes"="ChartOfCalculationTypes"
    "ChartsOfCharacteristicTypes"="ChartOfCharacteristicTypes"
    "CommandGroups"="CommandGroup"
    "CommonAttributes"="CommonAttribute"
    "CommonCommands"="CommonCommand"
    "CommonForms"="CommonForm"
    "CommonModules"="CommonModule"
    "CommonPictures"="CommonPicture"
    "CommonTemplates"="CommonTemplate"
    "Constants"="Constant"
    "DataProcessors"="DataProcessor"
    "DefinedTypes"="DefinedType"
    "DocumentJournals"="DocumentJournal"
    "DocumentNumerators"="DocumentNumerator"
    "Documents"="Document"
    "Enums"="Enum"
    "EventSubscriptions"="EventSubscription"
    "ExchangePlans"="ExchangePlan"
    "ExternalDataSources"="ExternalDataSource"
    "FilterCriteria"="FilterCriterion"
    "FunctionalOptions"="FunctionalOption"
    "FunctionalOptionsParameters"="FunctionalOptionsParameter"
    "HTTPServices"="HTTPService"
    "InformationRegisters"="InformationRegister"
    "IntegrationServices"="IntegrationService"
    "Languages"="Language"
    "Reports"="Report"
    "Roles"="Role"
    "ScheduledJobs"="ScheduledJob"
    "Sequences"="Sequence"
    "SessionParameters"="SessionParameter"
    "SettingsStorages"="SettingsStorage"
    "StyleItems"="StyleItem"
    "Subsystems"="Subsystem"
    "Tasks"="Task"
    "WebServices"="WebService"
    "WSReferences"="WSReference"
    "XDTOPackages"="XDTOPackage"
}

$tagOrder = @(
    "Language","Subsystem","StyleItem","CommonPicture","SessionParameter","Role","CommonTemplate",
    "FilterCriterion","CommonModule","CommonAttribute","ExchangePlan","XDTOPackage","WebService",
    "HTTPService","WSReference","EventSubscription","ScheduledJob","SettingsStorage","FunctionalOption",
    "FunctionalOptionsParameter","DefinedType","CommonCommand","CommandGroup","Constant","CommonForm",
    "Catalog","Document","DocumentNumerator","Sequence","DocumentJournal","Enum","Report","DataProcessor",
    "InformationRegister","AccumulationRegister","ChartOfCharacteristicTypes","ChartOfAccounts",
    "AccountingRegister","ChartOfCalculationTypes","BusinessProcess","Task","ExternalDataSource",
    "IntegrationService"
)

$tagToDir = @{}
foreach($entry in $dirToTag.GetEnumerator()){ $tagToDir[$entry.Value] = $entry.Key }

$ws1Lines = [System.IO.File]::ReadAllLines($ws1, [System.Text.Encoding]::UTF8)
$ourLines = [System.IO.File]::ReadAllLines($ourTrunc, [System.Text.Encoding]::UTF8)
$head = $ourLines[0..($headCount-1)]
$tail = $ws1Lines[$tailStart..$tailEnd]

$co = New-Object System.Collections.Generic.List[string]
$co.Add("		<ChildObjects>")
$totalChildren = 0
foreach($tag in $tagOrder){
    $dir = $tagToDir[$tag]
    $dirPath = Join-Path $src $dir
    $names = New-Object System.Collections.Generic.List[string]
    if(Test-Path $dirPath){
        $names = @(Get-ChildItem $dirPath -Filter "*.xml" -File -Force -ErrorAction SilentlyContinue | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) })
        $names = @($names | Where-Object { $_ })
        $arr = [string[]]$names
        [Array]::Sort($arr, [System.StringComparer]::Ordinal)
        foreach($n in $arr){
            $co.Add("			<$tag>$n</$tag>")
            $totalChildren++
        }
    }
}
$co.Add("		</ChildObjects>")
Write-Host "objects=$totalChildren, ChildObjects lines=$($co.Count)"

$closing = New-Object System.Collections.Generic.List[string]
[void]$closing.Add("	</Configuration>")
[void]$closing.Add("</MetaDataObject>")

$all = New-Object System.Collections.Generic.List[string]
foreach($line in $head){ [void]$all.Add($line) }
foreach($line in $tail){ [void]$all.Add($line) }
foreach($line in $co){ [void]$all.Add($line) }
foreach($line in $closing){ [void]$all.Add($line) }

$utf8 = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllLines($outXml, $all.ToArray(), $utf8)

$fi = [System.IO.FileInfo]::new($outXml)
Write-Host "Result: $($fi.Length) bytes, $($all.Count) lines"

try {
    [xml]$doc = Get-Content $outXml -Raw
    $nodes = $doc.SelectNodes("//*[local-name()='ChildObjects']/*")
    Write-Host "XML parse: OK, ChildObjects elements: $($nodes.Count)"
    $props = $doc.SelectNodes("//*[local-name()='Properties']/*")
    Write-Host "Properties elements: $($props.Count)"
} catch {
    Write-Host "XML parse FAILED: $($_.Exception.Message)"
}
