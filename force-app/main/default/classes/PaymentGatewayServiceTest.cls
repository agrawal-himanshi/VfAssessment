@isTest
public class PaymentGatewayServiceTest implements HttpCalloutMock {

    public HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String body ='';
        if(req.getBody().contains('creditCard') && req.getBody().contains('5424000000000015')){
            body = '{"description":"This transaction has been approved.", "resultCode":"Ok"}';
        }         	
        else if (req.getBody().contains('creditCard') && req.getBody().contains('0000000000000000')){
            body = '{"errorText":"This transaction is Unsuccessful", "resultCode":"Error"}';
        }
        if(req.getBody().contains('bankAccount') && req.getBody().contains('1234567890')){
            body = '{"description":"This transaction has been approved.", "resultCode":"Ok"}';
        }         	
        else if (req.getBody().contains('bankAccount') && req.getBody().contains('0000000000')){
            body = '{"errorText":"This transaction is Unsuccessful", "resultCode":"Error"}';
        }
        res.setBody(body);
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }

}