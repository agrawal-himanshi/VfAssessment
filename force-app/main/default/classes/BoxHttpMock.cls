@isTest
 global class BoxHttpMock implements HttpCalloutMock {
     private String type; 
     private boolean flag ; 
     global BoxHttpMock(String type){
         this.type = type;
         this.flag = false;
     }
     
     /* 
        Returing response in Test class
        HttpResponse 
    */

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('/oauth2/token') && req.getBody().contains('code')) {
            res.setBody('{"access_token": "mock_access_token", "refresh_token": "mock_refresh_token", "expires_in": 3600}');
        }else if (req.getEndpoint().contains('/oauth2/token') && req.getBody().contains('refresh_token')) {
            res.setBody('{"access_token": "mock_access_token", "refresh_token": "", "expires_in": 3600}');
            if(type == 'refreshErrors'){
                res.setStatusCode(409);
                return res;
            }
             
            if(type == 'filesError' || type == 'deleteError' || type == 'createError' || type == 'errors' || type == 'uploadError' || type == 'downloadError'){
                res.setStatusCode(200);
                return res;
            }
        }else if (req.getEndpoint().contains('/folders/') && req.getMethod() == 'GET') {
            String response = '{"entries": [';
                response += '{"id": "1", "name": "Document.pdf", "type": "file"},';
                response += '{"id": "2", "name": "Image.jpg", "type": "file"},';
                response += '{"id": "3", "name": "Video.mp4", "type": "file"},';
                response += '{"id": "4", "name": "HTML.html", "type": "file"},';
             	response += '{"id": "5", "name": "abc.abc", "type": "file"},';
             	response += '{"id": "6", "name": "abc", "type": "file"},';
    			response += '{"id": "7", "name": "Sample Folder", "type": "folder"}';
    			response += ']}';
            res.setBody(response);
            if(type == 'fileError' && !flag){
                flag = !flag;
                res.setStatusCode(401);
                return res;
            }
            else if(type == 'fileError' && flag){
                res.setStatusCode(200);
                return res;
            }
             
            if(type == 'filesError' && !flag){
                flag = ! flag;
                res.setStatusCode(401);
                return res;
            }
            else if(type == 'filesError' && flag){
                res.setStatusCode(200);
                return res;
            }
        } else if (req.getEndpoint().contains('/folders/') && req.getMethod() == 'POST') {
            res.setBody('{"id": "new_folder_id", "name": "New Folder", "type": "folder"}');
            if(type == 'success'){
             	res.setStatusCode(201);
                return res;
         	}
            if(type == 'createError'&& !flag){
                flag =! flag;
                res.setStatusCode(401);
                return res;
            }
            else if(type == 'createError' && flag){
                res.setStatusCode(201);
                return res;
            }
        } else if (req.getEndpoint().contains('/files/content') && req.getMethod() == 'POST') {
            res.setBody('{"entries": [{"id": "new_file_id", "name": "New File", "type": "file"}]}');
            if(type == 'success'){
             	res.setStatusCode(201);
                return res;
         	}
            if(type == 'uploadError' && !flag){
                flag =! flag;
                res.setStatusCode(401);
                return res;
            } else if(type == 'uploadError' && flag){
                res.setStatusCode(201);
                return res;
            }
        } else if (req.getEndpoint().contains('/files/') && req.getMethod() == 'GET') {
            res.setBody('mock_file_content');
            if(type == 'downloadSuccess'){
             	res.setStatusCode(302);
                return res;
         	}
            if(type == 'downloadError' && !flag){
                flag = !flag;
                res.setStatusCode(401);
                return res;
            }
            else if(type == 'downloadError' && flag){
                res.setStatusCode(302);
                return res;
            }
            if(type == 'previewSuccess'){
             	res.setStatusCode(200);
                res.setBody('{"url":"http//box/file/1"}');
                res.setHeader('Location', 'http//box.com');
                return res;
         	}
            if(type == 'previewError'&& !flag){
                flag = !flag;
                res.setStatusCode(401);
                res.setHeader('Location', '');
                return res;
            }
            else if(type == 'previewError' && flag){
                res.setStatusCode(200);
                res.setBody('{"url":"http//box/file/1"}');
                res.setHeader('Location', 'http//box.com');
                return res;
            }
        } else if(req.getMethod() == 'DELETE'){
            res.setBody('');
            if(type == 'success'){
             	res.setStatusCode(204);
                return res;
         	}
            if(type == 'deleteError' && !flag){
                flag = !flag;
                res.setStatusCode(401);
                return res;
            }
            else if(type == 'deleteError' && flag){
                res.setStatusCode(204);
                return res;
            }
         }
        if(type == 'success'){
            res.setStatusCode(200);
        } else{
            res.setStatusCode(400);
            res.setBody('{"message":"Error"}');
        }
         
        return res;
    }
}