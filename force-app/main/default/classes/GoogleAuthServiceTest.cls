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
        Map<String, Object> uriMap = new Map<String, Object>();
        String result = driveController.createAuthURL();
        System.debug('createAuthURL response: ' + result);
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
        Map<String, Object> uriMap = new Map<String, Object>();
        String result = driveController.createAuthURL();
        System.debug('createAuthURL response: ' + result);
        Test.stopTest();
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap != null, 'Response map should not be null');
        System.assert(resultMap.containsKey('haveAccessToken'), 'haveAccessToken key should be present in response');
        System.assertEquals('test_access_token', resultMap.get('haveAccessToken'), 'Access token should match expected value');
        System.assert(resultMap.containsKey('isRedirect'), 'isRedirect key should be present in response');
        System.assertEquals(false, resultMap.get('isRedirect'), 'isRedirect should be false');
        List<AsyncApexJob> jobs = [SELECT Status FROM AsyncApexJob WHERE JobType = 'Queueable' AND Status = 'Completed'];
        System.assertEquals(1, jobs.size(), 'One queueable job should have been executed');
    }

    @isTest
    static void createAuthURLTest4() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'GOOGLE DRIVE'
        );
        insert token;
        String exceptionMessage = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));        
        try {
            driveController.createAuthURL();
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Exception message should match expected');
    }

    @isTest
    static void getAccessTokenTest1() {
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
        driveController.UserDetailsWrapper result = driveController.getAccessToken('test_code');
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('test_email@example.com', result.email, 'Email should match the mocked response');
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

    // @isTest
    // static void getAccessTokenTest1() {
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
    //     List<driveController.UserDetailsWrapper> result = driveController.getAccessToken('test_code');
    //     Assert.areEqual(result.size(),2);
    // }

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
        System.assertEquals(2, result.size(), 'Expected 2 files/folders in the result');
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
            driveController.getFilesANdFolders('', 'root', false, 'test_email');
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


    // @isTest
    // static void getFileAndFoldersTest1() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600), user_mail__c = 'test_email');
    //     insert token; 
    //     List<driveController.GoogleDriveFile> result;
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
    //     result = driveController.getFilesANdFolders('', 'root',true,'email');
    //     Test.stopTest();
    //     Assert.areEqual(2, result.size());
    // }


    // @isTest
    // static void getFileAndFoldersTest3() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
    //     insert token;
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
    //     List<driveController.GoogleDriveFile> result = driveController.getFileANdFolders('test_access_token', 'root',false);
    //     Test.stopTest();
        
    //     Assert.areEqual(2, result.size());
    // }
    
    // @isTest
    // static void getFileAndFoldersTest4() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
    //     insert token;
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
    //     List<driveController.GoogleDriveFile> result = driveController.getFileANdFolders('test_access_token', 'root',false);
    //     Test.stopTest();
        
    //     Assert.areEqual(2, result.size());
    // }
    
    /* Test method for deleteFileOrFolder method */

    @isTest
    static void deleteFileOrFolderTest1() {
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
        Boolean result = driveController.deleteFileOrFolder('test_access_token', '', '/path/to/file.txt', 'test_email');
        Test.stopTest();
        System.assertEquals(true, result, 'Expected deletion to succeed');
    }

    @isTest
    static void deleteFileOrFolderTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(-3600),  // Token is expired
            user_mail__c = 'test_email'
        );
        insert token;
        String exceptionMessage = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try {
            driveController.deleteFileOrFolder('', 'test_access_token', '/path/to/file.txt', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Expected exception message to match');
    }

    @isTest
    static void deleteFileOrFolderTest3() {
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
            driveController.deleteFileOrFolder('test_access_token', '', '/path/to/file.txt', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Expected exception message to match');
    }

    // @isTest
    // static void deleteFileOrFolderTest1() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
    //     insert token; 
    //     List<driveController.GoogleDriveFile> result;
	// 	Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
    //     result = driveController.deleteFileOrFolder('','test_access_token', '/path/to/file.txt');
    //     Test.stopTest();
    //     Assert.areEqual(2, result.size());
    // } 
    
    // @isTest
    // static void deleteFileOrFolderTest2() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
    //     insert token; 
    //     String exceptions='';
    //     List<driveController.GoogleDriveFile> result;
	// 	Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errorr'));
    //     try{
    //        result = driveController.deleteFileOrFolder('','test_access_token', '/path/to/file.txt');
    //     }
    //     catch(Exception e){
    //         exceptions=e.getMessage();
    //     }
    //     Test.stopTest();
    //    Assert.areEqual(exceptions,'Script-thrown exception');
    // }  
    
    // @isTest
    // static void deleteFileOrFolderTest3() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
    //     insert token; 
    //     String exceptions='';
    //     List<driveController.GoogleDriveFile> result;
	// 	Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
    //     try{
    //        result = driveController.deleteFileOrFolder('','test_access_token', '/path/to/file.txt');
    //     }
    //     catch(Exception e){
    //         exceptions=e.getMessage();
    //     }
    //     Test.stopTest();
    //     Assert.areEqual(2, result.size());
    // } 

    /* Test method for createFolderGoogleDrive method */

    @isTest
    static void createFolderInGoogleDriveTest1() {
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
        List<driveController.GoogleDriveFile> result = driveController.createFolderInGoogleDrive('test_access_token', 'root', '/path/to/newfolder', 'test_email');
        Test.stopTest();
        System.assertEquals(2, result.size(), 'Expected 2 GoogleDriveFile entries');
    }

    @isTest
    static void createFolderInGoogleDriveTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(-3600),  // Token is expired
            user_mail__c = 'test_email'
        );
        insert token;
        String exceptionMessage = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try {
            driveController.createFolderInGoogleDrive('', 'root', '/path/to/newfolder', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Expected exception message to match');
    }

    @isTest
    static void createFolderInGoogleDriveTest3() {
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
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
        try {
            result = driveController.createFolderInGoogleDrive('test_access_token', 'root', '/path/to/newfolder', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Expected exception message to match');
    }

    // @isTest
    // static void createFolderInGoogleDriveTest1() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
    //     insert token;
	// 	Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('success'));
    //     List<driveController.GoogleDriveFile> result = driveController.createFolderInGoogleDrive('','root', '/path/to/newfolder');
    //     Test.stopTest();
    //     Assert.areEqual(2, result.size());
    // }

    // @isTest
    // static void createFolderInGoogleDriveTest2() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
    //     insert token;
  	// 	String exceptions='';
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errorr'));
    //     try{
    //        List<driveController.GoogleDriveFile> result = driveController.createFolderInGoogleDrive('','root', '/path/to/newfolder');
    //     }
    //     catch(Exception e){
    //         exceptions=e.getMessage();
    //     }
    //     Test.stopTest();
    //     Assert.areEqual(exceptions,'Script-thrown exception');
    // }

    // @isTest
    // static void createFolderInGoogleDriveTest3() {
    //     Integration_Access__c token = new Integration_Access__c(Name__c = 'GOOGLEDRIVE'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
    //     insert token;
  	// 	String exceptions='';
    //     List<driveController.GoogleDriveFile> result;
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('errors'));
    //     try{
    //        result = driveController.createFolderInGoogleDrive('','root', '/path/to/newfolder');
    //     }
    //     catch(Exception e){
    //         exceptions=e.getMessage();
    //     }
    //     Test.stopTest();
    //     Assert.areEqual(2, result.size());
    // }

    /* Test method for uploadFile method */

    @isTest
    static void uploadFileTest1() {
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
        String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
        Boolean result = driveController.uploadFile('test_access_token', 'text/plain', 'root', 'test.txt', fileContents, 'test_email');
        Test.stopTest();
        System.assertEquals(true, result, 'Expected upload to return true on success');
    }

    @isTest
    static void uploadFileTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'GOOGLEDRIVE' + UserInfo.getUserId(),
            Access_Token__c = 'test_access_token',
            Refresh_Token__c = 'test_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(-3600),  // Token is expired
            user_mail__c = 'test_email'
        );
        insert token;
        String exceptionMessage = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try {
            String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
            driveController.uploadFile('', 'text/plain', 'root', 'test.txt', fileContents, 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('Script-thrown exception', exceptionMessage, 'Expected exception message to match');
    }

    @isTest
    static void uploadFileTest3() {
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
            String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
            driveController.uploadFile('test_access_token', 'text/plain', 'root', 'test.txt', fileContents, 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
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