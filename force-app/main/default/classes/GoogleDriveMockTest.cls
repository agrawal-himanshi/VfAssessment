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

        // Handle files/folders listing requests (GET method)
        if (req.getMethod() == 'GET' && req.getEndpoint().contains('drive/v3/files')) {
            if (responseType == 'errors' && !flag) {
                res.setStatusCode(401);  // First unauthorized error
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

        // Handle OAuth token requests
        if (req.getEndpoint().contains('oauth2/token')) {
            res.setStatusCode(200);
            res.setBody('{"access_token":"test_access_token","expires_in":"3600","token_type": "bearer"}');
            return res;
        }

        // User details request (People API)
        if (req.getEndpoint().contains('people.googleapis.com')) {
            if (responseType == 'success') {
                res.setStatusCode(200);
                res.setBody('{"names": [{"displayName": "Test User"}], "emailAddresses": [{"value": "testuser@example.com"}]}');
            } else {
                res.setStatusCode(400);
                res.setBody('{"error": "invalid_request"}');
            }
            return res;
        }

        // Handle file creation/upload (POST)
        if (req.getMethod() == 'POST' && req.getEndpoint().contains('drive/v3/files')) {
            if (responseType == 'errors' && !flag) {
                res.setStatusCode(401);  // Unauthorized on first call
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
                flag = true;
            } else {
                res.setStatusCode(204);  // Success on subsequent delete
                res.setBody('');  // No content
            }
            return res;
        }

        // Default response
        res.setStatusCode(responseType == 'success' ? 200 : 400);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
}
