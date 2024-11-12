@isTest
global class GoogleDriveMockTest implements HttpCalloutMock {
    private String responseType;

    public GoogleDriveMockTest(String type) {
        this.responseType = type;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        // Default behavior for success and error response handling
        if (responseType == 'success') {
            res.setStatusCode(200);
        } else if (responseType == 'error') {
            res.setStatusCode(400);
        } else {
            res.setStatusCode(500);  // default to internal error if unknown
            res.setBody('{"error": "internal_error", "message": "An unexpected error occurred"}');
        }

        // Handling GET method request
        if (req.getMethod() == 'GET') {
            if (responseType == 'success') {
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
                        '}]}' );
            } else if (responseType == 'error') {
                res.setBody('{"error": "invalid_request"}');
            }
        }

        // Handling OAuth token request for GET (Google OAuth API v2)
        else if (req.getEndpoint() == 'https://accounts.google.com/o/oauth2/token') {
            if (responseType == 'success') {
                res.setBody('{"access_token":"test_access_token","refresh_token":"test_refresh_token","expires_in":"3600","token_type": "bearer"}');
            } else if (responseType == 'error') {
                res.setBody('{"error": "invalid_request"}');
            }
        }

        // Handling OAuth Token Request for POST (Google OAuth API v4)
        else if (req.getEndpoint() == 'https://www.googleapis.com/oauth2/v4/token') {
            if (responseType == 'success') {
                res.setBody('{"access_token":"test_access_token","expires_in":"3600","token_type": "bearer"}');
            } else if (responseType == 'error') {
                res.setBody('{"error": "invalid_request"}');
            }
        }

        // Handling DELETE method for file removal
        else if (req.getMethod() == 'DELETE') {
            if (responseType == 'success') {
                res.setStatusCode(204);  // Successful deletion response
                res.setBody('');  // No content
            } else if (responseType == 'error') {
                res.setStatusCode(401);  // Unauthorized error response
                res.setBody('{"error": "unauthorized"}');
            }
        }

        // Handling POST method for file creation/upload
        else if (req.getMethod() == 'POST') {
            if (responseType == 'success') {
                res.setBody('{"kind": "drive#file",' +
                            '"mimeType": "application/vnd.google-apps.folder",' +
                            '"id": "1aSD_H0fy7laFLmEccqXlciih7lMrnKMj",' +
                            '"name": "Hello"}');
            } else if (responseType == 'error') {
                res.setBody('{"error": "invalid_request"}');
            }
        }

        // Handling upload request for Google Drive
        else if (req.getEndpoint() == 'https://www.googleapis.com/upload/drive/v3/files') {
            if (responseType == 'success') {
                res.setBody('{"name": "uploadedfile.txt"}');
            } else if (responseType == 'error') {
                res.setStatusCode(401);  // Unauthorized error response
                res.setBody('{"error": "unauthorized"}');
            }
        }

        return res;
    }
}
