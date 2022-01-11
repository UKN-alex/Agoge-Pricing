trigger MarginTrigger on Margin__c (before insert) {
    
    //Instanciamento da handler
     MarginTriggerHandler handler = new MarginTriggerHandler (
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );

    //conidção 

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert();
             
        }


    }
}