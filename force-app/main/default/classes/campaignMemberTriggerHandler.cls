public class campaignMemberTriggerHandler extends TriggerHandler {

    // Override the afterInsert method for Campaign trigger
    public override void afterInsert() {
        List<Campaign> campaignsToUpdate = new List<Campaign>();

        // Loop through the inserted Campaign records
        for (Campaign campaign : (List<Campaign>) Trigger.new) {
            String campaignId = campaign.Id;

            if (String.isNotBlank(campaignId)) {
                // Encrypt the CampaignId
                String encryptedCampaignId = encryptCampaignId(campaignId);

                Campaign updatedCampaign = new Campaign(
                    Id = campaign.Id,  
                    Encrypt_Campaign_Id__c = encryptedCampaignId
                );
                campaignsToUpdate.add(updatedCampaign);
            }
        }

        // Update the Campaign records with the encrypted CampaignId
        if (!campaignsToUpdate.isEmpty()) {
            update campaignsToUpdate;
        }
    }

    // Method to encrypt the CampaignId using MD5 and return the base64 encoded value
    private static String encryptCampaignId(String campaignId) {
        Blob targetBlob = Blob.valueOf(campaignId);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        return EncodingUtil.base64Encode(hash);
    }
}




