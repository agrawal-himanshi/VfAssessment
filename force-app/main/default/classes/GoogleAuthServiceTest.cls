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
            Expire_In_Time__c = System.now().addSeconds(3600), // Token is not expired
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
            Expire_In_Time__c = System.now().addSeconds(-3600), // Token is expired
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
        try {
            driveController.UserDetailsWrapper result = driveController.getAccessToken('test_code');
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals('test_email@example.com', result.email, 'Email should match the mocked response');
        } catch (Exception e) {
            System.debug('Error in test: ' + e.getMessage());
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
    }
    
    @isTest
    static void getAccessTokenTest2() {
        String exceptionMessage = '';
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try {
            driveController.getAccessToken(''); 
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

    /* Test method for getFileAndFolders method */

    @isTest
    static void getFileAndFoldersTest1() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'test_email'
        );
        insert token; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        List<driveController.GoogleDriveFile> result = driveController.getFilesANdFolders('test_access_token', 'root', true, 'test_email');
        Test.stopTest();
    }

    @isTest
    static void getFileAndFoldersTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600)
        );
        insert token; 
        String exceptionMessage = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try {
            driveController.getFilesANdFolders('test_access_token', 'root', false, 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Exception message should match expected');
    }

    @isTest
    static void getFileAndFoldersTest3() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600),  // Token is expired
            user_mail__c = 'test_email'
        );
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        List<driveController.GoogleDriveFile> result = driveController.getFilesANdFolders('test_access_token', 'root', false, 'test_email');
        Test.stopTest();
        System.assertEquals(2, result.size(), 'Expected 2 files/folders in the result');
    }

    @isTest
    static void getFileAndFoldersTest4() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'test_email'
        );
        insert token;
        String exceptionMessage = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
        try {
            driveController.getFilesANdFolders('test_access_token', 'root', false, 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Exception message should match expected');
    }

    /* Test method for deleteFileOrFolder method */

    @isTest
    static void deleteFileOrFolderTest1() {
        // Setup test data
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(3600),  // token valid for 1 hour
            user_mail__c = 'test_email'
        );
        insert token;

        // Set mock response for success (HTTP 204)
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));

        // Call the deleteFileOrFolder method
        Boolean result = driveController.deleteFileOrFolder('test_access_token', '', 'fileId123', 'test_email');

        // Verify the result
        System.assertEquals(true, result, 'Expected deletion to succeed');
    }

    @isTest
    static void deleteFileOrFolderTest2() {
        // Setup test data with expired token
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(-3600),  // expired token
            user_mail__c = 'test_email'
        );
        insert token;

        // Set mock response for successful token refresh and file deletion (HTTP 204)
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));

        // Call the deleteFileOrFolder method with an expired token
        Boolean result = driveController.deleteFileOrFolder('', '', 'fileId123', 'test_email');

        // Verify the result
        System.assertEquals(true, result, 'Expected deletion to succeed after refreshing token');
    }

    // Test case 3: Error during the API call even with a valid token (mock error response)
    @isTest
    static void deleteFileOrFolderTest3() {
        // Setup test data (create integration access record with valid token)
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(3600),  // token valid for 1 hour
            user_mail__c = 'test_email'
        );
        insert token;

        // Set mock response for unauthorized error (HTTP 401)
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));

        // Call the deleteFileOrFolder method
        String exceptionMessage = '';
        try {
            driveController.deleteFileOrFolder('test_access_token', '', 'fileId123', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }

        // Verify the error message
        System.assertEquals('Unauthorized access', exceptionMessage, 'Expected error message for 401 response');
    }

    @isTest
    static void deleteFileOrFolderTest4() {
        // Setup test data (create integration access record with valid token)
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(3600),  // token valid for 1 hour
            user_mail__c = 'test_email'
        );
        insert token;

        // Set mock response for a generic error (HTTP 500)
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));

        // Call the deleteFileOrFolder method
        String exceptionMessage = '';
        try {
            driveController.deleteFileOrFolder('test_access_token', '', 'fileId123', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }

        // Verify the error message
        System.assertEquals('Internal Server Error', exceptionMessage, 'Expected error message for non-401 response');
    }

    /* Test method for createFolderGoogleDrive method */

    @isTest
    static void createFolderInGoogleDriveTest1() {
        // Create and insert test token
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'test_email'
        );
        insert token;
    
        Test.startTest();
        // Set mock response for successful folder creation
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
    
        // Call the method to test folder creation
        List<driveController.GoogleDriveFile> result = driveController.createFolderInGoogleDrive('test_access_token', 'root', '/path/to/newfolder', 'test_email');
        Test.stopTest();
    
        // Assert that the expected result is returned
        System.assertEquals(2, result.size(), 'Expected 2 GoogleDriveFile entries');
    }
    
    // Test case 2: Token expired and error occurs during folder creation
    @isTest
    static void createFolderInGoogleDriveTest2() {
        // Create and insert test token with expired expiration time
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(-3600),  // Token expired
            user_mail__c = 'test_email'
        );
        insert token;
    
        String exceptionMessage = '';
        Test.startTest();
        // Set mock response for error (mock failure case)
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        
        try {
            // Call method with expired token, expecting failure
            driveController.createFolderInGoogleDrive('', 'root', '/path/to/newfolder', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
    
        // Assert the exception message to ensure proper error handling
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Expected exception message to match');
    }
    
    // Test case 3: Error during folder creation (mock failure response)
    @isTest
    static void createFolderInGoogleDriveTest3() {
        // Create and insert test token
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'test_email'
        );
        insert token;

        String exceptionMessage = '';
        List<driveController.GoogleDriveFile> result;
        Test.startTest();
        // Set mock response for an error (mock failure case)
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));

        try {
            // Call the method, expecting it to throw an exception due to error
            result = driveController.createFolderInGoogleDrive('test_access_token', 'root', '/path/to/newfolder', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        // Assert the exception message to ensure error handling is correct
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Expected exception message to match');
    }

    /* Test method for uploadFile method */

    // Test case 1: Successful file upload
    @isTest
    static void uploadFileTest1() {
        // Create and insert test token
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'test_email'
        );
        insert token;

        Test.startTest();
        // Set mock response for successful file upload
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));

        // Call the method to test file upload
        Boolean result = driveController.uploadFile('test_access_token', 'text/plain', 'root', 'test.txt', fileContents, 'test_email');
        Test.stopTest();

        // Assert that the file upload was successful
        System.assertEquals(true, result, 'Expected upload to return true on success');
    }

    // Test case 2: Token expired and error occurs during file upload
    @isTest
    static void uploadFileTest2() {
        // Create and insert test token with expired expiration time
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(-3600),  // Token expired
            user_mail__c = 'test_email'
        );
        insert token;

        String exceptionMessage = '';
        Test.startTest();
        // Set mock response for error
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        
        try {
            // Call the method with expired token, expecting failure
            String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
            driveController.uploadFile('', 'text/plain', 'root', 'test.txt', fileContents, 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        // Assert the exception message to ensure proper error handling
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Expected exception message to match');
    }

    // Test case 3: Error during file upload (mock failure response)
    @isTest
    static void uploadFileTest3() {
        // Create and insert test token
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'test_email'
        );
        insert token;

        String exceptionMessage = '';
        Test.startTest();
        // Set mock response for file upload error (mock failure case)
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
        
        try {
            // Call the method, expecting it to throw an exception due to error
            String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
            driveController.uploadFile('test_access_token', 'text/plain', 'root', 'test.txt', fileContents, 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        // Assert the exception message to ensure error handling is correct
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Expected exception message to match');
    }

    // @isTest
    // static void uploadFileTest1() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
    //     insert token;
	// 	Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
    //     String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
    //     List<driveController.GoogleDriveFile> result = driveController.uploadFile('', 'test.txt','txt',fileContents,'root');
    //     Test.stopTest();
    //     Assert.areEqual(2, result.size());
    // }

    // @isTest
    // static void uploadFileTest2() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
    //     insert token;
    //     String exceptions='';
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errorr'));
    //     try{
    //        String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
    //        List<driveController.GoogleDriveFile> result = driveController.uploadFile('root', 'test.txt','txt',fileContents,'root');
    //     }
    //     catch(Exception e){
    //         exceptions=e.getMessage();
    //     }
    //     Test.stopTest();
    //     Assert.areEqual(exceptions,'Script-thrown exception');
    // }

    
    // @isTest
    // static void uploadFileTest3() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
    //     insert token;
    //     String exceptions='';
    //     List<driveController.GoogleDriveFile> result;
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
    //     try{
    //        String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
    //        result = driveController.uploadFile('root', 'test.txt','txt',fileContents,'root');
    //     }
    //     catch(Exception e){
    //         exceptions=e.getMessage();
    //     }
    //     Test.stopTest();
    //     Assert.areEqual(2, result.size());
    // }

    /* Test method for accessTokenWithRefreshToke method */
    
    @isTest
    static void accessTokenWithRefreshTokenTest() {
        String exceptionMessage = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try {
            Map<String, String> result = driveController.accessTokenWithRefreshToken('clientId', 'clientSecret', 'refreshToken', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('', exceptionMessage, 'Expected exception message to match');
    }


    // static void accessTokenWithRefreshTokenTest(){
    //     String exceptions='';
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
    //     try{
    //     	Map<string, string> result = driveController.accessTokenWithRefreshToken('clientId', 'clientSecret', 'refreshToken');
    //     }
    //     catch(Exception e){
    //         exceptions=e.getMessage();
    //     }
    //     Test.stopTest();
    //     Assert.areEqual(exceptions,'');
    // } 
}