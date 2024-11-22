@isTest
public class BoxControllerTest {

    //Test method for createAuthURL method

    @isTest
    static void createAuthURLTest1() {
        Test.startTest();
        String result = boxController.createAuthURL();
        Test.stopTest();
        String excpResult ='{"isRedirect":true,"authUri":"https://account.box.com/api/oauth2/authorize?response_type=code&client_id=mym7rb5cn43lnz9tnzd0gl6l65w0da9l&redirect_uri=https://briskmindssoftwaresoluti-6b-dev-ed.develop.my.site.com/box/"}';
        Assert.areEqual(excpResult, result);
    }

    @isTest
    static void createAuthURLTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success')); 
        String result = boxController.createAuthURL();
        Test.stopTest();
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap != null, 'Response map should not be null');
        System.assert(resultMap.containsKey('haveAccessToken'), 'haveAccessToken key should be present in response');
        System.assertEquals('test_access_token', resultMap.get('haveAccessToken'), 'Access token should match expected value');
    }

    @isTest
    static void createAuthURLTest3() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success')); 
        String result = boxController.createAuthURL();
        Test.stopTest();
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap != null, 'Response map should not be null');
        System.assert(resultMap.containsKey('haveAccessToken'), 'haveAccessToken key should be present in response');
        System.assertEquals('test_access_token', resultMap.get('haveAccessToken'), 'Access token should match expected value');
    }

    @isTest
    static void createAuthURLTest4() {
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('error')); 
        try {
            String result = boxController.createAuthURL();
        } catch (Exception e) {
            exceptions = e.getMessage();
        }

        Test.stopTest();
        System.assertEquals('', exceptions);
    }

    // Test method for getAccessToken method
        
   @isTest
    static void getAccessTokenTest1() {
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success'));
        boxController.UserDetailsWrapper result = boxController.getAccessToken('test_code');
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('testuser@example.com', result.email, 'Email should match the mocked response');
    }

    @isTest
    static void getAccessTokenTest2() {
        String exceptions='';
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('error'));
        try{
            boxController.UserDetailsWrapper result = boxController.getAccessToken('test_code');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Assert.areEqual(exceptions, 'Script-thrown exception'); 
    }



    @isTest
    static void createAuthURLForOtherAccTest() {
        Test.startTest();
        String result = boxController.createAuthURLForOtherAcc();
        Test.stopTest();
        System.assert(result.contains('client_id='), 'Auth URL should contain client_id');
        System.assert(result.contains('redirect_uri='), 'Auth URL should contain redirect_uri');
    }

    @isTest
    static void accessTokenWithRefreshTokenTest() {
        String exceptionMessage = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleDriveMockTest('error'));
        try {
            Map<String, String> result = boxController.accessTokenWithRefreshToken('clientId', 'clientSecret', 'refreshToken', 'test_email');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('', exceptionMessage, 'Expected exception message to match');
    }

    //Test method for getFilesANdFolders method
       
    @isTest 
    static void getFilesANdFoldersTest1() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        List<boxController.BoxItem> result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success')); 
        result = boxController.getFilesANdFolders('', 'root', true, 'testuser@example.com');
        Test.stopTest();
        Assert.areEqual(7, result.size()); 
    }

    @isTest
    static void getFilesANdFoldersTest2(){
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        String excp='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('error'));
        try{
            List<boxController.BoxItem> result = boxController.getFilesANdFolders('test_access_token', 'root',false, 'testuser@example.com');           
        }
        catch(exception e){
           excp = e.getMessage(); 
        }
        Test.stopTest();
        Assert.areEqual(excp, 'Script-thrown exception'); 
    }


    // Test method for deleteFileOrFolder method
       
    @isTest
    static void deleteFileOrFolderTest1() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        Boolean result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success')); 
        result = boxController.deleteFileOrFolder('', 'test_access_token', '1','testuser@example.com');
        Test.stopTest();
        Assert.areEqual(true, result);
    }

    @isTest
    static void deleteFileOrFolderTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        String exceptions = '';
        Boolean result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors')); 
        try{
           result = boxController.deleteFileOrFolder('',  'test_access_token', '1','testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception'); 
    } 

    @isTest
    static void deleteFileOrFolderTest3() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        String exceptions = '';
        Boolean result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('deleteError'));
        try{
           result = boxController.deleteFileOrFolder('', 'test_access_token', '/path/to/file.txt','testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        System.debug('Caught exception message: ' + exceptions);
        Assert.areEqual('Script-thrown exception', exceptions);
    }


    // Test method for createFolderInBOX method

    // @isTest
    // static void createFolderInBOXTest1() {
    //     Integration_Access__c token = new Integration_Access__c(
    //         Name__c = 'BOX1 ' + UserInfo.getUserId(), 
    //         Access_Token__c = 'test_access_token', 
    //         Refresh_Token__c = 'test_refresh_token', 
    //         Expire_In_Time__c = System.now().addSeconds(3600), 
    //         user_mail__c = 'testuser@example.com',
    //         Record_Type__c = 'BOX'
    //     );
    //     insert token;
	// 	Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success'));
    //     List<boxController.BoxItem> result = boxController.createFolderInBOX('','root', '0','testuser@example.com');
    //     Test.stopTest();
    //     System.assertNotEquals(result, null, 'Result should not be null');
    //     System.assertEquals(result.size(), 1, 'There should be 1 BoxItem in the result');
    //     boxController.BoxItem firstItem = result[0];
    //     System.assertEquals(firstItem.name, 'NewFolder', 'Folder name should be "NewFolder"');
    //     System.assertEquals(firstItem.type, 'folder', 'Item type should be "folder"');
    // }

    @isTest
    static void createFolderInBOXTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
  		String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('error'));
        try{
            List<boxController.BoxItem> result = boxController.createFolderInBOX('','root', '0','testuser@example.com');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

    // Test method for uploadFile method

    @isTest
    static void uploadFileTest1() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success'));
        Boolean result = boxController.uploadFileBox('', 'test.txt','txt', 'fileContents','testuser@example.com');
        Test.stopTest();
        Assert.areEqual(true, result);
    }

    @isTest
    static void uploadFileTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;        
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors'));
        try{
           String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
           Boolean result = boxController.uploadFileBox('', 'test.txt', 'txt', fileContents,'testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception');
    }

    /*@isTest
    static void uploadFileTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'mock_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
        String exceptions = '';
        Boolean result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('uploadError'));
        try{
           result = boxController.uploadFileBox('', '', 'txt.txt', 'awz=','test_email');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(true, result);
    }

*/
    // Test method for download method

    @isTest
    static void downloadFileTest1() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('downloadSuccess'));
        String result = boxController.downloadFile('', '1','testuser@example.com');
        Test.stopTest();
        Assert.areEqual(null, result);
    }

    @isTest
    static void downloadFileTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors'));
        try{
           String result = boxController.downloadFile('', '1','testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception');
    }
	
    
    @isTest
    static void downloadFileTest3() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        String exceptions = '';
        String result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('downloadError'));
        try{
           result = boxController.downloadFile('', '1','testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(null, result);
    }
    

    // Test method for previewFileTest method

    @isTest
    static void previewFileTest1() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('previewSuccess'));
        try{
           String result = boxController.previewFile('', '1','testuser@example.com');
        } 
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, '');
    }

    @isTest
    static void previewFileTest2() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(-3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors'));
        try{
           String result = boxController.previewFile('', '1','testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception');
    }

    @isTest
    static void previewFileTest3() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX1 ' + UserInfo.getUserId(), 
            Access_Token__c = 'test_access_token', 
            Refresh_Token__c = 'test_refresh_token', 
            Expire_In_Time__c = System.now().addSeconds(3600), 
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        String exceptions = '';
        String result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('previewError'));
        try{
           result = boxController.previewFile('', '1','testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(null, result);
    }

    @isTest
    static void testRevokeBoxAccount_Success() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX' + UserInfo.getUserId(),
            Access_Token__c = 'mock_access_token',
            Refresh_Token__c = 'mock_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success'));
        Test.startTest();
        String result = BoxController.revokeBoxAccount('testuser@example.com');
        Test.stopTest();
        System.assertEquals(result, 'Success');
    }

    @isTest
    static void testRevokeBoxAccount_Failure() {
        Integration_Access__c token = new Integration_Access__c(
            Name__c = 'BOX' + UserInfo.getUserId(),
            Access_Token__c = 'mock_access_token',
            Refresh_Token__c = 'mock_refresh_token',
            Expire_In_Time__c = System.now().addSeconds(-3600),
            user_mail__c = 'testuser@example.com',
            Record_Type__c = 'BOX'
        );
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors'));
        try{
            String result = BoxController.revokeBoxAccount('testuser@example.com');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception');
    }

    @isTest
    static void testGetAllAccMailIds() {
        Integration_Access__c access1 = new Integration_Access__c(
            user_mail__c = 'user1@example.com',
            Record_Type__c = 'BOX'
        );
        Integration_Access__c access2 = new Integration_Access__c(
            user_mail__c = 'user2@example.com',
            Record_Type__c = 'BOX'
        );
        insert new List<Integration_Access__c>{access1, access2};
        Test.startTest();
        List<Integration_Access__c> result = BoxController.getAllAccMailIds();
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
        delete [SELECT Id FROM Integration_Access__c WHERE Record_Type__c = 'BOX'];
        Test.startTest();
        List<Integration_Access__c> result = BoxController.getAllAccMailIds();
        Test.stopTest();
        System.assertEquals(null, null, 'Result should be null as no records exist');
    }

    @isTest
    static void testGetAllAccMailIdsQueryException() {
        Test.startTest();
        try {
            List<Integration_Access__c> result = BoxController.getAllAccMailIds();
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No Integration Access record found or an error occurred'));
        }
        Test.stopTest();
    }


}