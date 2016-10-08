#Requires -modules TrackITWebAPIPowerShell

Function Add-TrackITWorkOrderCustomProperties {
    param(
        [Parameter(ValueFromPipeline)]$WorkOrder
    )
    $WorkOrder | Add-Member -MemberType ScriptProperty -Name AllNotes -Value {
        $This.notes | GM | where membertype -EQ noteproperty | % { $This.notes.$($_.name) }
    }
    $WorkOrder.AllNotes | Add-Member -MemberType ScriptProperty -Name CreatedDateDate -Value { get-date $this.createddate }
    $WorkOrder
}

Function Get-TervisTrackITWorkOrder {
    param(
        $WorkOrderNumber
    )
    Import-module TrackItWebAPIPowerShell -Force #Something is broken as this line shouldn't be required but it is
    Invoke-TrackITLogin -Username helpdeskbot -Pwd helpdeskbot
    $WorkOrder = Get-TrackITWorkOrder -WorkOrderNumber $WorkOrderNumber | select -ExpandProperty Data
    $WorkOrder | Add-TrackITWorkOrderCustomProperties
}
