trigger ConnectionTrigger on Connection__c (before insert, before update, before delete) {
    ConnectionClass connectionObj = new ConnectionClass();
    
    if (trigger.isBefore && trigger.isInsert){
        connectionObj.buildConnectionIntegrationKeys(trigger.New, null);
    }
    if (trigger.isBefore && trigger.isUpdate){
        connectionObj.buildConnectionIntegrationKeys(trigger.New, trigger.oldMap);
    }
    if (trigger.isBefore && trigger.isDelete){
        connectionObj.deleteConnectionIntegrationKeys(trigger.Old);
    }
    
}