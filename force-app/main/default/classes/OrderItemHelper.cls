public with sharing class OrderItemHelper {
    public OrderItemHelper() {

    }

public static void checkFields(List<OrderItem> orderItemList){
    for(OrderItem orderItem : orderItemList) {
        if(orderItem.Freight__c == null ){
            //Utilizando-se das criações de Labels para mensagem
            orderItem.addError(System.label.NotAthorize);
        }
        else if (orderItem.Taxes__c == null){
            //Utilizando-se das criações de Labels para mensagem
            orderItem.addError(System.label.NotAthorize);
        }
        else if (orderItem.MarginName__c == null){
            //Utilizando-se das criações de Labels para mensagem
            orderItem.addError(System.label.NotAthorize);
        }
        else if (orderItem.Quantity <= 0) {
            orderItem.addError(System.label.OrderItemQuantityError);
        }
        else if (orderItem.UnitPrice <= 0) {
            orderItem.addError(System.label.OrderItemPriceError);
        }
    }
}

public static List<OrderItem> calcPrice(List<OrderItem> orderItemList){
    //Carregamento dos dados relacionados ao OrderItem
    Set<Id> orderIdSet = new Set<Id>();
    Set<Id> productIdSet = new Set<Id>();
    Set<Id> taxesIdSet = new Set<Id>();
    Set<Id> distribuitionCenterIds = new Set<Id>();
    //Iteração na coleção de OrderItem


    for (OrderItem orderItem : orderItemList) {

        //Preenchimento dos meus dois Sets
        orderIdSet.add(orderItem.OrderId);
        productIdSet.add(orderItem.Product2Id);
        taxesIdSet.add(orderItem.Taxes__c);
        // Obs: Fazendo os set dos identificadores, agora é possível realizar um SELECT na tabela de Pedido e Produto

    }
    //Utilizando-se do mapa fica mais fácil acessar as informações relativas ao OrderItem
    
    Map<Id, Order> orderMap = new Map <Id, Order> ([
        SELECT Id, AccountId, Account.AccountGroup__c
        FROM Order
        WHERE Id IN: orderIdSet // Meu Where fica limitado apenas aos meus Ids do OrderIdSet
    ]);

    Map<Id, Product2> productMap = new Map <Id, Product2> ([
        SELECT Id, ProductHierarchy__c
        FROM Product2
        WHERE Id IN: productIdSet // Meu Where fica limitado apenas aos meus Ids do productIdSet
    ]);

    // search margins
    Map<OrderItem, Margin__c> orderItemToMargin = searchMargin(orderItemList, orderMap, productMap);
    
    System.debug('orderItemToMargin' + orderItemToMargin);

    for(OrderItem orderItem : orderItemToMargin.keySet()) {
        Margin__c margin = orderItemToMargin.get(orderItem);
        System.debug('Entrou!!!');
        if(margin != null) {
            orderItem.MarginName__c = margin.Id;
            orderItem.MarginPercent__c = margin.Value__c;
            // orderItem.Taxes__c = taxes.Value__c;
            // orderItem.Freight__c = freight.Id;
            //orderItem.Freight__c = orderItem.Freight_c.Value__c; ---> Tenho que fazer meu Frete do orderItem receber meu frete do Object Freight__c o mesmo para impostos

            
            //System.debug('priceWtMargin => ' + priceWtMargin);
            //System.debug('finalPrice => ' + finalPrice);
            //orderItem.PriceWtMargin__c * (1+ (margin.Value__c/100));
            // cálculo do ListPrice padrão -> orderItem.FullPrice__c = orderItem.ListPrice - (orderItem.ListPrice * (priceMargin.Margin__c/100));
            // apenas para salvar lógica (totalPrice + frete) * (Imposto/100) = Preço sem Margem
            

        }
          
    }
    Map<OrderItem, Taxes__c> orderItemToTaxes = searchTaxes(orderItemList, orderMap, productMap);
    System.debug('orderItemToTaxes' + orderItemToTaxes);
    
    for(OrderItem orderItemTaxes : orderItemToTaxes.keySet()){
        Taxes__c taxes = orderItemToTaxes.get(orderItemTaxes);
        System.debug('Entrou!!! 2');
        System.debug('Taxes' + taxes);

        if(taxes != null) {
            orderItemTaxes.Taxes__c = taxes.Id;
            orderItemTaxes.TaxPercent__c = taxes.Imposto__c;
        }
        
    }  
    

    Map<OrderItem, Freight__c> orderItemToFreight = searchFreight(orderItemList, orderMap, productMap);
    System.debug('orderItemToFreight' + orderItemToFreight);

    for (OrderItem orderItemFreight : orderItemToFreight.keySet()){
        Freight__c freight = orderItemToFreight.get(orderItemFreight);
        System.debug('Entrou 3');
        System.debug('Freight' + freight);

        if(freight !=null) {
            orderItemFreight.Freight__c = freight.Id;
            orderItemFreight.FreightValue__c = freight.Value__c;

            Decimal priceWtMargin = (orderItemFreight.ListPrice + orderItemFreight.FreightValue__c) * (1+(orderItemFreight.TaxPercent__c/100));
            Decimal finalPrice =  priceWtMargin * (1+(orderItemFreight.MarginPercent__c/100));
            Decimal discountPrice = (finalPrice - orderItemFreight.ListPrice);
            Decimal discountPercent = (discountPrice * 100)/finalPrice;
             System.debug('Total price => ' + finalPrice);
             orderItemFreight.PriceWtMargin__c = priceWtMargin;
             orderItemFreight.FinalPrice__c = finalPrice;
             orderItemFreight.Decount__c = discountPrice;
             orderItemFreight.DiscountPercent__c = discountPercent;
        }
    }
    return new List<OrderItem>(orderItemToFreight.keySet());
}

    public static  Map<OrderItem, Margin__c> searchMargin (List<OrderItem> orderItemList, Map<Id,Order> orderMap, Map<Id, Product2> productMap){
        // Variáveis para realizar o filtro do marginList abaixo 
        Set<Id> productIds = new Set<Id>();
        Set<Id> hierarchyIds = new Set<Id>(); 
        Set<Id> accountIds = new Set<Id>(); 
        Set<Id> groupIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>(); 
        Set<Id> countryIds = new Set<Id>();  
        // Iterações dentro do meu mapa para preenchimento dos meus fields/objects
        for (Order order : orderMap.values()) {
            accountIds.add(order.AccountId);
            groupIds.add(order.Account.AccountGroup__c);
        }

        for (Product2 product : productMap.values()){
            productIds.add(product.Id);
            hierarchyIds.add(product.ProductHierarchy__c);
        }

        // consulta da minha margin list
        List<Margin__c> marginList = [
            SELECT Id, Product__c, ProductHierarchy__c, Account__c, AccountGroup__c, City__c, States__c, Country__C, Value__c, Score__c
            FROM Margin__c
            WHERE (Product__c IN :       productIds     OR Product__c = null) AND 
            (ProductHierarchy__c IN:     hierarchyIds   OR ProductHierarchy__c = null ) AND
            (Account__c IN:              accountIds     OR Account__c = null) AND
            (AccountGroup__c IN:         groupIds       OR AccountGroup__c = null) AND
            (City__c IN :                cityIds        OR City__c = null) AND
            (States__c IN :              stateIds       OR States__c = null) AND 
            (Country__C IN :             countryIds     OR Country__C = null) 
            ORDER BY Score__c // Ordernação baseada pela especificidade
        ];

        // O intuito agora é realizar um match entre a margin e orderItem
        //Obs por se tratar do contexto Before, ainda não existe um ID para OrderItem, portanto vamos utilizar otura chave
        Map<OrderItem, Margin__c> orderItemToMargin = new Map<OrderItem, Margin__c>();

        for(OrderItem orderItem : orderItemList) {
            // Vamos iterar os OderItens recebidos como parâmetros
            orderItemToMargin.put(orderItem, null); //Vamos colocar nosso orderItem dentro do nosso mapa

            // Agora para saber o valor do margin do nosso item, vamos fazer uma condição
            for (Margin__c margin : marginList) {
                // aqui dentro determino a validação para saber se a margem bate com o meu order Item
                if (matchMargin(margin, orderItem, orderMap, productMap)){
                    // O put permite que eu posso sobreescrever o valor que já está, no caso colocando o valor da Margem agora
                    orderItemToMargin.put(orderItem, margin);
                    break; // Pois o primeiro que o match encontrar com o score alto já pode encerrar a condição
                }
            }
        }


        return orderItemToMargin;
}
    // método para realizar o match entre order e margin.
    // Importante passar os maps que foram feitos, para puxar os campos relacionados
    public static Boolean matchMargin (Margin__c margin, OrderItem orderItem, Map<Id, Order> orderMap, Map<Id, Product2> productMap){

        //Validação para realizar o seguinte caso: Ou o campo está vazio ou ele da Match com o campo do OrderItem
        return (String.isBlank(margin.Product__c)   || margin.Product__c          == orderItem.Product2Id) &&
        // Como eu não possuo o campo ProductHierarchy no OrderItem eu devo fazer o seguinte, fazer um map do Product para dentro do o OrderItem por meio do Get
        (String.isBlank(margin.ProductHierarchy__c) || margin.ProductHierarchy__c == productMap.get(orderItem.Product2Id).ProductHierarchy__c) &&
        (String.isBlank(margin.Account__c)          || margin.Account__c          == orderMap.get(orderItem.OrderId).AccountId) &&
        (String.isBlank(margin.AccountGroup__c)     || margin.AccountGroup__c     == orderMap.get(orderItem.OrderId).Account.AccountGroup__c);
        /*
            Preciso adicionar os campos de endereço para tratar no meu match também
        
        (String.isBlank(margin.DistributionCenter__c)     || margin.DistributionCenter__c     == orderMap.get(orderItem.OrderId).DistributionCenter__c)
        (String.isBlank(margin.State__c)                  || margin.State__c                  == orderMap.get(orderItem.OrderId).DistributionCenter__r.State__c)
        (String.isBlank(margin.Product__c) || margin.Product2 === orderItem.Product2) && 
        (String.isBlank(margin.Product__c) || margin.Product2 === orderItem.Product2) && 
        (String.isBlank(margin.Product__c) || margin.Product2 === orderItem.Product2) && 
        */ 
    }


    public static Map<OrderItem, Freight__c> searchFreight(List<OrderItem> orderItemList, Map<Id, Order> orderMap, Map<Id, Product2> productMap){
        Set<Id> distribuitionCenterIds = new Set<Id>();
        Set<Id> hierarchyIds = new Set<Id>(); 
        Set<Id> cityIds = new Set<Id>(); 
        Set<Id> stateIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        /*
        for (Order order : orderMap.values()){
            distribuitionCenterIds.add(order.DistribuitionCenter__c);
            cityIds.add(order.AccountAddress__r.City__c);
            stateIds.add(order.AccountAddress__r.City__r.State__c);
            countryIds.add(order.AccountAddress__r.City__r.State__r.Country__c);
        }
        */
        for (Product2 product : productMap.values()){
            productIds.add(product.Id);
            hierarchyIds.add(product.ProductHierarchy__c);
        }

        List<Freight__c> freightList = [
            SELECT Id, Product__c, 	ProductHierarchy__c, DistribuitionCenter__c, City__c, States__c, Country__c, Value__c, Score__c
            FROM Freight__c
            WHERE (Product__c IN : productIds OR Product__c = null) OR
            (ProductHierarchy__c IN : hierarchyIds OR ProductHierarchy__c = null) OR
            (DistribuitionCenter__c IN : distribuitionCenterIds OR DistribuitionCenter__c = null) OR
            (City__c IN : cityIds OR City__c = null) OR
            (States__c IN : stateIds OR States__c = null) OR
            (Country__c IN : countryIds OR Country__c = null)
            ORDER BY Score__c DESC 
        ];
            System.debug('Freight ' + freightList);
        Map<OrderItem, Freight__c> orderItemToFreight = new Map<OrderItem, Freight__c>();

        for(OrderItem orderItem : orderItemList) {
            orderItemToFreight.put(orderItem, null);

            for (Freight__c freight : freightList) {
                if (matchFreight(freight, orderItem, orderMap, productMap)){
                    orderItemToFreight.put(orderItem, freight);
                    break;
                }
            }
        }
        return orderItemToFreight;
    }

    // método para realizar o match entre order e freight.
    public static Boolean matchFreight (Freight__c freight, OrderItem orderItem, Map<Id, Order> orderMap, Map<Id, Product2> productMap){
        return (String.isBlank(freight.Product__c) || freight.Product__c == orderItem.Product2Id) ||
        (String.isBlank(freight.ProductHierarchy__c) || freight.ProductHierarchy__c == productMap.get(orderItem.Product2Id).ProductHierarchy__c) ||
        (String.isBlank(freight.DistribuitionCenter__c) || freight.DistribuitionCenter__c == orderMap.get(orderItem.OrderId).DistribuitionCenter__c) ||
        (String.isBlank(freight.City__c) || freight.City__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__c) ||
        (String.isBlank(freight.States__c) || freight.States__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__r.State__c) ||
        (String.isBlank(freight.Country__c) || freight.Country__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__r.State__r.Country__c);
        
    }
    




    public static Map<OrderItem, Taxes__c> searchTaxes(List<OrderItem> orderItemList, Map<Id, Order> orderMap, Map<Id, Product2> productMap) {
        Set<Id> distribuitionCenterIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        /*
        for (Order order : orderMap.values()){
            distribuitionCenterIds.add(order.DistribuitionCenter__c);
            stateIds.add(order.AccountAddress__r.City__r.State__c);
        }
       */

        for (Product2 product : productMap.values()){
            productIds.add(product.Id);
        }

        List<Taxes__c> taxesList =[
            SELECT Id, DistribuitionCenter__c, States__c, Imposto__c, Product__c, Name
            FROM Taxes__c
            WHERE (Product__c IN: productIds OR Product__c = null) OR  
                  (DistribuitionCenter__c IN: distribuitionCenterIds OR DistribuitionCenter__c = null) OR
                  (States__c IN: stateIds OR States__c = null)   
                  
        ];
        System.debug('taxes list' + taxesList);
        Map<OrderItem, Taxes__c> orderItemToTaxes = new Map<OrderItem, Taxes__c>();     
        
        for (OrderItem orderItem : orderItemList){
            orderItemToTaxes.put(orderItem, null);

            for (Taxes__c taxes : taxesList) {
                if (matchTax(taxes, orderItem, orderMap, productMap)){
                    orderItemToTaxes.put(orderItem, taxes);
                    break;
                }
            }
            
        }
        return orderItemToTaxes;
    }

    // método para realizar o match entre order e os impostos.
    public static Boolean matchTax(Taxes__c taxes, OrderItem orderItem, Map<Id, Order> orderMap, Map<Id, Product2> productMap){
        return (String.isBlank(taxes.Product__c)                  || taxes.Product__c                         == orderItem.Product2Id) ||
               (String.isBlank(taxes.DistribuitionCenter__c)      || taxes.DistribuitionCenter__c             == orderMap.get(orderItem.OrderId).DistribuitionCenter__c)||
               (String.isBlank(taxes.States__c)                   || taxes.States__c                          == orderMap.get(orderItem.OrderId).AccountAddress__r.City__r.State__c);
    }
    
}
