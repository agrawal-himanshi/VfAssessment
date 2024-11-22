public with sharing class GoogleDriveServiceClass {
    private static String googleDriveOAuthToken = 'https://oauth2.googleapis.com/token';
    private static String googleDriveRefreshToken = 'https://www.googleapis.com/oauth2/v4/token';
    private static String filesEndpoint = 'https://www.googleapis.com/drive/v3/files';
    private static String uploadFileGoogleDrive = 'https://www.googleapis.com/upload/drive/v3/files';
    private static String peopleApiEndpoint = 'https://people.googleapis.com/v1/people/me?personFields=names,emailAddresses';
        
    public static IntegrationWrapperClass getaccessToken(String clientId, String clientSecret, String code, String redirectUri){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://oauth2.googleapis.com/token');  
        system.debug(code);
        string bodyRequest = '';
        bodyRequest = 'code=' + EncodingUtil.urlEncode(code, 'UTF-8');
        bodyRequest+= '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8');
        bodyRequest+= '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8');
        bodyRequest+= '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8');
        bodyRequest+= '&grant_type=authorization_code';
        system.debug(bodyRequest);
        req.setBody(bodyRequest);    
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setTimeout(60*1000);
        HttpResponse res = h.send(req);
        system.debug(res.getStatusCode());
        // if (res.getStatusCode() != 200) {
        //     System.debug('Error: ' + res.getBody());
        //     throw new AuraHandledException('Authorization failed with status ' + res.getStatusCode());
        // }
        return new IntegrationWrapperClass(res.getBody(),String.valueof(res.getStatusCode()));
    }

    public static IntegrationWrapperClass getUserDetails(String accessToken) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(peopleApiEndpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        HttpResponse res = h.send(req);
        System.debug('Status Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());
        if (res.getStatusCode() != 200) {
            System.debug('Error Response: ' + res.getBody());
            throw new AuraHandledException('Failed to retrieve user details with status ' + res.getStatusCode());
        }             
        return new IntegrationWrapperClass(res.getBody(),String.valueof(res.getStatusCode()));
    }

    public static IntegrationWrapperClass getAccessTokenFromRefershToken(String clientId, String clientSecret, String refreshToken){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(googleDriveRefreshToken);  
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
        return new IntegrationWrapperClass(res.getBody(),String.valueof(res.getStatusCode()));
    }

    public static IntegrationWrapperClass getfilesFolders(String accessToken, String currentFolder){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String url = filesEndpoint+'?q=\''+EncodingUtil.urlEncode(currentFolder, 'UTF-8')+ '\'+in+parents&trashed=false&fields=files(id%2Cname%2CmimeType%2Csize%2CwebViewLink%2CwebContentLink%2Ctrashed)&orderBy=folder&';        
        request.setEndpoint(url);  
        request.setHeader('Authorization', 'Bearer '+accessToken);
        request.setMethod('GET');
        request.setTimeout(60*1000);
        
        HttpResponse response = http.send(request);
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }

    public static IntegrationWrapperClass deleteFileOrFolder(String accessToken, String fileId){
        HttpRequest request = new HttpRequest();
        String url = filesEndpoint+'/'+fileId;
        request.setEndpoint(url);
        request.setMethod('DELETE');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
        system.debug(response.getBody());
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));

    }

    public static IntegrationWrapperClass createFolderInGoogleDrive(String accessToken, String folderName, String parentId){
        HttpRequest request = new HttpRequest();
        String bodyRequest = JSON.serialize(new Map<String, Object>{
            'name' => folderName,
            'mimeType' => 'application/vnd.google-apps.folder',
            'parents' => new List<String>{parentId}
        });
        request.setEndpoint(filesEndpoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(bodyRequest);
        Http http = new Http();
        HttpResponse response = http.send(request);
        system.debug(response.getBody());
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }

    public static IntegrationWrapperClass uploadFile(String accessToken, String fileName, String fileContent,String folderId,String mimeType){
        Blob fileBlob = EncodingUtil.base64Decode(fileContent);
        Map<String, Object> metadataMap = new Map<String, Object>{
            'name' => fileName,
            'mimeType' => mimeType
        };
        if (!String.isBlank(folderId)) {
            metadataMap.put('parents', new List<String>{folderId});
        }
        String metadata = JSON.serialize(metadataMap);
        String boundary = '-------314159265358979323846';
        String delimiter = '--' + boundary + '\r\n';
        String closeDelimiter = '\r\n--' + boundary + '--';

        String body = delimiter +
        'Content-Type: application/json; charset=UTF-8\r\n\r\n' +
        metadata + '\r\n' +
        delimiter +
        'Content-Type: ' + mimeType + '\r\n' +
        'Content-Transfer-Encoding: base64\r\n\r\n' +
        EncodingUtil.base64Encode(fileBlob) +
        closeDelimiter;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uploadFileGoogleDrive);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'multipart/related; boundary=' + boundary);
        req.setBody(body);
        Http http = new Http();
        HttpResponse response = http.send(req);
        System.debug(response.getBody());
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));

    }

    public static IntegrationWrapperClass revokeToken(String accessToken) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://accounts.google.com/o/oauth2/revoke?token=' + accessToken);
        request.setMethod('POST');
        request.setHeader('Content-Length', '0');
        HttpResponse response = http.send(request);
        System.debug('Status Code: ' + response.getStatusCode());
        System.debug('Response Body: ' + response.getBody());
        if (response.getStatusCode() != 200) {
            System.debug('Error Response: ' + response.getBody());
            throw new AuraHandledException('Failed to revoke user ' + response.getStatusCode());
        }             
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }

}