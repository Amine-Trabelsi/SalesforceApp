trigger OrderItemTrigger on OrderItem__c (after insert, after update, after delete, after undelete) {
    Set<Id> orderIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (OrderItem__c item : Trigger.new) {
            orderIds.add(item.OrderId__c);
        }
    }

    if (Trigger.isDelete) {
        for (OrderItem__c item : Trigger.old) {
            orderIds.add(item.OrderId__c);
        }
    }

    if (!orderIds.isEmpty()) {
        OrderItemTriggerHandler.updateOrderTotals(orderIds);
    }
}
