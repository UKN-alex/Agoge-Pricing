public with sharing class OrderItemTriggerHandler {

    List<OrderItem> oldRecords {get; set;} // Variável relativa ao meu Trigger.old
    List<OrderItem> newRecords {get; set;} // Variável relativa ao meu Trigger.new
    Map<Id, OrderItem> oldMap {get; set;} // Variável realativa ao meu Trigger.old    
    Map<Id, OrderItem> newMap {get; set;} // Variável realativa ao meu Trigger.new

    public OrderItemTriggerHandler(List<OrderItem> oldRecords, List<OrderItem> newRecords, Map<Id, OrderItem> oldMap, Map<Id, OrderItem> newMap) {
        
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;

    }

    // Métodos

    public void beforeInsert() {
        OrderItemHelper.checkFields(this.newRecords);
        OrderItemHelper.calcPrice(this.newRecords);
    }

    public void beforeUpdate() {
        OrderItemHelper.checkFields(this.newRecords);
    }
}
