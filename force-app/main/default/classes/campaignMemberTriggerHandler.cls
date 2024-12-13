public class campaignMemberTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        List<CampaignMember> campaignMembersToUpdate = new List<CampaignMember>();

        for (CampaignMember campMember : (List<CampaignMember>) Trigger.new) {
            try {
                String campaignId = campMember.CampaignId;
                if (String.isNotBlank(campaignId)) {
                    String encryptedCampaignId = encryptCampaignId(campaignId);

                    // Create updated CampaignMember with the encrypted field
                    CampaignMember updatedMember = new CampaignMember(
                        Id = campMember.Id, 
                        Encrypted_Campaign_Id__c = encryptedCampaignId
                    );

                    // Add to the list of records to be updated
                    campaignMembersToUpdate.add(updatedMember);
                }
            } catch (Exception e) {
                System.debug('Error encrypting CampaignId: ' + e.getMessage());
            }
        }

        // Update the records with the encrypted CampaignId
        if (!campaignMembersToUpdate.isEmpty()) {
            update campaignMembersToUpdate;
        }

    }

    // Method to encrypt the CampaignId using MD5 and return the base64 encoded value
    private static String encryptCampaignId(String campaignId) {
        Blob targetBlob = Blob.valueOf(campaignId);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        return EncodingUtil.base64Encode(hash);
    }

}



