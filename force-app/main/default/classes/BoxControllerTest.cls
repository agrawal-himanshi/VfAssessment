@isTest
public class BoxControllerTest {

    //Test method for createAuthURL method

    @isTest
    static void createAuthURLTest1() {
        Test.startTest();
        String result = boxController.createAuthURL();
        Test.stopTest();
        String excpResult ='{"isRedirect":true,"authUri":"https://account.box.com/api/oauth2/authorize?response_type=code&client_id=t3h3vd7hbi0d38jjwcsvkmt47airxe8w&redirect_uri=https://briskminds129-dev-ed.develop.my.site.com/s/?tabset-05c93=8d051"}';
        Assert.areEqual(excpResult, result);
    }

    @isTest
    static void createAuthURLTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token; 
        Test.startTest();
        String result = boxController.createAuthURL();
        Test.stopTest();
        String excpResult ='{"isRedirect":false,"authUri":"https://account.box.com/api/oauth2/authorize?response_type=code&client_id=t3h3vd7hbi0d38jjwcsvkmt47airxe8w&redirect_uri=https://briskminds129-dev-ed.develop.my.site.com/s/?tabset-05c93=8d051"}';
        Assert.areEqual(excpResult, result);
    }

    @isTest
    static void createAuthURLTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success')); 
        String result = boxController.createAuthURL();
        Test.stopTest();
        String excpResult ='{"isRedirect":false,"authUri":"https://account.box.com/api/oauth2/authorize?response_type=code&client_id=t3h3vd7hbi0d38jjwcsvkmt47airxe8w&redirect_uri=https://briskminds129-dev-ed.develop.my.site.com/s/?tabset-05c93=8d051"}';
        Assert.areEqual(excpResult, result);
    }
    
    @isTest
    static void createAuthURLTest4() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('error')); 
       	String result = boxController.createAuthURL();
        Test.stopTest();
        String excpResult ='{"isRedirect":true,"authUri":"https://account.box.com/api/oauth2/authorize?response_type=code&client_id=t3h3vd7hbi0d38jjwcsvkmt47airxe8w&redirect_uri=https://briskminds129-dev-ed.develop.my.site.com/s/?tabset-05c93=8d051"}';
        Assert.areEqual(excpResult, result);
    }

    @isTest
    static void createAuthURLTest5() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token; 
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('refreshErrors')); 
        try{
        	String result = boxController.createAuthURL();
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception'); 
    }


    // Test method for getAccessToken method
        
    @isTest
    static void getAccessTokenTest1() {
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success'));
        // Boolean result = boxController.getAccessToken('test_code');
       // Assert.areEqual(true, result);
    }

    @isTest
    static void getAccessTokenTest2() {
        String exceptions='';
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('error'));
        try{
            // Boolean result = boxController.getAccessToken('');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Assert.areEqual(exceptions, 'Script-thrown exception'); 
    }


    //Test method for getFilesANdFolders method
       
    @isTest 
    static void getFilesANdFoldersTest1() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token; 
        List<boxController.BoxItem> result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success')); 
        result = boxController.getFilesANdFolders('', 'root', true, 'test_email');
        Test.stopTest();
        Assert.areEqual(7, result.size()); 
    }

    @isTest
    static void getFilesANdFoldersTest2() { 
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = '', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token; 
        Test.startTest();
        List<boxController.BoxItem> result = boxController.getFilesANdFolders('', 'root', false, 'test_email');
        Test.stopTest();
        Assert.areEqual(1 , result.size()); 
        
    }

    @isTest
    static void getFilesANdFoldersTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success')); 
        List<boxController.BoxItem> result = boxController.getFilesANdFolders('test_access_token', 'root', false, 'test_email');
        Test.stopTest();
        Assert.areEqual(7, result.size());
    }

    @isTest
    static void getFilesANdFoldersTest4() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('fileError'));
        List<boxController.BoxItem> result = boxController.getFilesANdFolders('test_access_token', 'root', false, 'test_email');
        Test.stopTest();
        Assert.areEqual(1, result.size()); 
    }

    @isTest
    static void getFilesANdFoldersTest5(){
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('filesError'));
        List<boxController.BoxItem> result = boxController.getFilesANdFolders('test_access_token', 'root', false, 'test_email');
        Test.stopTest();
        Assert.areEqual(7, result.size());
    }

    @isTest
    static void getFilesANdFoldersTest6(){
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
        String excp='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('error'));
        try{
            List<boxController.BoxItem> result = boxController.getFilesANdFolders('test_access_token', 'root',false, 'test_email');           
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
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token; 
        Boolean result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success')); 
        result = boxController.deleteFileOrFolder('', 'test_access_token', '1','test_email');
        Test.stopTest();
        Assert.areEqual(true, result);
    }

    @isTest
    static void deleteFileOrFolderTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token; 
        String exceptions = '';
        Boolean result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors')); 
        try{
           result = boxController.deleteFileOrFolder('',  'test_access_token', '1','test_email');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception'); 
    } 

    @isTest
    static void deleteFileOrFolderTest3() {
       
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token; 
        String exceptions = '';
        Boolean result;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('deleteError'));
        try{
           result = boxController.deleteFileOrFolder('', 'test_access_token', '/path/to/file.txt','test_email');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(true, result);
    }


    // Test method for createFolderInBOX method

    @isTest
    static void createFolderInBOXTest1() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success'));
        // Boolean result = boxController.createFolderInBOX('','root', '0','test_email');
        Test.stopTest();
        //Assert.areEqual(true, result);
    }

    @isTest
    static void createFolderInBOXTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
  		String exceptions='';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors'));
        // try{
        // //    Boolean result = boxController.createFolderInBOX('','root', '0','test_email');
        // }
        // catch(Exception e){
        //     exceptions=e.getMessage();
        // }
        Test.stopTest();
        Assert.areEqual(exceptions,'Script-thrown exception');
    }

    @isTest
    static void createFolderInBOXTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
        Boolean result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('createError'));
        // result = boxController.createFolderInBOX('','root', '0','test_email');
        Test.stopTest();
        Assert.areEqual(true, result);
    }


    // Test method for uploadFile method

    @isTest
    static void uploadFileTest1() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('success'));
        Boolean result = boxController.uploadFileBox('', 'test.txt','txt', 'fileContents','test_email');
        Test.stopTest();
        Assert.areEqual(true, result);
    }

    @isTest
    static void uploadFileTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors'));
        try{
           String fileContents = EncodingUtil.base64Encode(Blob.valueOf('file content'));
           Boolean result = boxController.uploadFileBox('', 'test.txt', 'txt', fileContents,'test_email');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception');
    }

    @isTest
    static void uploadFileTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
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


    // Test method for download method

    @isTest
    static void downloadFileTest1() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('downloadSuccess'));
        String result = boxController.downloadFile('', '1','test_email');
        Test.stopTest();
        Assert.areEqual(null, result);
    }

    @isTest
    static void downloadFileTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors'));
        try{
           String result = boxController.downloadFile('', '1','test_email');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception');
    }
	
    
    @isTest
    static void downloadFileTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
        String exceptions = '';
        String result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('downloadError'));
        try{
           result = boxController.downloadFile('', '1','test_email');
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
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('previewSuccess'));
        try{
           String result = boxController.previewFile('', '1','test_email');
        } 
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, '');
    }

    @isTest
    static void previewFileTest2() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-3600));
        insert token;
        String exceptions = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('errors'));
        try{
           String result = boxController.previewFile('', '1','test_email');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(exceptions, 'Script-thrown exception');
    }

    @isTest
    static void previewFileTest3() {
        Integration_Access__c token = new Integration_Access__c(Name__c = 'BOX'+UserInfo.getUserId(), Access_Token__c = 'test_access_token', Refresh_Token__c = 'test_refresh_token', Expire_In_Time__c = System.now().addSeconds(-1));
        insert token;
        String exceptions = '';
        String result;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxHttpMock('previewError'));
        try{
           result = boxController.previewFile('', '1','test_email');
        }
        catch(Exception e){
            exceptions = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(null, result);
    }

}