public with sharing class boxController {

    private static String boxAuthorizeCode = 'https://account.box.com/api/oauth2/authorize';
    private static String redirectUri = 'https://briskmindssoftwaresoluti-6b-dev-ed.develop.my.site.com/box/';

    @AuraEnabled
    public static String createAuthURL() {
        try {
            IntegrationAssignment__mdt box = getMetaData(); 
            String authuri = boxAuthorizeCode+'?response_type=code&client_id='+box.AppKey__c+'&redirect_uri=' +redirectUri; //authUri creation
            Map<String, Object> uriMap = new Map<String, Object>(); // Creating Map for URL redirect
            List<Integration_Access__c> recordcheck = new List<Integration_Access__c>();
            try {
                recordcheck = [SELECT Id, user_mail__c FROM Integration_Access__c WHERE Record_Type__c = 'BOX'];
            } catch (QueryException e) {
                System.debug('No Integration Access record found or an error occurred: ' + e.getMessage());
            }
            System.debug(recordcheck);
            if (recordcheck.isEmpty()) {
                uriMap.put('authUri', authuri);
                uriMap.put('isRedirect', true);
                return JSON.serialize(uriMap);
            }        
            String emailId;
            List<String> emails = new List<String>();
            for (Integration_Access__c recordd : recordcheck) {
                emails.add(recordd.user_mail__c);
                System.debug('Email: ' + recordd.user_mail__c);
                emailId=recordd.user_mail__c;
                Integration_Access__c tokens = getTokens(recordd.user_mail__c); 
                if (tokens != null) { 
                    uriMap.put('email',emailId);
                    uriMap.put('haveAccessToken',tokens.Access_Token__c);
                    uriMap.put('expiresIn',tokens.Expire_In_Time__c);
                    uriMap.put('refreshtoken',tokens.refresh_token__c);
                    if (tokens.Expire_In_Time__c < System.now()) {
                        System.enqueueJob(new RefreshTokenJob(
                            box.AppKey__c, 
                            box.AppSecret__c, 
                            tokens.Refresh_Token__c, 
                            recordd.user_mail__c
                        ));
                        uriMap.put('isRedirect', false);
                    }
                }
            }
            return JSON.serialize(uriMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class RefreshTokenJob implements Queueable, Database.AllowsCallouts {
        private String clientId;
        private String clientSecret;
        private String refreshToken;
        private String email;
        public RefreshTokenJob(String clientId, String clientSecret, String refreshToken, String email) {
            this.clientId = clientId;
            this.clientSecret = clientSecret;
            this.refreshToken = refreshToken;
            this.email = email;
        }
        public void execute(QueueableContext context) {
            Map<String, String> jsonValues = accessTokenWithRefreshToken(clientId, clientSecret, refreshToken, email);
            if (jsonValues != null && !jsonValues.isEmpty()) {
                saveToken(jsonValues.get('access_token'), jsonValues.get('refresh_token'), jsonValues.get('expires_in'), email);
            }
        }
    }

    @AuraEnabled
    public static UserDetailsWrapper getAccessToken(String code){
        try{    
            IntegrationAssignment__mdt box = getMetaData();
            Map<string, string> jsonValues = new Map<string, string>();
            system.debug('clientid:' + box.AppKey__c + 'clientSecret ' + box.AppSecret__c + 'authcode ' + code + 'uri ' + redirectUri);
            IntegrationWrapperClass res = boxServiceClass.getaccessToken(box.AppKey__c, box.AppSecret__c, code);
            system.debug(res.responseStatusCode);
            if(res.responseStatusCode == '200'){  
                System.debug(res.responseBody);
                jsonValues= parseBody(res.responseBody);     
                UserDetailsWrapper userinformation = userDetails(jsonValues.get('access_token'));
                saveToken(jsonValues.get('access_token'), jsonValues.get('refresh_token'), jsonValues.get('expires_in'),userinformation.email);
                return userinformation;
            }
            else{
                throw new AuraHandledException(res.responseBody);
            }            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static UserDetailsWrapper userDetails(String accessToken) {
        try {
            IntegrationWrapperClass response;
            System.debug(accessToken);
            response = boxServiceClass.getUserDetails(accessToken);
            if (response.responseStatusCode == '200') {
                system.debug(response.responseBody);
                Map<String, Object> userDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody);
                String username =(String) userDetailsMap.get('name');
                String emailId = (String) userDetailsMap.get('login');
                system.debug(username);
                system.debug(emailId);
                return new UserDetailsWrapper(username, emailId);
            } 
            return null; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> accessTokenWithRefreshToken(String clientId, String clientSecret, String refreshToken, String email) {
        IntegrationAssignment__mdt box = getMetaData();
        String authuri = boxAuthorizeCode + '?response_type=code&client_id=' + box.AppKey__c + '&redirect_uri=' + redirectUri;
        Map<String, String> jsonValues = new Map<String, String>();
        if (String.isBlank(refreshToken)) {
            jsonValues.put('redirectUrl', authuri); 
            return jsonValues;
        }
        IntegrationWrapperClass res = boxServiceClass.getAccessTokenFromRefershToken(clientId, clientSecret, refreshToken);
        if (res.responseStatusCode == '200') {
            jsonValues = parseBody(res.responseBody);
            saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'),email);
        }
        else if (res.responseStatusCode == '400' || res.responseStatusCode == '401') {
            jsonValues.put('redirectUrl', authuri); 
        }
        return jsonValues;
    }
    
    @AuraEnabled
    public static List<BoxItem> getFilesANdFolders(String accessToken, String currentFolder, Boolean isNew, String email){
        try {
            System.debug(email);
            Integration_Access__c tokens = getTokens(email);
            IntegrationAssignment__mdt box = getMetaData();
            IntegrationWrapperClass response;
            List<BoxItem> data = new List<BoxItem>();
            if(String.isBlank(currentFolder) || currentFolder == 'root'){
                currentFolder = '0';
            }
            if(String.isBlank(accessToken)){
                accessToken = tokens.Access_Token__c;
            }
            System.debug(accessToken);
            response = boxServiceClass.getfilesFolders(accessToken,currentFolder); 
            if (response.responseStatusCode == '200') {
                system.debug(response.responseBody);
                data = getData(response.responseBody);
                system.debug(data);
            // } else if(response.responseStatusCode == '401') {
            //     Map<string, string> jsonValues = accessTokenWithRefreshToken(box.AppKey__c,box.AppSecret__c,tokens.Refresh_Token__c,email);
            //     data = getFilesANdFolders(jsonValues.get('access_token'),currentFolder,isNew,email);
            //     saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'),tokens.user_mail__c);
            // 
            }
            else {
                throw new AuraHandledException(response.responseBody);
            }
            return data;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<BoxItem> createFolderInBox( String accessToken,String current,String fileName,String email){
        try {
            System.debug(current);
            System.debug(fileName);
            IntegrationAssignment__mdt box = getMetaData();
            Integration_Access__c tokens=getTokens(email);
            if(String.isBlank(current) || current == 'root'){
                current = '';
            }
            if(accessToken==''||accessToken==null){
                accessToken=tokens.Access_Token__c;
            }
            IntegrationWrapperClass response;
            response = boxServiceClass.createFolderBox(accessToken,fileName,current);
            if(response.responseStatusCode == '201'){
                List<BoxItem> data= getFilesANdFolders(accessToken,current,false,email);
                return data;
            }
            else if(response.responseStatusCode == '400'){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(box.AppKey__c,box.AppSecret__c,tokens.Refresh_Token__c,email);
                accessToken=jsonValues.get('access_token');
                List<BoxItem> data= createFolderInBox(accessToken,current,fileName,email);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'),email);
                return data;
            }
            else{
                throw new AuraHandledException(response.responseBody);
            }
        } catch (Exception e) {
            throw new AuraHandledException( e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean uploadFile(String accessToken,String mimeType, String current, String fileName, String fileContent, String email) {
        String errorMessage = '';
        try {
            IntegrationAssignment__mdt box = getMetaData();
            Integration_Access__c tokens = getTokens(email);
            if(String.isBlank(current) || current == 'root'){
                current = '';
            }
            if(accessToken == '' || accessToken == null){
                accessToken = tokens.Access_Token__c;
            }
            IntegrationWrapperClass response;
            response = boxServiceClass.uploadFile(accessToken, fileName, fileContent, current, mimeType);
            if(response.responseStatusCode == '201'){
                return true;
            }
            else if(response.responseStatusCode == '400'){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(box.AppKey__c, box.AppSecret__c, tokens.Refresh_Token__c,email);
                accessToken = jsonValues.get('access_token');
                Boolean data = uploadFile(accessToken, mimeType, current, fileName, fileContent,email);
                saveToken(jsonValues.get('access_token'), jsonValues.get('refresh_token'), jsonValues.get('expires_in'),email);
                return data;
            }
            else{
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody);
                errorMessage = (String) jsonMap.get('message');
                throw new AuraHandledException(errorMessage);
            }
        } catch (Exception e) {
            if(String.isBlank(errorMessage)){
                errorMessage = e.getMessage();
            }
            throw new AuraHandledException(errorMessage);
        }
    }

    public class BoxItem {
        @AuraEnabled 
        public String id ;
        @AuraEnabled 
        public String name ;
        @AuraEnabled 
        public String type ;
        @AuraEnabled 
        public String redirectUri ;
        @AuraEnabled 
        public Boolean isDownloadable ;
        @AuraEnabled 
        public Boolean isFolder ;

        public BoxItem(String name, String type, Boolean isDownloadable, String id, Boolean isFolder){
            this.name = name;
            this.type = type;
            this.isDownloadable = isDownloadable;
            this.id = id;
            this.isFolder = isFolder;
            this.redirectUri = null;
        }
        
        public BoxItem(String uri){
            this.redirectUri = uri;
        }
    }   
    
    /*
        get data from response
        List<BoxItem>
    */
    @AuraEnabled
    public static List<BoxItem> getData(String body){
        List<BoxItem> data = new List<BoxItem>();
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(body);
        List<Object> files = (List<Object>) responseBody.get('entries');  
        for (Object file : files) {
            Map<String, Object> fileMap = (Map<String, Object>) file;
            String type = (String) fileMap.get('type');
            String name = (String) fileMap.get('name');
            String id = (String) fileMap.get('id');
            Boolean isDownloadable = false;
            String doctype = 'doctype:';
            String previewUrl = '';
            if (type == 'folder') {
                isDownloadable = false;
            } else {
                type = getFileTypeFromExtension(name);
                isDownloadable = true;
            }   
            doctype += type;          
            BoxItem BoxItem = new BoxItem(name, doctype, isDownloadable, id, !(isDownloadable)); 
            data.add(BoxItem); 
        }
        return data;
    }

    private static String getFileTypeFromExtension(String fileName) {
        if (fileName.contains('.')) {
            String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
            if (extension == 'pdf' || extension == 'doc' || extension == 'docx' || extension == 'ppt' || extension == 'pptx' || extension == 'txt' || extension == 'csv') {
                return extension;
            } else if (extension == 'png' || extension == 'jpg' || extension == 'jpeg') {
                return 'image';
            } else if (extension == 'mp4') {
                return 'video';
            }else if(extension == 'htm' || extension == 'html'){
                return 'html';
            }else if(extension == 'xlsx' || extension == 'xls'){
                return 'excel';
            }else {
                return 'unknown';
            }
        }
        return 'unknown';
    }

    public class UserDetailsWrapper {
        @AuraEnabled 
        public String username { get; set; }
        @AuraEnabled 
        public String email { get; set; }
    
        public UserDetailsWrapper(String username, String email) {
            this.username = username;
            this.email = email;
        }
    }

    @AuraEnabled
    public static IntegrationAssignment__mdt getMetaData(){
        List<IntegrationAssignment__mdt> appkey = IntegrationAssignment__mdt.getAll().values();
        IntegrationAssignment__mdt box ;
        for(IntegrationAssignment__mdt driveObj : appkey){
            if(driveObj.MasterLabel=='Box'){
                box=driveObj;
            }   
        } 
        return box;
    }

    @AuraEnabled
    public static Integration_Access__c getTokens(String mailId) {
        system.debug(UserInfo.getUserId());
        Integration_Access__c record;
        if(mailId!=null) {
            try {
                record = [SELECT Id, Access_Token__c, Refresh_Token__c, Expire_In_Time__c,user_mail__c 
                    FROM Integration_Access__c 
                    WHERE user_mail__c= :mailId AND Record_Type__c = 'BOX'
                    LIMIT 1];
            } 
            catch (QueryException e) {
                system.debug('No Integration Access record found or an error occurred: ' + e.getMessage());
                return null; 
            }
        }
        else{
            return null;
        }
        system.debug(record);                           
        if (record == null) {
            system.debug('Integration_Access__c record does not exist for user:');
            return null; 
        }
        return record; 
    }

    @AuraEnabled
    public static void saveToken(String accessToken, String refreshToken, String expiryTime, String mailId) {
        try {
            system.debug(mailId);
            Integer seconds = Integer.valueOf(expiryTime);
            system.debug(seconds);
            DateTime dt = System.now(); 
            system.debug(dt); 
            DateTime adjustedDt = dt.addSeconds(seconds);
            system.debug(adjustedDt);
            User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            system.debug(currentUser);
            String recordName = 'BOX ' + currentUser.Id;       
            system.debug(recordName);  
            Integration_Access__c myCustomObject;
            if(mailId!=null){
                try {
                    myCustomObject = [SELECT Id, Access_Token__c, Refresh_Token__c, Expire_In_Time__c ,user_mail__c
                                    FROM Integration_Access__c 
                                    WHERE user_mail__c = :mailId AND Record_Type__c = 'BOX'
                                    LIMIT 1];
                } 
                catch (QueryException e) {
                    system.debug('No Integration_Access__c record found for: ' + mailId);
                    myCustomObject = null; 
                }
            }
            else{
                myCustomObject = null; 
            }
            System.debug(myCustomObject);
            if (myCustomObject == null) {
                myCustomObject = new Integration_Access__c();
                myCustomObject.Contact__c = currentUser.ContactId;
                myCustomObject.Refresh_Token__c = refreshToken;
                myCustomObject.Name__c = 'BOX ' + UserInfo.getUserId();
                myCustomObject.Record_Type__c = 'BOX';
                myCustomObject.user_mail__c = mailId;
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