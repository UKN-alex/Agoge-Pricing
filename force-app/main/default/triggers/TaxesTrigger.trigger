trigger TaxesTrigger on Taxes__c (before insert) {

    TaxesTriggerHandler handler = new TaxesTriggerHandler (
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );


    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert();
        }
    }
}