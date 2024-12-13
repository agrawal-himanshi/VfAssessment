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

//     @AuraEnabled
//     public static String encrypt(String plainText) {
//         // Generate a key
//         Blob key = Crypto.generateKey('AES256');
//         // Encrypt the plain text
//         Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(plainText));
//         // Convert to Base64
//         return EncodingUtil.base64Encode(encryptedData);
//     }

//     @AuraEnabled
//     public static String decrypt(String encryptedText) {
//         // Generate a key
//         Blob key = Crypto.generateKey('AES256');
//         // Decrypt the Base64 encoded text
//         Blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, EncodingUtil.base64Decode(encryptedText));
//         // Convert back to String
//         return decryptedData.toString();
//     }
// }



