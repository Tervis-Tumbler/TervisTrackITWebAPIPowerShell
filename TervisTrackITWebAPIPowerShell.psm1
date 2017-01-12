#Requires -modules TrackITWebAPIPowerShell, TervisActiveDirectory

Function Add-TrackITWorkOrderCustomProperties {
    param(
        [Parameter(ValueFromPipeline)]$WorkOrder
    )

    $WorkOrder | 
    Add-Member -MemberType ScriptProperty -Name RequestorFirstName -PassThru -Value {
        $This.RequestorName -split " " |
        select -First 1
    } | 
    Add-Member -MemberType ScriptProperty -Name RequestorEmailAddress -PassThru -Value {
        Get-ADUserEmailAddressByName -Name $This.RequestorName
    } |
    Add-Member -MemberType ScriptProperty -Name AllNotes -Value {
        $This.notes | 
        Get-Member | 
        where membertype -EQ noteproperty | 
        ForEach-Object { 
            $This.notes.$($_.name) 
        }
    }

    $WorkOrder.AllNotes | 
    Add-Member -MemberType ScriptProperty -Name CreatedDateDate -Value { 
        get-date $this.createddate 
    }

    $WorkOrder
}

Function Get-TervisTrackITWorkOrder {
    param(
        [Parameter(Mandatory)]$WorkOrderNumber
    )
    Import-module TrackItWebAPIPowerShell -Force #Something is broken as this line shouldn't be required but it is
    Invoke-TrackITLogin -Username helpdeskbot -Pwd helpdeskbot
    $WorkOrder = Get-TrackITWorkOrder -WorkOrderNumber $WorkOrderNumber | select -ExpandProperty Data
    $WorkOrder | Add-TrackITWorkOrderCustomProperties
}

Function Edit-TervisTrackITWorkOrder {
    param (
        [Parameter(Mandatory)]$WorkOrderNumber,
        $KanbanizeColumn,
        $KanbanizeLane,
        $KanbanizeBoard,
        $KanbanizeCardID,
        $KanbanizeProject
    )
    
    $TrackITWorkOrderPropertyMapping = @{
        #UdfLookup1 = "KanbanizeProject"
        #UdfLookup2 = "KanbanizeBoard"
        #UdfLookup3 = "KanbanizeLane"
        #UdfLookup4 = "KanbanizeColumn"
        #UdfText2 = "KanbanizeCardID"
        KanbanizeProject = "UdfLookup1"
        KanbanizeBoard = "UdfLookup2"
        KanbanizeLane = "UdfLookup3"
        KanbanizeColumn = "UdfLookup4"
        KanbanizeCardID = "UdfText2"
    }

    $Parameters = @{}
    
    foreach ($Key in $PSBoundParameters.Keys) {
        if ($TrackITWorkOrderPropertyMapping.ContainsKey($Key)) {
            $Parameters.Add($TrackITWorkOrderPropertyMapping[$Key], $PSBoundParameters[$Key])
        } else {
            $Parameters.Add($Key, $PSBoundParameters[$Key])
        }
    }

    Edit-TrackITWorkOrder @Parameters
}
