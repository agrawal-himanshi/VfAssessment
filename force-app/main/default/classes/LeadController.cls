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

            // Step 2: Create CampaignMember
            CampaignMember newCampaignMember = new CampaignMember(
                LeadId = newLead.Id,
                CampaignId = '701dL00000gP8F7QAK'
            );
            insert newCampaignMember;

            return newCampaignMember.Id;

        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}


