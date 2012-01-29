trigger AccountTrigger on Account (before insert, before update) {
	AccountClass objAccount = new AccountClass();
	objAccount.BeforeInsertUpdateAccount(trigger.new);
	
	// create star rating cases for ESR or Venere/EEM accounts
	if(Trigger.isUpdate) {
		objAccount.NewUnratedProperties(trigger.oldMap, trigger.new);
	}
}