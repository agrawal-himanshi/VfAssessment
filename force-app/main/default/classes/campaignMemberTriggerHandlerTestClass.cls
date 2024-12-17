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
private class campaignMemberTriggerHandlerTestClass {

    @isTest
    static void testAfterInsert() {

        // Step 1: Create a test Campaign
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;

        // Step 2: Create a test Lead to associate with the Campaign
        Lead testLead = new Lead(FirstName = 'Johny', LastName = 'Doer', Email = 'john.doe@example.com', Phone = '555-555-5555', Company = 'Acme Corp');
        insert testLead;

        // Step 3: Ensure no existing CampaignMembers for this Lead and Campaign
        List<CampaignMember> existingCampaignMembers = [
            SELECT Id FROM CampaignMember WHERE LeadId = :testLead.Id AND CampaignId = :testCampaign.Id
        ];
        if (!existingCampaignMembers.isEmpty()) {
            delete existingCampaignMembers;
        }

        CampaignMember campaignMember = new CampaignMember(LeadId = testLead.Id, CampaignId = testCampaign.Id);
        insert campaignMember;

        testCampaign = [SELECT Id, Encrypt_Campaign_Id__c FROM Campaign WHERE Id = :testCampaign.Id];
        System.assertNotEquals(null, testCampaign.Encrypt_Campaign_Id__c, 'Encrypted Campaign ID should not be null');
        String encryptedCampaignId = testCampaign.Encrypt_Campaign_Id__c;
        System.assert(encryptedCampaignId.length() > 0, 'Encrypted Campaign ID should have some length');
    }
    
}




