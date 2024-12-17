public with sharing class LeadController {

    @AuraEnabled
    public static String createLeadWithCampaignMember(String firstName, String lastName, String email, String phone, String company) {
        String campaignId;
        try {
            // Step 1: Create Lead
            Lead newLead = new Lead(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Phone = phone,
                Company = company
            );
            insert newLead;

            Campaign newCampaign = new Campaign(
                Name = '' + newLead.LastName + ' Test Campaign',
                StartDate = System.today(),
                Status = 'Planned'
            );
            insert newCampaign;

            // Step 3: Create CampaignMember to link the Lead to the Campaign
            CampaignMember newCampaignMember = new CampaignMember(
                LeadId = newLead.Id,
                CampaignId = newCampaign.Id
            );
            insert newCampaignMember;

            return newCampaign.Id;

        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}


