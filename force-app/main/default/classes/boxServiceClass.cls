public with sharing class boxServiceClass {
    
    private static string boxTokenURL = 'https://api.box.com/oauth2/token';
    private static String peopleApiEndpoint = 'https://api.box.com/2.0/users/me';
    private static String filesEndpoint = 'https://api.box.com/2.0';
    // private static String uploadFileToBox = 'https://upload.box.com/api/2.0/files/content';

    /* 
        getting access token with authorization code.
        IntegrationWrapperClass 
    */
    public static IntegrationWrapperClass getaccessToken(String clientId, String clientSecret, String code){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(boxTokenURL);  
        system.debug(code);
        string bodyRequest = '';
        bodyRequest = 'code=' + EncodingUtil.urlEncode(code, 'UTF-8');
        bodyRequest+= '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8');
        bodyRequest+= '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8');
        bodyRequest+= '&grant_type=authorization_code';
        system.debug(bodyRequest);
        req.setBody(bodyRequest);    
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setTimeout(60*1000);
        HttpResponse res = h.send(req);
        System.debug(res.getBody());
        system.debug(res.getStatusCode());
        if (res.getStatusCode() != 200) {
            System.debug('Error: ' + res.getBody());
            throw new AuraHandledException('Authorization failed with status ' + res.getStatusCode());
        }
        return new IntegrationWrapperClass(res.getBody(),String.valueof(res.getStatusCode()));
    }

    public static IntegrationWrapperClass getUserDetails(String accessToken) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(peopleApiEndpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + accessToken);        
        HttpResponse response = http.send(request);
        System.debug('Status Code: ' + response.getStatusCode());
        System.debug('Response Body: ' + response.getBody());
        if (response.getStatusCode() != 200) {
            System.debug('Error Response: ' + response.getBody());
            throw new AuraHandledException('Failed to retrieve user details with status ' + response.getStatusCode());
        }        
        return new IntegrationWrapperClass(response.getBody(), String.valueOf(response.getStatusCode()));
    }
    
    public static IntegrationWrapperClass getAccessTokenFromRefershToken(String clientId, String clientSecret, String refreshToken){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(boxTokenURL);  
        string bodyRequest = '';
        bodyRequest = 'grant_type=refresh_token';
        bodyRequest+= '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8');
        bodyRequest+= '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8');
        bodyRequest+= '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8');                   
        req.setBody(bodyRequest); 
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setTimeout(60*1000);
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        return new IntegrationWrapperClass(res.getBody(),String.valueof(res.getStatusCode()));
    }

    public static IntegrationWrapperClass getfilesFolders(String accessToken, String currentFolder){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(filesEndpoint + '/folders/' + currentFolder + '/items');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        Http http = new Http();
        HttpResponse response = http.send(req);
        System.debug(response.getBody());
        return new IntegrationWrapperClass(response.getBody(), String.valueof(response.getStatusCode()));
    }

}