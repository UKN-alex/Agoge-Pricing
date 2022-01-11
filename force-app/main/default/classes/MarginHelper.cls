public with sharing class MarginHelper {
    public MarginHelper() {

    }

    // Definição do meu método para validção de categoria, ao menos uma das categorias devem ser preenchidas
    public static void validateMarginCetegory(List<Margin__c> marginList){
        for (Margin__c margin : marginList){
            // condição para informar erros

            // Se ele retornar false na validação Boolean ele estrará aqui
            if(!validateMarginCategories(margin)){
                margin.addError('Preencha corretamente a estrutura de especificação da Margem.');
            }
        }
    }

    // Neste metódo de validação verifico se mues capos de especificidade estão preenchidos conforme proposto
    public static Boolean validateMarginCategories(Margin__c margin){
        if ((String.isBlank(margin.Product__c) && String.isBlank(margin.ProductHierarchy__c )) ||
            (String.isBlank(margin.Account__c) && String.isBlank(margin.AccountGroup__c )) ||
            (String.isBlank(margin.City__c) && String.isBlank(margin.States__c ) && String.isBlank(margin.Country__c))
        ){
            //Se os campos estiverem vazios o retorno será false
            return false;
        }
            // Caso os campos sejam verdadeiros o retorno será True
            return true;
    }

    
    public static void calcScore (List<Margin__c> marginList){
        // Calc score = Regra de especificidade baseado nos parametros de maior valor
        for (Margin__c margin : marginList){

            //calc score
            Integer score = 0; 
            // Validação sempre pelo comapo mais forte, depois passa para o de menor pontuação.
            if (String.isNotBlank(margin.Product__c)) {
                score += 2000;
            }
            else if (String.isNotBlank(margin.ProductHierarchy__c)){
                score += 1000;
            }

            if (String.isNotBlank(margin.Account__c)){
                score += 200;
            }
            else if (String.isNotBlank(margin.AccountGroup__c)){
                score += 100;
            }

            if (String.isNotBlank(margin.City__c)){
                score += 30;
            }
            else if (String.isNotBlank(margin.States__c)){
                score += 20;
            }
            else if (String.isNotBlank(margin.Country__c)){
                score+= 10;
            }
            System.debug('Score total de especificidade => ' + score);
            margin.Score__c = score;
        }
        
    }

}
