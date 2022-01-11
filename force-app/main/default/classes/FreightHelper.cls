public with sharing class FreightHelper {
    public FreightHelper() {

    }


    public static void validateFreightCategory(List<Freight__c> freightList){
        for (Freight__c freight : freightList){

            if(!vaildateFreightCategories(freight)){
                freight.addError('Preencha corretamente a estrutura do FRETE');
            }
        }
    }

    public static Boolean vaildateFreightCategories(Freight__c freight){
        if ((String.isBlank(freight.Product__c) && String.isBlank(freight.ProductHierarchy__c )) ||
        (String.isBlank(freight.City__c) && String.isBlank(freight.States__c ) && String.isBlank(freight.Country__c))
    ){
        //Se os campos estiverem vazios o retorno será false
        return false;
    }
        // Caso os campos sejam verdadeiros o retorno será True
        return true;
    }

    public static void calcScore(List<Freight__c> freightList){

        for (Freight__c freight : freightList){

            Integer score = 0;

            if (String.isNotBlank(freight.Product__c)){
                score += 2000;
            }
            else if (String.isNotBlank(freight.ProductHierarchy__c)) {
                score += 1000;
            }

            if(String.isNotBlank(freight.City__c)){
                score += 30;
            }
            else if (String.isNotBlank(freight.States__c)){
                score += 20;
            }
            else if (String.isNotBlank(freight.Country__c)){
                score += 10;
            }

            System.debug('Score total de especificidade de Frete' + score);
            freight.Score__c = score;
        }
    }
}
