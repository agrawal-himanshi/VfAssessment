public with sharing class PaymentGatewayService {

    public static IntegrationWrapperClass authorizeApi(String body) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apitest.authorize.net/xml/v1/request.api');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(body);
        HttpResponse res = new HttpResponse();
        res = h.send(req);
        System.debug(res.getBody());
        return new IntegrationWrapperClass (res.getBody(), String.valueOf(res.getStatusCode()));
    }

}