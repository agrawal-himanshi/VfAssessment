@isTest
public class GoogleAuthServiceTest {

    @isTest
    static void createAuthURLTest1() {
        Test.startTest();
        String result = driveController.createAuthURL();
        Test.stopTest();        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap.containsKey('authUri'), 'authUri should be present');
        System.assertEquals(true, resultMap.get('isRedirect'), 'isRedirect should be true');
        System.assert(!resultMap.containsKey('haveAccessToken'), 'haveAccessToken should not be present');
    }

    @isTest
    static void createAuthURLTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        String result = driveController.createAuthURL();
        Test.stopTest();
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap != null, 'Response map should not be null');
        System.assert(resultMap.containsKey('haveAccessToken'), 'haveAccessToken key should be present in response');
        System.assertEquals('test_access_token', resultMap.get('haveAccessToken'), 'Access token should match expected value');
    }

    @isTest
    static void createAuthURLTest3() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        String result = driveController.createAuthURL();
        Test.stopTest();
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap.containsKey('haveAccessToken'), 'haveAccessToken key should be present in response');
        System.assertEquals('test_access_token', resultMap.get('haveAccessToken'), 'Access token should match expected value');
        System.assertEquals(false, resultMap.get('isRedirect'), 'isRedirect should be false');
    }

    @isTest
    static void getAccessTokenTest1() {
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        DriveController.UserDetailsWrapper result = DriveController.getAccessToken('test_code');
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('testuser@example.com', result.email, 'Email should match the mocked response');
    }
   
    @isTest
    static void getAccessTokenTest2() {
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        DriveController.UserDetailsWrapper result = DriveController.getAccessToken('test_code');
        String exceptionMessage = result.email;
        System.debug('Actual exception message: ' + exceptionMessage);
        String expectedErrorMessage = 'Invalid Request: {"error": "invalid_request"}';
        System.assertEquals(expectedErrorMessage, exceptionMessage, 'Exception message should match expected');
    }
    
    // Test for user details retrieval

    @isTest
    static void testUserDetailsSuccess() {
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        DriveController.UserDetailsWrapper result = DriveController.userDetails('test_access_token');
        System.debug(Result);
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('testuser@example.com', result.email, 'Email should match the mocked response');
    }
    
    @isTest
    static void testUserDetailsError() {
        String exceptionMessage = '';
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try {
            DriveController.userDetails('test_access_token');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Exception message should match expected');
    }
        
    @isTest
    static void createAuthURLForOtherAccTest() {
        Test.startTest();
        String result = driveController.createAuthURLForOtherAcc();
        Test.stopTest();
        System.assert(result.contains('client_id='), 'Auth URL should contain client_id');
        System.assert(result.contains('scope='), 'Auth URL should contain scope');
        System.assert(result.contains('redirect_uri='), 'Auth URL should contain redirect_uri');
    }

    // /* Test method for getFileAndFolders method */

    @isTest 
    static void getFilesANdFoldersTest1() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        List<driveController.GoogleDriveFile> result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        result = driveController.getFilesANdFolders('', 'root',true, 'testuser@example.com');
        Test.stopTest();
        System.debug(result);
        Assert.areEqual(2, result.size());
    }

    @isTest
    static void getFilesANdFoldersTest2(){
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try{
            List<driveController.GoogleDriveFile> result = driveController.getFilesANdFolders('', 'root',false,'testuser@example.com');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

    @isTest
    static void getFileAndFoldersTest3() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        List<driveController.GoogleDriveFile> result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        result = driveController.getFilesANdFolders('', 'root',false, 'testuser@example.com');
        Test.stopTest();
        System.debug(result);
        Assert.areEqual(2, result.size());
    }
    
    @isTest
    static void getFileAndFoldersTest4() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptions = '';
        List<driveController.GoogleDriveFile> result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
        try{       
            result = driveController.getFilesANdFolders('test_access_token','root',false, 'testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception'); 
    } 

     /* Test method for deleteFileOrFolder method */

    @isTest
    static void deleteFileOrFolderTest1() {
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        Boolean result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        result = driveController.deleteFileOrFolder('test_access_token', '', 'fileId123', 'testuser@example.com');
        Test.stopTest();
        Assert.areEqual(true, result);
    }

    @isTest
    static void deleteFileOrFolderTest2() {
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptions = '';
        Boolean result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
        try{
	        result = driveController.deleteFileOrFolder('test_access_token', '', 'fileId123', 'testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception'); 
    } 
    
    @isTest
    static void deleteFileOrFolderTest3(){
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try{
            Boolean result = driveController.deleteFileOrFolder('test_access_token', '', 'fileId123', 'testuser@example.com');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

    @isTest
    static void deleteFileOrFolderTest4() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        Boolean result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        result = driveController.deleteFileOrFolder('test_access_token', '', 'fileId123', 'testuser@example.com');
        Test.stopTest();
        System.debug(result);
        Assert.areEqual(true, result);
    }
    
     /* Test method for createFolderGoogleDrive method */

    @isTest
     static void createFolderInGoogleDriveTest1() {
         Integration_Access__c token = new Integration_Access__c(
             Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
             Access_Token__c = 'test_access_token', 
             Refresh_Token__c = 'test_refresh_token', 
             Expire_In_Time__c = System.now().addSeconds(3600),
             user_mail__c = 'testuser@example.com',
             Record_Type__c = 'GOOGLE DRIVE'
         );
         insert token;
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
         List<driveController.GoogleDriveFile> result = driveController.createFolderInGoogleDrive('test_access_token', 'root', '/path/to/newfolder', 'testuser@example.com');
         Test.stopTest();
         System.assertEquals(2, result.size(), 'Expected 2 GoogleDriveFile entries');
     }
    
    @isTest
    static void createFolderInBOXTest2() {
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptions = '';
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
        try{
	        List<driveController.GoogleDriveFile> result = driveController.createFolderInGoogleDrive('', 'root', '0', 'testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception'); 
    } 
    
    @isTest
    static void createFolderInBOXTest3(){
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try{
	        List<driveController.GoogleDriveFile> result = driveController.createFolderInGoogleDrive('', 'root', '0', 'testuser@example.com');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

   /* @isTest
    static void createFolderInBOXTest4() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        List<driveController.GoogleDriveFile> result = driveController.createFolderInGoogleDrive('', 'root', '/path/to/newfolder', 'testuser@example.com');
        Test.stopTest();
        System.debug(result);
        System.assertEquals(2, result.size(), 'Expected 2 GoogleDriveFile entries');
    }*/
    
     /* Test method for uploadFile method */
    
     @isTest
    static void uploadFileTest1() {
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
    	Boolean result = driveController.uploadFile('', 'text/plain', 'root', 'test.txt', fileContents, 'testuser@example.com');
        Test.stopTest();
        Assert.areEqual(true, result);
    }

    @isTest
    static void uploadFileTest2() {
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
        try{
           String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
           driveController.uploadFile('', 'text/plain', 'root', 'test.txt', fileContents, 'testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception');
    }
    
    @isTest
    static void uploadFileTest3(){
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try{
           String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
           driveController.uploadFile('', 'text/plain', 'root', 'test.txt', fileContents, 'testuser@example.com');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

     @isTest
    static void uploadFileTest4() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
    	Boolean result = driveController.uploadFile('', 'text/plain', 'root', 'test.txt', fileContents, 'testuser@example.com');
        Test.stopTest();
        Assert.areEqual(true, result);
    }
    
    @isTest
    static void testRevokeBoxAccount_Success() {
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        Test.startTest();
        String result = driveController.revokeGoogleDriveAccount(token.Id);
        Test.stopTest();
        System.assertEquals(result, 'Success');
    }

    @isTest
    static void testRevokeBoxAccount_Failure() {
		Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
        try{
            String result = driveController.revokeGoogleDriveAccount(token.Id);
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception');
    }

    /* Test method for accessTokenWithRefreshToke method */
    
    @isTest
    static void accessTokenWithRefreshTokenTest() {
        String exceptionMessage = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try {
            Map<String, String> result = driveController.accessTokenWithRefreshToken('clientId', 'clientSecret', 'refreshToken', 'testuser@example.com');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('', exceptionMessage, 'Expected exception message to match');
    }
    
    @isTest
    static void testGetAllAccMailIds() {
        Integration_Access__c access1 = new Integration_Access__c(
            user_mail__c = 'user1@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        Integration_Access__c access2 = new Integration_Access__c(
            user_mail__c = 'user2@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert new List<Integration_Access__c>{access1, access2};
        Test.startTest();
        List<Integration_Access__c> result = driveController.getAllAccMailIds();
        Test.stopTest();
        System.assertNotEquals(result, null, 'Result should not be null');
        System.assertEquals(result.size(), 2, 'There should be 2 records returned');
        List<String> expectedEmails = new List<String>{'user1@example.com', 'user2@example.com'};
        for (Integration_Access__c record : result) {
            System.assert(expectedEmails.contains(record.user_mail__c), 'Expected email not found');
        }
    }

    @isTest
    static void testGetAllAccMailIdsNoRecords() {
        delete [SELECT Id FROM Integration_Access__c WHERE Record_Type__c = 'GOOGLE DRIVE'];
        Test.startTest();
        List<Integration_Access__c> result = driveController.getAllAccMailIds();
        Test.stopTest();
        System.assertEquals(null, null, 'Result should be null as no records exist');
    }

    @isTest
    static void testGetAllAccMailIdsQueryException() {
        Test.startTest();
        try {
            List<Integration_Access__c> result = driveController.getAllAccMailIds();
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No Integration Access record found or an error occurred'));
        }
        Test.stopTest();
    }


}