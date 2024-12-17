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
public class LeadControllerTest {

    @isTest
    static void testCreateLeadWithCampaignMember() {
        // Create a test Campaign
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;

        // Create a test Lead
        Lead testLead = new Lead(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', Phone = '555-555-5555', Company = 'Acme Corp');
        insert testLead;

        // Use the campaignId from the inserted Campaign
        String campaignId = testCampaign.Id;

        Test.startTest();
        // Create CampaignMember using the custom method
        String campaignMemberId = LeadController.createLeadWithCampaignMember(testLead.FirstName, testLead.LastName, testLead.Email, testLead.Phone, testLead.Company);
        Test.stopTest();

        System.assertNotEquals(campaignMemberId, 'Error: null', 'Campaign Member ID should not be null or an error message');

        // Query the newly created Lead using the correct Id
        Lead createdLead = [SELECT Id, FirstName, LastName, Email, Phone, Company FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(createdLead.LastName, testLead.LastName, 'Last Name should match');
        System.assertEquals(createdLead.Email, testLead.Email, 'Email should match');
        System.assertEquals(createdLead.Phone, testLead.Phone, 'Phone should match');

        // Query the CampaignMember using the Lead Id
        List<CampaignMember> campaignMembers = [SELECT Id, LeadId, CampaignId FROM CampaignMember WHERE LeadId = :createdLead.Id];
    }

    @isTest
    static void testCreateLeadWithCampaignMember_Error() {
        Test.startTest();
        String result = LeadController.createLeadWithCampaignMember(null, null, null, null, null);
        Test.stopTest();

        System.assert(result.startsWith('Error:'), 'Error message should be returned');
    }
}

