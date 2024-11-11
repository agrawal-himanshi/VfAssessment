@isTest
global class GoogleDriveMockTest implements HttpCalloutMock {
    private string responseType ;
    private boolean flag ;
    
    public GoogleDriveMockTest(String type){
        flag=false;
        this.responseType=type;
    }
    
    public HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
            
        if(req.getMethod()=='GET'){
            res.setBody('{"files": [{'+
                                      '"kind": "drive#file",'+
                                      '"mimeType": "application/octet-stream",'+
                                      '"id": "1cEyIW0zeOYI6ZI5W7XVs2IC8S2STUqYC",'+
                                      '"name": "Untitled",'+
                                      '"trashed":false'+
                        '},'+
                        '{'+
                          '"kind": "drive#file",'+
                          '"mimeType": "application/vnd.google-apps.folder",'+
                          '"id": "1aSD_H0fy7laFLmEccqXlciih7lMrnKMj",'+
                          '"name": "Hello",'+
                          '"trashed":false'+
                        '}]}');
            if(responseType=='errors'&&!flag){
                res.setStatusCode(401);
                flag=!flag;
                return res;
            }else if(responseType=='errors'&&flag){
                res.setStatusCode(200);
                return res;
            }
        }
        else if(req.getEndpoint()=='https://accounts.google.com/o/oauth2/token'){
            res.setBody('{"access_token":"test_access_token","refresh_token":"test_refresh_token","expires_in":"3600","token_type": "bearer"}');
        }
        else if(req.getEndpoint()=='https://www.googleapis.com/oauth2/v4/token'){
            res.setBody('{"access_token":"test_access_token","expires_in":"3600","token_type": "bearer"}');
            if(responseType=='errors'||responseType=='errorr'){
                res.setStatusCode(200);
                return res;
            }
        }
        else if(req.getMethod()=='DELETE'){
            res.setBody('');
            if(responseType=='success'){
            	res.setStatusCode(204);
                return res;
            }
            if(responseType=='errors'&&!flag){
                res.setStatusCode(401);
                flag=!flag;
                return res;
            }else if(responseType=='errors'&&flag){
                res.setStatusCode(204);
                return res;
           }
        }
        else if(req.getMethod()=='POST'){
            res.setBody('{"kind": "drive#file",'+
                          '"mimeType": "application/vnd.google-apps.folder",'+
                          '"id": "1aSD_H0fy7laFLmEccqXlciih7lMrnKMj",'+
                          '"name": "Hello"'+
                        '}');
            if(responseType=='errors'&&!flag){
                res.setStatusCode(401);
                flag=!flag;
                return res;
            }else if(responseType=='errors'&&flag){
                res.setStatusCode(200);
                return res;
           }
        }
        else if(req.getEndpoint()=='https://www.googleapis.com/upload/drive/v3/files'){
            res.setBody('{"name": "uploadedfile.txt"}');
            if(responseType=='errors'&&!flag){
                res.setStatusCode(401);
                flag=!flag;
                return res;
            }else if(responseType=='errors'&&flag){
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