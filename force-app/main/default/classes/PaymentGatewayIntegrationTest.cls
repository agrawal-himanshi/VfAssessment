@isTest
public class PaymentGatewayIntegrationTest {

    @IsTest
    public static void cardPaymentTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PaymentGatewayServiceTest());
        String result = PaymentGatewayIntegration.cardPayment('5424000000000015','12','2025','999');
        Test.stopTest();
        System.assertEquals('This transaction has been approved.', result, 'Transaction is approved');
    }

    @IsTest
    public static void cardPaymentTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PaymentGatewayServiceTest());
        try{
            String result = PaymentGatewayIntegration.cardPayment('0000000000000000','12','2025','999');
        }catch(Exception e){
             Assert.areEqual('Script-thrown exception', e.getMessage(), 'error message');
        }
        Test.stopTest();
    }

    @IsTest
    public static void eCheckPaymentTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PaymentGatewayServiceTest());
        String result = PaymentGatewayIntegration.eCheckPayment('1234567890','234213242','Sam');
        Test.stopTest();
        System.assertEquals('This transaction has been approved.', result, 'Transaction is approved');
    }

    @IsTest
    public static void eCheckPaymentTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PaymentGatewayServiceTest());
        try{
            String result = PaymentGatewayIntegration.eCheckPayment('0000000000','234213242','Sam');
        }catch(Exception e){
             Assert.areEqual('Script-thrown exception', e.getMessage(), 'error message');
        }
        Test.stopTest();
    }

}