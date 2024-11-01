/*  
Class Name           : DropboxIntegrationController
Description          : Controller class for DropBox component
Developer Name       : Himanshi Agrawal 
*/
public with sharing class DropboxIntegrationController {
    private static String dropboxOAuthAuthorize = 'https://www.dropbox.com/oauth2/authorize';
    private static String redirectUri ='https://briskmindssoftwaresoluti-6b-dev-ed.develop.my.site.com/dropboxCommunity/s/';
    
    /*method name : createAuthURL
     Description  : Method is used to create Authorization URL
     Return type  : List<DropboxFile>
    */
    @AuraEnabled
    public static List<DropboxFile> createAuthURL() {
        try {
            IntegrationAssignment__mdt dropBox = getMetaData();
            String currentFolder='root';
            List<DropboxFile> data; 
            String authuri = dropboxOAuthAuthorize+'?client_id='+dropBox.AppKey__c+'&token_access_type=offline&response_type=code&+&scope=files.metadata.read sharing.write files.metadata.write files.content.write files.content.read &redirect_uri=' + redirectUri;    
            ApexPages.PageReference uri = new PageReference(authuri);
            system.debug(uri);
            Integration_Access__c tokens = getTokens(); 
            system.debug(tokens);
            if(tokens==null){
                aura.redirect(uri);
                system.debug(uri);
                return new List<DropboxFile>();
            }           
            if(tokens.Expire_In_Time__c < System.now()){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(dropBox.AppKey__c,dropBox.AppSecret__c,tokens.Refresh_Token__c);
                data = getFileAndFolders(jsonValues.get('access_token'),currentFolder,true);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'));
            }
            if (tokens!= null) {
                data = getFileAndFolders(tokens.Access_Token__c, currentFolder, false);
            } 
            return data;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*method name : getAccessToken
     Description  : Method is used to get Access Token
     parameters passed : code,currentFolder
     Return type  : List<DropboxFile>
    */    
    @AuraEnabled
    public static List<DropboxFile> getAccessToken(String code,String currentFolder) {
        try{    
            IntegrationAssignment__mdt dropBox = getMetaData();
            List<DropboxFile> data = new List<DropboxFile>();
            Map<string, string> jsonValues = new Map<string, string>();
            IntegrationWrapperClass res = DropBoxServiceClass.getAccessToken(dropBox.AppKey__c,dropbox.AppSecret__c,code,redirectUri);
            system.debug(res);
            system.debug(res.responseStatusCode);
            if(res.responseStatusCode == '200') {  
                jsonValues= parseBody(res.responseBody);   
                system.debug(jsonValues);         
                data = getFileAndFolders(jsonValues.get('access_token'),currentFolder,true);
                system.debug(data);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'));
            }
            else {
                throw new AuraHandledException(res.responseBody);
            }
            return data;
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*method name : getFileAndFolders
     Description  : Method is used to get file and folder 
     parameters passed : accessToken, currentFolder, isNew
     Return type  : List<DropboxFile>
    */    
    @AuraEnabled
    public static List<DropboxFile> getFileAndFolders(String accessToken,String currentFolder,Boolean isNew){
        try {
            Integration_Access__c tokens=getTokens();
            IntegrationAssignment__mdt dropBox = getMetaData();
            IntegrationWrapperClass response;
            List<DropboxFile> files = new List<DropboxFile>();
            if(currentFolder=='root'||currentFolder==null){
                currentFolder='';           
            }
            if(accessToken==''||accessToken==null){
                accessToken=tokens.Access_Token__c;
            }
            if(isNew){
                response = DropBoxServiceClass.getfilesAndFolders(accessToken,currentFolder); 
            }
            else if(tokens.Expire_In_Time__c < System.now()||String.isBlank(tokens.Access_Token__c)||String.isBlank(tokens.Refresh_Token__c)){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(dropBox.AppKey__c,dropBox.AppSecret__c,tokens.Refresh_Token__c);
                response = DropBoxServiceClass.getfilesAndFolders(jsonValues.get('access_token'),currentFolder); 
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'));
            }
            else{
                response = DropBoxServiceClass.getfilesAndFolders(accessToken,currentFolder); 
            }
            if (response.responseStatusCode == '200') {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody);
                List<Object> entries = (List<Object>) responseBody.get('entries');
                for (Object entry : entries) {
                    Map<String, Object> entryMap = (Map<String, Object>) entry;
                    String tag = (String) entryMap.get('.tag');
                    String name = (String) entryMap.get('name');
                    String id = (String) entryMap.get('id');
                    String pathLower = (String) entryMap.get('path_lower');
                    
                    String fileType;
                    Boolean isDownloadable = false;
                    String previewUrl = '';

                    if (tag == 'file') {
                        fileType = getFileTypeFromExtension(name);
                        isDownloadable = (Boolean) entryMap.get('is_downloadable');
                    } else if (tag == 'folder') {
                        fileType = 'folder';
                        isDownloadable = false;
                    }
                    DropboxFile dropboxFile = new DropboxFile(name, fileType, isDownloadable, id,pathLower);
                    files.add(dropboxFile);
                }
            } 
            else if(response.responseStatusCode == '401') {
                Map<string, string> jsonValues = accessTokenWithRefreshToken(dropBox.AppKey__c,dropBox.AppSecret__c,tokens.Refresh_Token__c);
                files = getFileAndFolders(jsonValues.get('access_token'),currentFolder,true);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'));
            }
            else {
                throw new AuraHandledException(response.responseBody);
            }
            return files;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*method name : getPreview
     Description  : Method is used to view file in dropbox 
     parameters passed : filePath
     Return type  : String --> give url
    */  
    @AuraEnabled
    public static String getPreview(String filePath) {
        try {
            IntegrationAssignment__mdt dropBox = getMetaData();
            Integration_Access__c tokens=getTokens();
            String accessToken=tokens.Access_Token__c;
            IntegrationWrapperClass response;
            if(tokens.Expire_In_Time__c < System.now()){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(dropBox.AppKey__c,dropBox.AppSecret__c,tokens.Refresh_Token__c);
                accessToken=jsonValues.get('access_token');
                response = DropBoxServiceClass.getFilePreviewLink(accessToken,filePath);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'));
            }
            else{
                response = DropBoxServiceClass.getFilePreviewLink(accessToken,filePath);
            }
            if(response.responseStatusCode=='200'){
                Map<String , String> url = parseBOdy(response.responseBody);
                return url.get('url');
            }
            else if(response.responseStatusCode=='409'){
                response = DropBoxServiceClass.getFilePreviewLinks(accessToken,filePath);
                String url='';
                System.debug(response.responseBody);
                System.debug(response.responseStatusCode);
                if(response.responseStatusCode=='200'){
                    Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody);
                    List<Object> links = (List<Object>) responseBody.get('links');
                    for (Object entry : links) {
                        Map<String, Object> linkMap = (Map<String, Object>) entry;
                        url=(String) linkMap.get('url');
                    } 
                }
                return url;               
            }
            else{
                throw new AuraHandledException(response.responseBody);
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*method name : doRevokeAccessToken
     Description  : Method is used to revoke 
     Return type  : String --> give url of homepage
    */  
    @AuraEnabled
    public static String doRevokeAccessToken() {    
        try {
            IntegrationAssignment__mdt dropBox = getMetaData();
            Integration_Access__c tokens = getTokens();
            String accessToken = tokens.Access_Token__c;
            IntegrationWrapperClass response;
            response = DropBoxServiceClass.revokeAccessToken(accessToken);
            System.debug(response.responseStatusCode);
            if (response.responseStatusCode == '200') { 
                Integration_Access__c accessRecord = [SELECT Id FROM Integration_Access__c WHERE Access_Token__c = :accessToken LIMIT 1];
                delete accessRecord;
                return redirectUri;
            } else {
                return 'Failed to revoke access token: ' + response.responseBody;
            }
            
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    /*method name : createFolderInDropBox
     Description  : Method is used to create folder  
     parameters passed : current(currentfolder),filePath
     Return type  : List<DropboxFile>
    */       
    @AuraEnabled
    public static List<DropboxFile> createFolderInDropBox(String current,String filePath){
        try {
            IntegrationAssignment__mdt dropBox = getMetaData();
            Integration_Access__c tokens=getTokens();
            String accessToken=tokens.Access_Token__c;
            IntegrationWrapperClass response;
            if(tokens.Expire_In_Time__c < System.now()){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(dropBox.AppKey__c,dropBox.AppSecret__c,tokens.Refresh_Token__c);
                accessToken=jsonValues.get('access_token');
                response = DropBoxServiceClass.createFolderInDropBox(accessToken,filePath);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'));
            }
            else{
                response = DropBoxServiceClass.createFolderInDropBox(accessToken,filePath);
                system.debug(response.responseStatusCode);
            }
            
            if(response.responseStatusCode=='200'){
                system.debug(response.responseStatusCode);
                List<DropboxFile> data= getFileAndFolders(accessToken,current,false);
                system.debug(data);
                return data;
            }
            else{
                throw new AuraHandledException(response.responseBody);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*method name : uploadFile
     Description  : Method is used to upload File 
     parameters passed : current(currentfolder), filePath, fileContents
     Return type  : List<DropboxFile>
    */ 
    @AuraEnabled
    public static List<DropboxFile> uploadFile(String current,String filePath, String fileContents) {
        try {
            IntegrationAssignment__mdt dropBox = getMetaData();
            Integration_Access__c tokens=getTokens();
            String accessToken=tokens.Access_Token__c;
            IntegrationWrapperClass response;
            if(tokens.Expire_In_Time__c < System.now()){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(dropBox.AppKey__c,dropBox.AppSecret__c,tokens.Refresh_Token__c);
                accessToken=jsonValues.get('access_token');
                response = DropBoxServiceClass.uploadFile(accessToken,filePath,fileContents);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'));
            }
            else{
                response = DropBoxServiceClass.uploadFile(accessToken,filePath,fileContents);
            }
            
            if(response.responseStatusCode=='200'){
                List<DropboxFile> data= getFileAndFolders(accessToken,current,false);
                return data;
            }
            else{
                throw new AuraHandledException(response.responseBody);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*method name : fileDownload
     Description  : Method is used to Download File 
     parameters passed :filePath
     Return type  : String --> url of the file
    */ 
    @AuraEnabled
    public static String fileDownload( String filePath) {
        try {
            IntegrationAssignment__mdt dropBox = getMetaData();
            Integration_Access__c tokens=getTokens();
            String accessToken = tokens.Access_Token__c;
            IntegrationWrapperClass response;            
            if(tokens.Expire_In_Time__c < System.now()){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(dropBox.AppKey__c,dropBox.AppSecret__c,tokens.Refresh_Token__c);
                response = DropBoxServiceClass.fileDownload(jsonValues.get('access_token'),filePath);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'));
            }
            else{
                response = DropBoxServiceClass.fileDownload(accessToken,filePath);
                System.debug(response);
            }
            System.debug(response.responseStatusCode);
            if(response.responseStatusCode=='200'){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody);
                String url = (String) responseMap.get('link');
                system.debug(url);
                return url;
            }
            else{
                throw new AuraHandledException(response.responseBody);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*method name : deleteFileOrFolder
     Description  : Method is used to Delete File or folder
     parameters passed :Current(currentFolder), filePath
     Return type  : List<DropboxFile>
    */ 
    @AuraEnabled
    public static List<DropboxFile> deleteFileOrFolder(String current,String filePath) {
        try {
            IntegrationAssignment__mdt dropBox = getMetaData();
            Integration_Access__c tokens=getTokens();
            String accessToken=tokens.Access_Token__c;
            IntegrationWrapperClass response;
            if(tokens.Expire_In_Time__c < System.now()){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(dropBox.AppKey__c,dropBox.AppSecret__c,tokens.Refresh_Token__c);
                accessToken=jsonValues.get('access_token');
                response = DropBoxServiceClass.deleteFileOrFolder(accessToken,filePath);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'));
            }
            else{
                response = DropBoxServiceClass.deleteFileOrFolder(accessToken,filePath);
            }
            system.debug(response.responseStatusCode);
            if(response.responseStatusCode=='200'){
                List<DropboxFile> data= getFileAndFolders(accessToken,current,false);
                return data;
            }
            else{
                throw new AuraHandledException(response.responseBody);
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class DropboxFile {
        @AuraEnabled
        public String fileName { get; set; }
        @AuraEnabled
        public String fileType { get; set; }
        @AuraEnabled
        public Boolean isDownloadable { get; set; }
        @AuraEnabled
        public String fileId { get; set; }
        @AuraEnabled
        public String pathDisplay { get; set; }

        public DropboxFile(String name, String type,  Boolean downloadable, String id,String path) {
            this.fileName = name;
            this.fileType = type;
            this.isDownloadable = downloadable;
            this.fileId = id;
            this.pathDisplay=path;
        }
    }

    @AuraEnabled
    public static IntegrationAssignment__mdt getMetaData(){
        IntegrationAssignment__mdt dropBox ;
        List<IntegrationAssignment__mdt> mcs = IntegrationAssignment__mdt.getAll().values();
        for(IntegrationAssignment__mdt drive:mcs){
            if(drive.MasterLabel=='Dropbox'){
                dropBox=drive;
                break;
            }
        }
        return dropBox;  
    }

    @AuraEnabled
    public static Integration_Access__c getTokens() {
        system.debug(UserInfo.getUserId());
        User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        system.debug(currentUser);
        String recordName = 'DROPBOX' + currentUser.Id;       
        system.debug(recordName); 
        Integration_Access__c record;
        try {
            record = [SELECT Id, Access_Token__c, Refresh_Token__c, Expire_In_Time__c 
                FROM Integration_Access__c 
                WHERE Name__c = :recordName
                LIMIT 1];
        } 
        catch (QueryException e) {
            system.debug('No Integration Access record found or an error occurred: ' + e.getMessage());
            return null; 
        }
        system.debug(record);                           
        if (record == null) {
            system.debug('Integration_Access__c record does not exist for user: ' + recordName);
            return null; 
        }
        return record; 
    }
        
    @AuraEnabled
    public static void saveToken(String accessToken, String refreshToken, String expiryTime) {
        try {
            Integer seconds = Integer.valueOf(expiryTime);
            system.debug(seconds);
            DateTime dt = System.now(); 
            system.debug(dt); 
            DateTime adjustedDt = dt.addSeconds(seconds);
            system.debug(adjustedDt);
            User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            system.debug(currentUser);
            String recordName = 'DROPBOX' + currentUser.Id;       
            system.debug(recordName);  
            Integration_Access__c myCustomObject;
            try {
                myCustomObject = [SELECT Id, Access_Token__c, Refresh_Token__c, Expire_In_Time__c 
                                FROM Integration_Access__c 
                                WHERE Name__c = :recordName
                                LIMIT 1];
            } 
            catch (QueryException e) {
                system.debug('No Integration_Access__c record found for: ' + recordName);
                myCustomObject = null; 
            }
            if (myCustomObject == null) {
                myCustomObject = new Integration_Access__c();
                myCustomObject.Contact__c = currentUser.ContactId;
                myCustomObject.Refresh_Token__c = refreshToken;
                myCustomObject.Name__c = 'DROPBOX' + UserInfo.getUserId();
            } 
            else if (refreshToken != null) {
                myCustomObject.Refresh_Token__c = refreshToken;
            }
            myCustomObject.Access_Token__c = accessToken;
            myCustomObject.Expire_In_Time__c = adjustedDt;
            upsert myCustomObject;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<string, string> accessTokenWithRefreshToken(String clientId,String clientSecret,String refreshToken){
        try {
            IntegrationAssignment__mdt dropBox = getMetaData();
            Integration_Access__c tokens = getTokens(); 
            String authuri = dropboxOAuthAuthorize+'?client_id='+clientId+'&token_access_type=offline&response_type=code&+&scope=files.metadata.read sharing.write files.metadata.write files.content.write files.content.read &redirect_uri=' + redirectUri;    
            ApexPages.PageReference uri = new PageReference(authuri);
            Map<string, string> jsonValues = new Map<string, string>();
            if(String.isBlank(refreshToken) || refreshToken != tokens.Refresh_Token__c){
                aura.redirect(uri);
            }
            IntegrationWrapperClass res = DropBoxServiceClass.getAccessTokenFromRefershToken(clientId,clientSecret,refreshToken);
            if(res.responseStatusCode=='200'){
                jsonValues= parseBody(res.responseBody);
            }
            else if(res.responseStatusCode=='400'||res.responseStatusCode=='401'){
                aura.redirect(uri);
            }
            return jsonValues;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getFileTypeFromExtension(String fileName) {
        if (fileName.contains('.')) {
            String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
            if (extension == 'pdf' || extension == 'doc' || extension == 'docx' || extension == 'xls' || extension == 'xlsx' || extension == 'ppt' || extension == 'pptx' || extension == 'txt' || extension == 'csv') {
                return extension;
            } else if (extension == 'png' || extension == 'jpg' || extension == 'jpeg') {
                return 'image';
            } else if (extension == 'mp4') {
                return 'video';
            }else if(extension == 'htm' || extension == 'html'){
                return 'html';
            } else {
                return 'unknown';
            }
        }
        return 'unknown';
    }

    @AuraEnabled
    public static Map<string, string> parseBody(String body){
        Map<string, string> jsonValues = new Map<string, string>();
        String keyValue = '';
        String tempValue = '';
        JSONParser parser = JSON.createParser(body);
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                keyValue = parser.getText();
                parser.nextToken();
                tempValue = parser.getText();
                jsonValues.put(keyValue, tempValue);            
            }
        }
        return jsonValues;
    }
}

            

