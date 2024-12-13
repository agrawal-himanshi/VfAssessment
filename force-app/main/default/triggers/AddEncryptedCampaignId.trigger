trigger AddEncryptedCampaignId on CampaignMember (after insert, after update, before insert, before update) {

    new campaignMemberTriggerHandler().run();

}




