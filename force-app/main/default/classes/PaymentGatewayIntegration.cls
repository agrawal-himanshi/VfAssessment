public with sharing class PaymentGatewayIntegration {
    
    @AuraEnabled
    public static String cardPayment(String cardNumber, String cardMonth, String cardYear, String cvv){
        String errorMessage = '';
        try{
            IntegrationAssignment__mdt metadata = getCredentials();
            String email = 'test@g.com';
            String loginId = metadata.AppKey__c; // these get from authurize.net sandbox account tab
            String transactionKey = metadata.AppSecret__c;// these get from authurize.net sandbox account tab
            String amount = '2000';
            //create JSON body JSON Genertor
            JSONGenerator payBody = JSON.createGenerator(true);
            payBody.writeStartObject();//1
            payBody.writeFieldName('createTransactionRequest');
            
            payBody.writeStartObject();//2
            payBody.writeFieldName('merchantAuthentication');
            
            payBody.writeStartObject();//3
            payBody.writeStringField('name', loginId);
            payBody.writeStringField('transactionKey', transactionKey);
            payBody.writeEndObject();
            
            payBody.writeStringField('refId', '123456');
            payBody.writeFieldName('transactionRequest');
            
            payBody.writeStartObject();//4
            payBody.writeStringField('transactionType', 'authCaptureTransaction');
            payBody.writeStringField('amount', amount);
            payBody.writeFieldName('payment');
            
            payBody.writeStartObject();//5
            payBody.writeFieldName('creditCard');
            
            payBody.writeStartObject();//6
            payBody.writeStringField('cardNumber', cardNumber);
            payBody.writeStringField('expirationDate', cardYear + '-' + cardMonth);
            payBody.writeStringField('cardCode', cvv);
            payBody.writeEndObject();
            
            payBody.writeEndObject();
            
            payBody.writeFieldName('customer');
            payBody.writeStartObject();
            if(String.isNotBlank(email)){
                payBody.writeStringField('email', email);    
            }
            payBody.writeEndObject();
            payBody.writeEndObject();
            payBody.writeEndObject();
            payBody.writeEndObject();

            IntegrationWrapperClass response = PaymentGatewayService.AuthorizeApi(payBody.getAsString());
            if(response.responseStatusCode == '200') {
                if(response.responseBody.substringBetween('"resultCode":"', '"') == 'Ok') {
                    return response.responseBody.substringBetween('"description":"', '"');
                }
                else {
                    String error = response.responseBody.substringBetween('"errorText":"', '"');
                    errorMessage = error;
                    throw new AuraHandledException(error);
                }
            }
            return 'Unsuccessful Transaction';      
        } 
        catch (Exception e) {
            throw new AuraHandledException(String.isBlank(errorMessage)?e.getMessage():errorMessage);
        }   
    }

    @AuraEnabled
    public static String eCheckPayment(String routingNumber, String accountNumber, String nameOnAccount){
        String errorMessage = '';
        try{
            IntegrationAssignment__mdt metadata = getCredentials();
            String email = 'test@g.com';
            String loginId = metadata.AppKey__c; // these get from authurize.net sandbox account tab
            String transactionKey = metadata.AppSecret__c;// these get from authurize.net sandbox account tab
            String amount = '500';
            //create JSON body JSON Genertor
            JSONGenerator payBody = JSON.createGenerator(true);
            payBody.writeStartObject();//1
            payBody.writeFieldName('createTransactionRequest');
            
            payBody.writeStartObject();//2
            payBody.writeFieldName('merchantAuthentication');
            
            payBody.writeStartObject();//3
            payBody.writeStringField('name', loginId);
            payBody.writeStringField('transactionKey', transactionKey);
            payBody.writeEndObject();
            
            payBody.writeStringField('refId', '123456');
            payBody.writeFieldName('transactionRequest');
            
            payBody.writeStartObject();//4
            payBody.writeStringField('transactionType', 'authCaptureTransaction');
            payBody.writeStringField('amount', amount);
            payBody.writeFieldName('payment');
            
            payBody.writeStartObject();//5
            payBody.writeFieldName('bankAccount');
            
            payBody.writeStartObject();//6
            payBody.writeStringField('accountType', 'checking');
            payBody.writeStringField('routingNumber', routingNumber);
            payBody.writeStringField('accountNumber', accountNumber);
            payBody.writeStringField('nameOnAccount', nameOnAccount);
            payBody.writeEndObject();
            
            payBody.writeEndObject();
            
            payBody.writeFieldName('customer');
            payBody.writeStartObject();
            if(String.isNotBlank(email)){
                payBody.writeStringField('email', email);    
            }
            payBody.writeEndObject();
            payBody.writeEndObject();
            payBody.writeEndObject();
            payBody.writeEndObject();

            IntegrationWrapperClass response = PaymentGatewayService.AuthorizeApi(payBody.getAsString());
            if(response.responseStatusCode == '200') {
                if(response.responseBody.substringBetween('"resultCode":"', '"') == 'Ok') {
                    return response.responseBody.substringBetween('"description":"', '"');
                }
                else {
                    String error = response.responseBody.substringBetween('"errorText":"', '"');
                    errorMessage = error;
                    throw new AuraHandledException(error);
                }
            }
            return 'Unsuccessful Transaction';      
        } 
        catch (Exception e) {
            throw new AuraHandledException(String.isBlank(errorMessage)?e.getMessage():errorMessage);
        }   
    }

    @AuraEnabled
    public static IntegrationAssignment__mdt getCredentials() {
        IntegrationAssignment__mdt metaData = IntegrationAssignment__mdt.getInstance('PaymentGatewayIntegration');
        return metaData;
    }
   
}