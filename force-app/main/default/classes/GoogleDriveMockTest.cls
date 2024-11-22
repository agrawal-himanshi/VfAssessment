@isTest
global class GoogleDriveMockTest implements HttpCalloutMock {
    private String responseType;
    private Boolean flag;

    public GoogleDriveMockTest(String type) {
        flag = false;
        this.responseType = type;
    }

    public HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');  // Set Content-Type

        // Handle files/folders listing requests (GET method)
        if (req.getMethod() == 'GET' && req.getEndpoint().contains('drive/v3/files')) {
            if (responseType == 'errors' && !flag) {
                res.setStatusCode(401);  // First unauthorized error
                res.setBody('{"error": "unauthorized"}');  // Set appropriate body content for errors
                flag = true;
            } else {
                res.setStatusCode(200);  // Success on subsequent call
                res.setBody('{"files": [{' +
                            '"kind": "drive#file",' +
                            '"mimeType": "application/octet-stream",' +
                            '"id": "1cEyIW0zeOYI6ZI5W7XVs2IC8S2STUqYC",' +
                            '"name": "Untitled",' +
                            '"trashed": false' +
                            '}, {' +
                            '"kind": "drive#file",' +
                            '"mimeType": "application/vnd.google-apps.folder",' +
                            '"id": "1aSD_H0fy7laFLmEccqXlciih7lMrnKMj",' +
                            '"name": "Hello",' +
                            '"trashed": false' +
                            '}]}');
            }
            return res;
        }

        System.debug('Request Endpoint: ' + req.getEndpoint());
        // Handle OAuth token requests
        if (req.getEndpoint().contains('oauth2.googleapis.com/token')&&req.getBody().contains('authorization_code')) {
             if(responseType == 'error') {
                res.setStatusCode(400);  // Error on invalid request
                res.setBody('{"error": "invalid_request"}');
            }
            else{
            	res.setStatusCode(200);  // Successful response
            	System.debug(res.getBody());
            	res.setBody('{"access_token":"test_access_token","refresh_token":"test_refresh_token", "expires_in":"3600","token_type": "bearer"}');
            }
            return res;
        }

        // User details request (People API)
        if (req.getEndpoint().contains('people.googleapis.com')) {
            if (responseType == 'success') {
                res.setStatusCode(200);  // Success on valid request
                res.setBody('{"names": [{"displayName": "Test User"}], "emailAddresses": [{"value": "testuser@example.com"}]}');
            } else {
                res.setStatusCode(400);  // Error on invalid request
                res.setBody('{"error": "invalid_request"}');
            }
            return res;
        }

        // Handle file creation/upload (POST)
        if (req.getMethod() == 'POST' && req.getEndpoint().contains('drive/v3/files')) {
            if (responseType == 'errors' && !flag) {
                res.setStatusCode(401);  // Unauthorized on first call
                res.setBody('{"error": "unauthorized"}');  // Set appropriate error body content
                flag = true;
            } else {
                res.setStatusCode(200);  // Success on subsequent call
                res.setBody('{"kind": "drive#file",' +
                            '"mimeType": "application/vnd.google-apps.folder",' +
                            '"id": "1aSD_H0fy7laFLmEccqXlciih7lMrnKMj",' +
                            '"name": "Hello"}');
            }
            return res;
        }

        // Handle file deletion (DELETE)
        if (req.getMethod() == 'DELETE' && req.getEndpoint().contains('drive/v3/files')) {
            if (responseType == 'errors' && !flag) {
                res.setStatusCode(401);  // Unauthorized error on first delete
                res.setBody('{"error": "unauthorized"}');  // Set error response body
                flag = true;
            } else {
                res.setStatusCode(204);  // Success on subsequent delete (No Content)
                res.setBody('');  // No content for successful delete
            }
            return res;
        }

        // Default error response if the endpoint is unrecognized
        res.setStatusCode(400);  // Bad Request status code for unhandled cases
        res.setBody('{"error": "invalid_request"}');  // Error message body
        return res;
    }
}