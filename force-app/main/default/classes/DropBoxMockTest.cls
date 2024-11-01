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
global class DropBoxMockTest implements HttpCalloutMock {
    private string responseType ;
    
    public DropBoxMockTest(String type){
        this.responseType=type;
    }   
    
    global HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint()=='https://api.dropboxapi.com/2/files/list_folder'){
            res.setBody('{"entries":'+
                        '[{'+
                            '"name":"folder1", ".tag":"folder"},'+
                            '{"name":"file1.txt", ".tag":"file"},'+
                            '{"name":"file2.png", ".tag":"file"},'+
                            '{"name":"file3.mp4", ".tag":"file"},'+
                            '{"name":"file4.html", ".tag":"file"},'+
                            '{"name":"file5.tiff", ".tag":"file"},'+
                        	'{"name":"file6", ".tag":"file"}'+
                        ']}');        	
        }
        else if(req.getEndpoint()=='https://api.dropboxapi.com/oauth2/token'&&req.getBody().contains('authorization_code')){
            res.setBody('{"access_token":"test_access_token","refresh_token":"test_refresh_token","expires_in":"3600","token_type": "bearer"}');
        }
        else if(req.getEndpoint()=='https://api.dropboxapi.com/oauth2/token'&&req.getBody().contains('refresh_token')){
            res.setBody('{"access_token":"test_access_token","expires_in":"3600","token_type": "bearer"}');
        }
        else if(req.getEndpoint()=='https://content.dropboxapi.com/2/files/download'){
        	res.setBody('file content');
        }
        else if(req.getEndpoint()=='https://api.dropboxapi.com/2/files/delete_v2'){
            res.setBody('{"metadata": {".tag": "file"}}');
        }
        else if(req.getEndpoint()=='https://api.dropboxapi.com/2/files/create_folder_v2'){
            res.setBody('{"metadata": {".tag": "folder"}}');
        }
        else if(req.getEndpoint()=='https://content.dropboxapi.com/2/files/upload'){
            res.setBody('{"name": "uploadedfile.txt"}');
        }
        else if(req.getEndpoint()=='https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings'){
            res.setBody('{"url": "http//abc.com"}');
            if(responseType=='errors'){
                res.setStatusCode(409);
                return res;
            }
        }
        else if(req.getEndpoint()=='https://api.dropboxapi.com/2/sharing/list_shared_links'){
            res.setBody('{"links": [{"url": "http//abc.com"}]}');
            if(responseType=='errors'){
                res.setStatusCode(200);
                return res;
            }
        }
        if(responseType=='success'){
            res.setStatusCode(200);
        }
        else{
            res.setStatusCode(400);
        }
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
}