/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class DropboxControllerTest {
    // Test method for createAuthURL method
    @isTest
    static void createAuthURLTest1() {
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
            List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.createAuthURL();
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'');
    }

    @isTest
    static void createAuthURLTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.createAuthURL();
        Test.stopTest();
        Assert.areEqual(7, result.size());
        Assert.areEqual('file1.txt', result[1].fileName);
        Assert.areEqual('folder1', result[0].fileName);  
    }

    @isTest
    static void createAuthURLTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token; 
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        try{
            List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.createAuthURL();
            Assert.areEqual(7, result.size());
            Assert.areEqual('file1.txt', result[1].fileName);
            Assert.areEqual('folder1', result[0].fileName);  
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
    }
        
    // Test method for getAccessToken method
    @isTest
    static void getAccessTokenTest1() {
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.getAccessToken('test_code', '');
        Assert.areEqual(result.size(),7);
    }

    @isTest
    static void getAccessTokenTest2() {
        String exceptions='';
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
            List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.getAccessToken('', '');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

    @isTest
    static void getAccessTokenTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.getAccessToken('test_code', '');
        Test.stopTest();
        Assert.areEqual(7, result.size());
        Assert.areEqual('file1.txt', result[1].fileName);
        Assert.areEqual('folder1', result[0].fileName);  
    }

    @isTest
    static void revokeTokenTest1() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        Test.startTest();
        String result = DropboxIntegrationController.doRevokeAccessToken();
        Test.stopTest();
        Integer recordCount = [SELECT Id FROM Integration_Access__c WHERE Access_Token__c = 'test_access_token'].size();
        System.assertEquals(0, recordCount, 'The access token record is deleted.');
    }

    @isTest
    static void revokeTokenTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
        String exceptions = '';
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        Test.startTest();
        try {
            String result = DropboxIntegrationController.doRevokeAccessToken();
        } catch (Exception e) {
            exceptions = 'No record found' + e.getMessage();
        }
        Test.stopTest();
        System.assertEquals('', exceptions, 'An exception.');
    }

    // Test method for getFileAndFolders method
    @isTest
    static void getFileAndFoldersTest1() {
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.getFileANdFolders('test_access_token', 'root',true);
        Assert.areEqual(7, result.size());
        Assert.areEqual('file1.txt', result[1].fileName);
        Assert.areEqual('folder1', result[0].fileName);
    }

    @isTest
    static void getFileAndFoldersTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token; 
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
            List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.getFileANdFolders('', 'root',false);
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
        
    }

    @isTest
    static void getFileAndFoldersTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.getFileANdFolders('test_access_token', 'root',false);
        Test.stopTest();
        Assert.areEqual(7, result.size());
        Assert.areEqual('file1.txt', result[1].fileName);
        Assert.areEqual('folder1', result[0].fileName);
    }

    // Test method for fileDownload method
 
    @isTest
    static void fileDownloadTest1() {
       
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token; 
        String exceptions='';
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
            String result = DropboxIntegrationController.fileDownload('/path/to/file.txt');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        
       Assert.areEqual(exceptions,'Script-thrown exception');
    }
    
    @isTest
    static void fileDownloadTest2() {
       
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token; 
        String exceptions='';
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
            String result = DropboxIntegrationController.fileDownload('/path/to/file.txt');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        
       Assert.areEqual(exceptions,'Script-thrown exception');
    }
	
    // Test method for deleteFileOrFolder method
        
    @isTest
    static void deleteFileOrFolderTest1() {
       
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token; 
        List<DropboxIntegrationController.DropboxFile> result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        result = DropboxIntegrationController.deleteFileOrFolder('test_access_token', '/path/to/file.txt');
        Test.stopTest();
        Assert.areEqual(7, result.size());
    } 
    
    @isTest
    static void deleteFileOrFolderTest2() {
       
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token; 
        String exceptions='';
        List<DropboxIntegrationController.DropboxFile> result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
           result = DropboxIntegrationController.deleteFileOrFolder('test_access_token', '/path/to/file.txt');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }  
    
    @isTest
    static void deleteFileOrFolderTest3() {
       
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token; 
        String exceptions='';
        List<DropboxIntegrationController.DropboxFile> result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
           result = DropboxIntegrationController.deleteFileOrFolder('test_access_token', '/path/to/file.txt');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    } 
	
    // Test method for createFolderInDropBox method
        
    @isTest
    static void createFolderInDropBoxTest1() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token;
  
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.createFolderInDropBox('root', '/path/to/newfolder');
        Test.stopTest();
        Assert.areEqual(7, result.size());
    }

    @isTest
    static void createFolderInDropBoxTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token;
  		String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
           List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.createFolderInDropBox('root', '/path/to/newfolder');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

    @isTest
    static void createFolderInDropBoxTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
  		String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
           List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.createFolderInDropBox('root', '/path/to/newfolder');
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
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
        List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.uploadFile('root', '/uploadedfile.txt', fileContents);
        Test.stopTest();
        Assert.areEqual(7, result.size());
    }

    @isTest
    static void uploadFileTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token;
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
           String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
        	List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.uploadFile('root', '/uploadedfile.txt', fileContents);
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

    @isTest
    static void uploadFileTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        try{
           String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
        	List<DropboxIntegrationController.DropboxFile> result = DropboxIntegrationController.uploadFile('root', '/uploadedfile.txt', fileContents);
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

    // Test method for accessTokenWithRefreshToke method
        
    @isTest
    static void accessTokenWithRefreshTokenTest1(){
        String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
        	Map<string, string> result = DropboxIntegrationController.accessTokenWithRefreshToken('clientId', 'clientSecret', 'refreshToken');
        }
        catch(Exception e){
            exceptions=e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }
    
    // Test method for getPreview method
        
    @isTest
    static void getPreviewTest1() {       
        Integration_Access__c token = new Integration_Access__c(Name__c ='DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token; 
        String result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('success'));
        result = DropboxIntegrationController.getPreview('/path/to/file.txt');
        Test.stopTest();
        Assert.areEqual('http//abc.com', result);
    } 
    
    @isTest
    static void getPreviewTest2() {       
        Integration_Access__c token = new Integration_Access__c(Name__c ='DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token; 
        String result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('error'));
        try{
            result = DropboxIntegrationController.getPreview('/path/to/file.txt');
        }
        catch(Exception e){
            result = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual('Script-thrown exception', result);

    } 
    
    @isTest
    static void getPreviewTest3() {       
        Integration_Access__c token = new Integration_Access__c(Name__c ='DROPBOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(3600));
        insert token; 
        String result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DropBoxMockTest('errors'));
        result = DropboxIntegrationController.getPreview('/path/to/file.txt');
        Test.stopTest();
        Assert.areEqual('http//abc.com', result);
    } 
}