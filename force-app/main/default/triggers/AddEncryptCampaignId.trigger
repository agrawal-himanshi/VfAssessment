trigger AddEncryptCampaignId on Campaign (after insert, after update, before insert, before update) {

    new campaignMemberTriggerHandler().run();

}






