public with sharing class boxServiceClass {
    
    private static string boxTokenURL = 'https://api.box.com/oauth2/token';
    private static String peopleApiEndpoint = 'https://api.box.com/2.0/users/me';
    private static String filesEndpoint = 'https://api.box.com/2.0';
    private static String uploadFileToBox = 'https://upload.box.com/api/2.0/files/content';

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
        req.setTimeout(30*1000);
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

    public static IntegrationWrapperClass createFolderBox(String accessToken, String folderName, String parentId){
        HttpRequest request = new HttpRequest();
        Map<String, Object> metadataMap = new Map<String, Object>{
            'name' => folderName,
            'mimeType' => 'application/vnd.google-apps.folder'
        };
        if (!String.isBlank(parentId)) {
            metadataMap.put('parent', new Map<String, String>{'id' => parentId});
        } else {
            metadataMap.put('parent', new Map<String, String>{'id' => '0'});
        }
        String bodyRequest = JSON.serialize(metadataMap);
        request.setEndpoint('https://api.box.com/2.0/folders');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);  
        request.setHeader('Content-Type', 'application/json');        
        request.setBody(bodyRequest);                                  
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('Response Status Code: ' + response.getStatusCode());
        System.debug('Response Body: ' + response.getBody());
        return new IntegrationWrapperClass(response.getBody(), String.valueOf(response.getStatusCode()));
    }

    public static IntegrationWrapperClass deleteFileOrFolder(String accessToken, String itemId, String type) {
        HttpRequest req = new HttpRequest();
        String url = '';
        System.debug(type);
        System.debug('to delete');        
        if (type == 'folders') {
            System.debug('in folder delete');
            url = 'https://api.box.com/2.0/folders/' + itemId + '?recursive=true'; // URL to delete a folder (recursive)
        } else {
            url = 'https://api.box.com/2.0/files/' + itemId; // URL to delete a file
        }
        req.setMethod('DELETE');
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        Http http = new Http();
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 204) {
            return new IntegrationWrapperClass('Success', String.valueOf(response.getStatusCode()));
        } else {
            return new IntegrationWrapperClass('Error: ' + response.getBody(), String.valueOf(response.getStatusCode()));
        }
    }
   
    public static IntegrationWrapperClass downloadFile(String accessToken, String fileId){
        HttpRequest req = new HttpRequest();
        String url = filesEndpoint+'/files/'+fileId+'/content';
        req.setMethod('GET');
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        Http http = new Http();
        HttpResponse response = http.send(req);
        return new IntegrationWrapperClass(response.getBody(), String.valueof(response.getStatusCode()), response.getHeader('location'));

    }

    /*
        preview file
        IntegrationWrapperClass 
    */
    public static IntegrationWrapperClass previewFile(String accessToken, String fileId){
        HttpRequest req = new HttpRequest();
        String url = filesEndpoint+'/files/'+fileId+'?fields=expiring_embed_link';
        req.setMethod('GET');
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(req);
        return new IntegrationWrapperClass(response.getBody(), String.valueof(response.getStatusCode()), response.getHeader('location'));

    }

    public static IntegrationWrapperClass uploadFile(String accessToken, String fileName, String fileContent, String parentFolderId){
        Blob base64EncodeFile = base64EncodeFileContent(EncodingUtil.base64Decode(fileContent), fileName);
        String uploadEndPointURL = uploadFileToBox+'?parent_id='+parentFolderId;
        String boundary = '----------------------------741e90d31eff';
        String body = '{"name":"' + fileName + '", "parent":{"id":"' + parentFolderId + '"}}';
        HttpRequest req = new HttpRequest();
        req.setBody(body);
        req.setBodyAsBlob(base64EncodeFile);
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('POST');
        req.setEndpoint(uploadEndPointURL);
        Http ht = new Http();
        HTTPResponse response = ht.send(req);
        return new IntegrationWrapperClass(response.getBody(), String.valueof(response.getStatusCode()));

    }

    public static blob base64EncodeFileContent(Blob fileContent, String fileName){
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+fileName+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header += ' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(fileContent);
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4, bodyEncoded.length());
  
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0, 2) + '0K';
            bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
  
        return bodyBlob;
    }

}