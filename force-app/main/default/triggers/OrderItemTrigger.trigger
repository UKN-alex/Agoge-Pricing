trigger OrderItemTrigger on OrderItem (before insert, before update) {

    //Instanciando minha handler
    OrderItemTriggerHandler handler = new OrderItemTriggerHandler(
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );

    switch on Trigger.operationType {
        // Entrada da minha condicional

        // BEFORE_INSERT
        when BEFORE_INSERT {
            System.debug('Entrou no BEFORE_INSERT');
            handler.beforeInsert();
        }

        when BEFORE_UPDATE {
            System.debug('Entrou no BEFORE_UPDATE');
            handler.beforeUpdate();
        }
    }
}