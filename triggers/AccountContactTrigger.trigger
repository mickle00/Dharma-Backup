trigger AccountContactTrigger on Account_Contact__c (before insert) {
    AccountContactClass.buildUniqueKeys(trigger.New);
}