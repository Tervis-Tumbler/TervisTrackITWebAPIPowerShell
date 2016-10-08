﻿Function Add-TrackITWorkOrderCustomProperties {
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
    $WorkOrder = Get-TrackITWorkOrder -WorkOrderNumber $WorkOrderNumber | select -ExpandProperty Data

    $WorkOrder | Add-TrackITWorkOrderCustomProperties
}

Function Test {
    $WorkOrder = Get-TervisTrackITWorkOrder -WorkOrderNumber 85103
}