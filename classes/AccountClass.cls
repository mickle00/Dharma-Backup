public with sharing class AccountClass {
	
	public List<Account> FindAllById(Set<Id> accountIds) {
		
		List<Account> accounts = new List<Account>();
		
		accounts = [SELECT Id
		                  ,Name
		                  ,Expedia_Hotel_Id__c
		                  ,Vendor_Id__c
		                  ,Region__r.Name
		                  ,Booking_Delivery_Method__c
		                  ,ARI_Enabled__c
		              FROM Account
		             WHERE Id IN :accountIds];
		             
	  return accounts;
		 
	}

	public void BeforeInsertUpdateAccount(List<Account> accounts) {
		Region__c MEXICO = RegionClass.FindRegionByName('Mexico & Central America');
		Region__c SOUTH_AMERICA = RegionClass.FindRegionByName('South America');
		Super_Region__c SUPER_REGION = SuperRegionClass.FindSuperRegionByName('LATAM');

		for(Account newAcct : accounts) {
			if(newAcct.Region__c == SOUTH_AMERICA.Id || newAcct.Region__c == MEXICO.Id) {
				// set the super region if the region field equals South America or Mexico
				newAcct.Super_Region__c = SUPER_REGION.Id;
			}else if(newAcct.Region__c == NULL && newAcct.Super_Region__c == SUPER_REGION.Id) {
				// clear the super region field if there is no value for region
				newAcct.Super_Region__c = NULL;
			}
		}
	}
	
	public void NewUnratedProperties(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		List<Case> newCases = new List<Case>();
		RecordType starRatingRecordType = [Select Id From RecordType Where DeveloperName = 'Star_Ratings' And SObjectType = 'Case' limit 1];
		// map star ratings and cases to accounts
		Map<Id, Account> acctMapping = new Map<Id,Account>([Select Id
																, (Select Id From Star_Ratings__r limit 1)
																, (Select Id From Cases Where RecordTypeId = : starRatingRecordType.Id And IsClosed = false limit 1) 
																From Account 
																Where Id IN : newAccounts]);
		
		for(Account newAccount : newAccounts) {
			
			// get old values
			Account oldAccount = (oldAccounts == null ? null : oldAccounts.get(newAccount.Id));
			Account myAccount = acctMapping.get(newAccount.Id);
			
			// verify that the account is not a lead account, does not have any star ratings or open cases
			if(myAccount.Star_Ratings__r.isEmpty() && myAccount.Cases.isEmpty() && newAccount.PSG_Lead_Account__c == false) {

				if(newAccount.ESR_or_GDS__c == 'ESR' && newAccount.Expedia_Hotel_Id__c != NULL && (oldAccounts ==  NULL || oldAccount.ESR_or_GDS__c == 'GDS')) {
					// create a star rating case if the account was a GDS account and is now an ESR account, there are no star rating reviews,
					// an EID has been created and there is no open case
					Case myCase = this.CreateCase('GDS/ESR Transition', starRatingRecordType, newAccount, 'ESR');
					newCases.add(myCase);
				}else if(newAccount.Venere_Contract_Status__c == 'Accepted Contract' && newAccount.HIMS_Stop_Sell__c == false && 
						 (newAccount.Venere_Status__c == 'Active' && oldAccount.Venere_Status__c != 'Active')) {
					// create a star rating case if the account is a Venere account the Venere Status is Active, the Venere Contract Status is
					// Accepted Contract, there are no star rating reviews, and there is no open case
					Case myCase = this.CreateCase('New Venere/EEM contract', starRatingRecordType, newAccount, 'EEM');
					newCases.add(myCase);
			 	}
			}
		}
		
		// insert cases
		if(newCases.isEmpty() == false) {
			insert newCases;
		}
	}
	
	///// Private Methods
	private Case CreateCase(String subject, RecordType starRatingRecordType, Account acct, String sellingModel) {
		return new Case(Subject = subject
                       ,RecordTypeId = starRatingRecordType.Id
                       ,Origin = 'GDS/ESR Transition'
                       ,Type = 'New Star Review'
                       ,AccountId = acct.Id
                       ,Priority = '4'
                       ,Selling_Model__c = sellingModel
                       );
	}
}