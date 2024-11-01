public with sharing class IntegrationWrapperClass {
    public String responseBody;//for storing body of response
    public String responseStatusCode;// store status code 
    public String responseHeader;// store header
    
    public IntegrationWrapperClass(String body, String statusCode, String header) {
        this.responseBody=body;
        this.responseStatusCode=statusCode;
        this.responseHeader=header;
    }
    
    public IntegrationWrapperClass(String body, String statusCode) {
        this.responseBody=body;
        this.responseStatusCode=statusCode;
    }
}