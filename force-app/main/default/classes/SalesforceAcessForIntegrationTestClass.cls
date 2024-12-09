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
public class SalesforceAcessForIntegrationTestClass {
    
     	@testSetup 
    	static void setup() {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode('VGhpcyBpcyBhIHRlc3QgZmlsZSBib2R5');
        cv.Title = 'TestFile';
        cv.PathOnClient = 'TestFile.txt';
        insert cv;

        Contact con = new Contact(FirstName = 'Himanshi', LastName = 'Agrawal');
        insert con;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = con.Id;
        insert cdl;
    }
    
    	@isTest
    	static void testGetContactsExistingContact() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Contact/';
        request.addParameter('FName', 'Himanshi');
        request.addParameter('LName', 'Agrawal');
        RestContext.request = request;

        List<ContentDocumentLink> result = SalesforceAccessForIntegration.getContacts();
    }
	
    	@isTest
    	static void testGetContactsNewContact() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Contact/';
        request.addParameter('FName', 'abc');
        request.addParameter('LName', 'xyz');
        RestContext.request = request;

        List<ContentDocumentLink> result = SalesforceAccessForIntegration.getContacts();

    }
	
    static testMethod void testCreateContact() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Contact/';
        request.httpMethod = 'POST';
        
        request.addParameter('fileName', 'TestFile.txt');
        request.addParameter('content', EncodingUtil.base64Encode(Blob.valueOf('Test file content')));
        request.addParameter('userId', UserInfo.getUserId());
        request.addParameter('FName', 'lmn');
        request.addParameter('LName', 'pqr');
        
        RestContext.request = request;

        List<ContentDocumentLink> result = SalesforceAccessForIntegration.CreateContact('TestFile.txt',EncodingUtil.base64Encode(Blob.valueOf('Test file content')),UserInfo.getUserId(),'Himanshi','Agrawal');

        ContentDocumentLink cdl = result[0];
        system.debug('cdl ==> ' + cdl);

    }

    
}