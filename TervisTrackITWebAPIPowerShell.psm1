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
