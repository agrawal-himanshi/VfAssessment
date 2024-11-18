public with sharing class driveController {
    private static String googleDriveOAuthAuthorize = 'https://accounts.google.com/o/oauth2/v2/auth';    
    private static String scope='https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email';
    private static String redirectUri='https://briskmindssoftwaresoluti-6b-dev-ed.develop.my.site.com/driveCommunity/';
    
    @AuraEnabled
    public static String createAuthURL() {
        try {
            IntegrationAssignment__mdt googleDrive = getMetaData(); 
            String authuri = googleDriveOAuthAuthorize + '?client_id=' + googleDrive.AppKey__c + '&access_type=offline&response_type=code'+ '&scope=' + scope + '&redirect_uri=' + redirectUri + '&prompt=consent'; 
            Map<String, Object> uriMap = new Map<String, Object>(); // Creating Map for URL redirect
            List<Integration_Access__c> recordcheck = new List<Integration_Access__c>();
            try {
                recordcheck = [SELECT Id, user_mail__c FROM Integration_Access__c WHERE Record_Type__c = 'GOOGLE DRIVE'];
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
                    if (tokens.Expire_In_Time__c < System.now()) {
                        System.enqueueJob(new RefreshTokenJob(
                            googleDrive.AppKey__c, 
                            googleDrive.AppSecret__c, 
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
            IntegrationAssignment__mdt googleDrive = getMetaData();
            Map<string, string> jsonValues = new Map<string, string>();
            system.debug('clientid:' + googleDrive.AppKey__c + 'clientSecret ' + googleDrive.AppSecret__c + 'authcode ' + code + 'uri ' + redirectUri);
            IntegrationWrapperClass res = GoogleDriveServiceClass.getaccessToken(googleDrive.AppKey__c, googleDrive.AppSecret__c, code,redirectUri);
            system.debug(res.responseStatusCode);
            if(res.responseStatusCode == '200'){   
                jsonValues= parseBody(res.responseBody);     
                UserDetailsWrapper userinformation = userDetails(jsonValues.get('access_token'));
                system.debug('UserInformation: '+ userinformation);
                saveToken(jsonValues.get('access_token'), jsonValues.get('refresh_token'), jsonValues.get('expires_in'),userinformation.email);
                return userinformation;
            }else if(res.responseStatusCode == '400'){
                System.debug('Error (400): ' + res.responseBody);
                UserDetailsWrapper errorResult = new UserDetailsWrapper();
                errorResult.email = 'Invalid Request: ' + res.responseBody;  // Example of a failure message
                return errorResult;  // Returning a custom object with a failure message instead of throwing an exception
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
    public static String createAuthURLForOtherAcc() {
        try {
            IntegrationAssignment__mdt googleDrive = getMetaData(); 
            String authuri = googleDriveOAuthAuthorize+'?client_id='+googleDrive.AppKey__c+'&access_type=offline&response_type=code&+&scope='+scope+'&redirect_uri=' +redirectUri+'&prompt=consent';    
            return authuri;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static UserDetailsWrapper userDetails(String accessToken) {
        try {
            IntegrationWrapperClass response;
            System.debug(accessToken);
            response = GoogleDriveServiceClass.getUserDetails(accessToken);
            if (response.responseStatusCode == '200') {
                system.debug(response.responseBody);
                Map<String, Object> userDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody);
                String username = '';
                String emailId = '';
                if (userDetailsMap.containsKey('names')) {
                    List<Object> namesList = (List<Object>) userDetailsMap.get('names');
                    if (!namesList.isEmpty()) {
                        Map<String, Object> nameDetails = (Map<String, Object>) namesList.get(0);
                        username = (String) nameDetails.get('displayName');
                    }
                }
                if (userDetailsMap.containsKey('emailAddresses')) {
                    List<Object> emailList = (List<Object>) userDetailsMap.get('emailAddresses');
                    if (!emailList.isEmpty()) {
                        Map<String, Object> emailDetails = (Map<String, Object>) emailList.get(0);
                        emailId = (String) emailDetails.get('value');
                    }
                }
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
    public static List<GoogleDriveFile> getFilesANdFolders(String accessToken,String currentFolder,Boolean isNew,String email){
        try {
            System.debug(email);
            Integration_Access__c tokens = getTokens(email);
            IntegrationAssignment__mdt googleDrive = getMetaData();
            IntegrationWrapperClass response;
            List<GoogleDriveFile> data = new List<GoogleDriveFile>();
            if(accessToken==''||accessToken==null){
                accessToken=tokens.Access_Token__c;
            }
            if(isNew){
                response = GoogleDriveServiceClass.getfilesFolders(accessToken,currentFolder); 
            }
            else if(tokens.Expire_In_Time__c < System.now()||tokens.Access_Token__c==null){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(googleDrive.AppKey__c,googleDrive.AppSecret__c,tokens.Refresh_Token__c,email);
                response = GoogleDriveServiceClass.getfilesFolders(jsonValues.get('access_token'),currentFolder); 
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'),tokens.user_mail__c);
            }
            else{
                response = GoogleDriveServiceClass.getfilesFolders(accessToken,currentFolder); 
            }
            if (response.responseStatusCode == '200') {
                system.debug(response.responseBody);
                data = getData(response.responseBody);
                system.debug(data);
            } else if(response.responseStatusCode == '401') {
                Map<string, string> jsonValues = accessTokenWithRefreshToken(googleDrive.AppKey__c,googleDrive.AppSecret__c,tokens.Refresh_Token__c,email);
                data = getFilesANdFolders(jsonValues.get('access_token'),currentFolder,isNew,email);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'),tokens.user_mail__c);
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
    public static Boolean deleteFileOrFolder( String accessToken, String current,String fileId,String email) {
        String errorMessage = '';
        try {
            IntegrationAssignment__mdt googleDrive = getMetaData();
            Integration_Access__c tokens = getTokens(email);
            if(accessToken==''||accessToken==null){
                accessToken = tokens.Access_Token__c;
            }
            IntegrationWrapperClass response;
            if(tokens.Expire_In_Time__c < System.now()||tokens.Access_Token__c == null){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(googleDrive.AppKey__c,googleDrive.AppSecret__c,tokens.Refresh_Token__c,email);
                accessToken = jsonValues.get('access_token');
                response = GoogleDriveServiceClass.deleteFileOrFolder(accessToken,fileId);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'),email);
            }
            else{
                response = GoogleDriveServiceClass.deleteFileOrFolder(accessToken,fileId);
            }
            if(response.responseStatusCode == '204'){
                return true;
            }
            else if(response.responseStatusCode == '401'){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(googleDrive.AppKey__c,googleDrive.AppSecret__c,tokens.Refresh_Token__c,email);
                accessToken=jsonValues.get('access_token');
                Boolean data= deleteFileOrFolder(jsonValues.get('access_token'),current,fileId,email);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'),email);
                return data;
            }
            else{
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody);
                errorMessage = (String) jsonMap.get('message');
                throw new AuraHandledException(errorMessage);
            }
        } 
        catch (Exception e) {
            if(String.isBlank(errorMessage)){
                errorMessage = e.getMessage();
            }
            throw new AuraHandledException(errorMessage);
        }
    }

    @AuraEnabled
    public static List<GoogleDriveFile> createFolderInGoogleDrive( String accessToken,String current,String fileName,String email){
        try {
            System.debug(current);
            System.debug(fileName);
            IntegrationAssignment__mdt googleDrive = getMetaData();
            Integration_Access__c tokens=getTokens(email);
            if(accessToken==''||accessToken==null){
                accessToken=tokens.Access_Token__c;
            }
            IntegrationWrapperClass response;
            if(tokens.Expire_In_Time__c < System.now()||tokens.Access_Token__c==null){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(googleDrive.AppKey__c,googleDrive.AppSecret__c,tokens.Refresh_Token__c,email);
                accessToken=jsonValues.get('access_token');
                response = GoogleDriveServiceClass.createFolderInGoogleDrive(accessToken,fileName,current);
                saveToken(jsonValues.get('access_token'),jsonValues.get('refresh_token'),jsonValues.get('expires_in'),email);
            }
            else{
                response = GoogleDriveServiceClass.createFolderInGoogleDrive(accessToken,fileName,current);
            }
            
            if(response.responseStatusCode == '200'){
                List<GoogleDriveFile> data= getFilesANdFolders(accessToken,current,false,email);
                return data;
            }
            else if(response.responseStatusCode == '401'){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(googleDrive.AppKey__c,googleDrive.AppSecret__c,tokens.Refresh_Token__c,email);
                accessToken=jsonValues.get('access_token');
                List<GoogleDriveFile> data= createFolderInGoogleDrive(accessToken,current,fileName,email);
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
            IntegrationAssignment__mdt googleDrive = getMetaData();
            Integration_Access__c tokens = getTokens(email);
            if(String.isBlank(current) || current == 'root'){
                current = '';
            }
            if(accessToken == '' || accessToken == null){
                accessToken = tokens.Access_Token__c;
            }
            IntegrationWrapperClass response;
            if(tokens.Expire_In_Time__c < System.now()){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(googleDrive.AppKey__c, googleDrive.AppSecret__c, tokens.Refresh_Token__c,email);
                accessToken = jsonValues.get('access_token');
                response = GoogleDriveServiceClass.uploadFile(accessToken, fileName, fileContent, current, mimeType);
                saveToken(jsonValues.get('access_token'), jsonValues.get('refresh_token'), jsonValues.get('expires_in'),email);
            }
            else{
                response = GoogleDriveServiceClass.uploadFile(accessToken, fileName, fileContent, current, mimeType);
            }
            if(response.responseStatusCode == '200'){
                return true;
            }
            else if(response.responseStatusCode == '401'){
                Map<string, string> jsonValues = accessTokenWithRefreshToken(googleDrive.AppKey__c, googleDrive.AppSecret__c, tokens.Refresh_Token__c,email);
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

    @AuraEnabled
    public static Map<string, string> accessTokenWithRefreshToken(String clientId,String clientSecret,String refreshToken,String email){
        IntegrationAssignment__mdt googleDrive = getMetaData();
        String authuri = googleDriveOAuthAuthorize+'?client_id='+googleDrive.AppKey__c+'&access_type=offline&response_type=code&scope='+scope+'&redirect_uri=' + redirectUri+'&prompt=consent';
        ApexPages.PageReference uri = new PageReference(authuri);
        Map<string, string> jsonValues = new Map<string, string>();
        if(String.isBlank(refreshToken)){
            aura.redirect(uri);
        }
        IntegrationWrapperClass res = GoogleDriveServiceClass.getAccessTokenFromRefershToken(clientId,clientSecret,refreshToken);
        if(res.responseStatusCode=='200'){
            jsonValues= parseBOdy(res.responseBody);
        }
        else {
            aura.redirect(uri);
        }
        return jsonValues;
    }

    @AuraEnabled
    public static String revokeGoogleDriveAccount(String IdOfRecord) {
        try {
            Integration_Access__c record = [SELECT Access_Token__c FROM Integration_Access__c WHERE Id = :IdOfRecord LIMIT 1];
            IntegrationWrapperClass res = GoogleDriveServiceClass.revokeToken(record.Access_Token__c);
            system.debug(res.responseStatusCode);
            if(res.responseStatusCode == '200'){   
                delete record;
                return 'Success';
            }
            else{
                throw new AuraHandledException(res.responseBody);
            }            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class UserDetailsWrapper {
        @AuraEnabled 
        public String username { get; set; }
        @AuraEnabled 
        public String email { get; set; }

        public UserDetailsWrapper() {
            this.email = '';
            this.username = '';
        }
    
        public UserDetailsWrapper(String username, String email) {
            this.username = username;
            this.email = email;
        }
    }
    
    public class GoogleDriveFile {
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public String fileType;
        @AuraEnabled
        public Boolean isDownloadable;
        @AuraEnabled
        public String fileId;
        @AuraEnabled
        public String previewLink;
        @AuraEnabled
        public String downloadLink;

        public GoogleDriveFile(String name, String type, Boolean downloadable, String id,String preview,String download) {
            this.fileName = name;
            this.fileType = type;
            this.isDownloadable = downloadable;
            this.fileId = id;
            this.previewLink=preview;
            this.downloadLink=download;
        }
    }

    @AuraEnabled
    public static IntegrationAssignment__mdt getMetaData(){
        List<IntegrationAssignment__mdt> appkey = IntegrationAssignment__mdt.getAll().values();
        IntegrationAssignment__mdt googleDrive ;
        for(IntegrationAssignment__mdt driveObj : appkey){
            if(driveObj.MasterLabel=='Google Drive'){
                googleDrive=driveObj;
            }   
        } 
        return googleDrive;
    }

    @AuraEnabled
    public static Integration_Access__c getTokens(String mailId) {
        system.debug(UserInfo.getUserId());
        User currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        system.debug(currentUser);
        String recordName = 'GOOGLE DRIVE ' + currentUser.Id;       
        system.debug(recordName); 
        Integration_Access__c record;
        if(mailId!=null) {
            try {
                record = [SELECT Id, Access_Token__c, Refresh_Token__c, Expire_In_Time__c,user_mail__c 
                    FROM Integration_Access__c 
                    WHERE user_mail__c= :mailId AND Record_Type__c = 'GOOGLE DRIVE'
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
            system.debug('Integration_Access__c record does not exist for user: ' + recordName);
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
            String recordName = 'GOOGLE DRIVE ' + currentUser.Id;       
            system.debug(recordName);  
            Integration_Access__c myCustomObject;
            if(mailId!=null){
                try {
                    myCustomObject = [SELECT Id, Access_Token__c, Refresh_Token__c, Expire_In_Time__c ,user_mail__c
                                    FROM Integration_Access__c 
                                    WHERE user_mail__c = :mailId 
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
            if (myCustomObject == null) {
                myCustomObject = new Integration_Access__c();
                myCustomObject.Contact__c = currentUser.ContactId;
                myCustomObject.Refresh_Token__c = refreshToken;
                myCustomObject.Name__c = 'GOOGLE DRIVE ' + UserInfo.getUserId();
                myCustomObject.Record_Type__c = 'GOOGLE DRIVE';
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
    public static List<Integration_Access__c> getAllAccMailIds() {
        List<Integration_Access__c> records = new List<Integration_Access__c>();
        try {
            records = [SELECT Id, user_mail__c FROM Integration_Access__c WHERE user_mail__c != null AND Record_Type__c = 'GOOGLE DRIVE'];
        } 
        catch (QueryException e) {
            system.debug('No Integration Access record found or an error occurred: ' + e.getMessage());
            return null; 
        }
        system.debug(records);                           
        if (records == null) {
            system.debug('Integration_Access__c record does not exist for user: ');
            return null; 
        }
        return records; 
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

    @AuraEnabled
    public static List<GoogleDriveFile> getData(String body){
        List<GoogleDriveFile> data=new List<GoogleDriveFile>();
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(body);
        List<Object> files = (List<Object>) responseBody.get('files');
        for (Object file : files) {
            Map<String, Object> fileMap = (Map<String, Object>) file;
            String tag = (String) fileMap.get('mimeType');
            String type = tag.contains('.')?tag.substring(tag.lastIndexOf('.') + 1):tag;
            String name = (String) fileMap.get('name');
            String id = (String) fileMap.get('id');
            String previewUrl = (String) fileMap.get('webViewLink');
            Boolean trashed=(Boolean) fileMap.get('trashed');
            if(trashed){
                continue;
            }
            String fileType;
            Boolean isDownloadable = false;
            String downloadLink;
            if (type == 'folder') {
                fileType = 'folder';
                isDownloadable = false;
            } else {
                fileType = tag;
                isDownloadable = true ;
                downloadLink = !String.isBlank((String) fileMap.get('webContentLink'))?(String) fileMap.get('webContentLink'):null;
                if(String.isBlank(downloadLink)){
                    String link = 'https://docs.google.com/';
                    if(type=='spreadsheet'){
                        link+='spreadsheets/d/'+id+'/export?format=xlsx';
                    }
                    else if(type=='document'){
                        link+='document/d/'+id+'/export?format=pdf';
                    }
                    else if(type=='presentation'){
                        link+='presentation/d/'+id+'/export?format=pptx';
                    }
                    downloadLink=link;
                }
                System.debug(downloadLink);
            }
            GoogleDriveFile GoogleDriveFile = new GoogleDriveFile(name, fileType,  isDownloadable, id,previewUrl,downloadLink);
            data.add(GoogleDriveFile);
        }
        return data;
    }

}

