trigger AddEncryptedCampaignId on CampaignMember (after insert) {

    List<CampaignMember> campaignMembersToUpdate = new List<CampaignMember>();

    for (CampaignMember campMember : Trigger.new) {
        try {
            String campaignId = campMember.CampaignId;
            if (String.isNotBlank(campaignId)) {

                String encryptedCampaignId = encryptCampaignId(campaignId);

                CampaignMember updatedMember = new CampaignMember(
                    Id = campMember.Id, // Keep the Id of the record
                    Encrypted_Campaign_Id__c = encryptedCampaignId 
                );
                campaignMembersToUpdate.add(updatedMember);
            }
        } catch (Exception e) {
            System.debug('Error encrypting CampaignId: ' + e.getMessage());
        }
    }

    if (!campaignMembersToUpdate.isEmpty()) {
        update campaignMembersToUpdate;
    }

    // Method to encrypt the CampaignId
    private static String encryptCampaignId(String campaignId) {

        Blob targetBlob = Blob.valueOf(campaignId);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        return EncodingUtil.base64Encode(hash);

    }

}

