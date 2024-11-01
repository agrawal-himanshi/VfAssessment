public class DropBoxServiceClass {

    private static String dropboxOAuthAuthorize = 'https://www.dropbox.com/oauth2/authorize';
    private static String dropboxOAuthToken = 'https://api.dropboxapi.com/oauth2/token';
    private static String listOfFilesAndFolder = 'https://api.dropboxapi.com/2/files/list_folder';
    private static String checkAccessTokenExipry = 'https://api.dropboxapi.com/2/auth/token/revoke';
    private static String createFolder = 'https://api.dropboxapi.com/2/files/create_folder_v2';
    private static String uploadFileToDropBox = 'https://content.dropboxapi.com/2/files/upload';
    private static String previewAFile = 'https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings';
    private static String previewAFiles = 'https://api.dropboxapi.com/2/sharing/list_shared_links';
    private static String downloadAFile = 'https://api.dropboxapi.com/2/files/get_temporary_link';
    private static String deleteFile = 'https://api.dropboxapi.com/2/files/delete_v2';
    private static String revokeToken = 'https://api.dropboxapi.com/2/auth/token/revoke';

    public static IntegrationWrapperClass getAccessToken(String clientId, String clientSecret, String code,String redirectUri){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(dropboxOAuthToken);  
        string bodyRequest = '';
        bodyRequest = 'code=' + EncodingUtil.urlEncode(code, 'UTF-8');
        bodyRequest+= '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8');
        bodyRequest+= '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8');
        bodyRequest+= '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8');
        bodyRequest+= '&grant_type=authorization_code';
            
        req.setBody(bodyRequest);    
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setTimeout(60*1000);
            
        HttpResponse res = h.send(req);
        return new IntegrationWrapperClass(res.getBody(),String.valueof(res.getStatusCode()));
    }

    public static IntegrationWrapperClass revokeAccessToken(String accessToken) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(revokeToken);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);    
        Http http = new Http();
        HttpResponse res = http.send(request);
        System.debug('Response Status Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());
        return new IntegrationWrapperClass(res.getBody(), String.valueOf(res.getStatusCode()));
    }
    
    public static IntegrationWrapperClass getAccessTokenFromRefershToken(String clientId, String clientSecret, String refreshToken){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(dropboxOAuthToken);  
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

    public static IntegrationWrapperClass getfilesAndFolders(String accessToken, String currentFolder){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(listOfFilesAndFolder);  
        string body = '{'+
            '"include_deleted": false,'+
            '"include_has_explicit_shared_members": false,'+
            '"include_media_info": false,'+
            '"include_mounted_folders": true,'+
            '"include_non_downloadable_files": true,'+
            '"path": "' + currentFolder + '",' +
            '"recursive": false'+
        '}';
        request.setBody(body);    
        request.setHeader('Authorization', 'Bearer '+ accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setTimeout(60*1000);
        HttpResponse response = http.send(request);
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }

    public static IntegrationWrapperClass createFolderInDropBox(String accessToken, String filePath){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(createFolder);
        system.debug('111111');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        String jsonBody = '{"path":"' + filePath + '"}';
    	request.setBody(jsonBody);
        Http http = new Http();
        HttpResponse response = http.send(request);
        system.debug('22222');
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }
    
    public static IntegrationWrapperClass uploadFile(String accessToken, String filePath, String fileContents){
        Blob fileBlob = EncodingUtil.base64Decode(fileContents);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uploadFileToDropBox);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Dropbox-API-Arg', '{"path": "' + filePath + '", "mode": "add", "autorename": false, "mute": false, "strict_conflict": false}');
        req.setHeader('Content-Type', 'application/octet-stream');
        req.setBodyAsBlob(fileBlob);
        Http http = new Http();
        HttpResponse response = http.send(req);
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }

    public static IntegrationWrapperClass getFilePreviewLink(String accessToken, String filePath){
        HttpRequest request = new HttpRequest();
        String body ='{'+
        '"path": "'+filePath+'",'+
        '"settings": {'+
            '"access": "viewer",'+
            '"allow_download": true,'+
            '"audience": "public",'+
            '"requested_visibility": "public"'+
        '}}';
        request.setEndpoint(previewAFile);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        Http http = new Http();
        HttpResponse response = http.send(request);
        system.debug(response.getBody());
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }

    public static IntegrationWrapperClass getFilePreviewLinks(String accessToken, String filePath){
        HttpRequest request = new HttpRequest();
        String body ='{'+
        '"path": "'+filePath+'"'+
        '}';
        request.setEndpoint(previewAFiles);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        Http http = new Http();
        HttpResponse response = http.send(request);
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }

    public static IntegrationWrapperClass fileDownload(String accessToken, String filePath){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(downloadAFile);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"path": "' + filePath + '"}');
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        System.debug(response.getStatusCode());
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }

    public static IntegrationWrapperClass deleteFileOrFolder(String accessToken, String filePath){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(deleteFile);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"path":"' + filePath + '"}');
        Http http = new Http();
        HttpResponse response = http.send(request);
        return new IntegrationWrapperClass(response.getBody(),String.valueof(response.getStatusCode()));
    }
}