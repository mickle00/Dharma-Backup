public with sharing class ConnectionClass {
    
    public static Connection__c getConnection(Id connectionId){
        Connection__c myConnection = [SELECT Id
                                            ,Name
                                            ,Account__c
                                            ,Account__r.Name
                                            ,Account__r.Id
                                            ,PSG_Account_ID__c
                                            ,Type__c
                                            ,Status__c
                                            ,Platform__c
                                            ,Go_Date__c
                                            ,LastModifiedDate
                                            ,Connectivity_System__c
                                            ,Connectivity_System__r.Connectivity_System_Type__c 
                                            ,Account_Repco__c
                                            ,Account__r.Market_Manager_Email__c
                                            ,Account__r.Market_Manager_Name__c
                                            ,Connectivity_System__r.Connectivity_Vendor__c
                                            ,Connectivity_System__r.Connectivity_Vendor__r.Market_Manager_Email__c 
                                            ,Connectivity_System__r.Connectivity_Vendor__r.Market_Manager_Name__c
                                       FROM Connection__c
                                      WHERE Id = :connectionId];
        return myConnection;
    }
    
    public static List<Connection__c> getConnectionsByAccountId (Id accountId){
        return [SELECT  Id
        			   ,Account__c
                       ,Name 
                       ,Connectivity_System__c
                       ,Connectivity_System__r.Connectivity_Vendor__r.Name
                       ,Connectivity_System__r.Connectivity_System_Type__c
                       ,PSG_Account_ID__c
                       ,Type__c
                       ,Status__c
                       ,Platform__c
                       ,Go_Date__c
                       ,LastModifiedDate
                       ,LastModifiedBy.FirstName
                       ,LastModifiedBy.LastName 
                FROM  Connection__c 
               WHERE  Account__c = :accountId
            ORDER BY  LastModifiedDate DESC];
    }
    
        
    public static List<Connection__c> ConnectionsByAccounts(Set<Id> accountIds) {
      return [SELECT Id
                    ,Account__c
                    ,Name 
                    ,Connectivity_System__c
                    ,Connectivity_System__r.Connectivity_Vendor__r.Name
                    ,Connectivity_System__r.Connectivity_System_Type__c
                    ,PSG_Account_ID__c
                    ,Type__c
                    ,Status__c
                    ,Platform__c
                    ,Go_Date__c
                    ,LastModifiedDate
                    ,LastModifiedBy.FirstName
                    ,LastModifiedBy.LastName 
                FROM Connection__c 
               WHERE Account__c IN :accountIds];
    }
    
    
    // Check for updates before upserting. Since this is displayed with rollout steps, and notes, 
    public static void upsertConnection(Connection__c myConnection){
    	if (myConnection.Id != null){
    		Connection__c oldConnection = getConnection(myConnection.Id);
    		if (oldConnection != myConnection) upsert myConnection;
    	} else{
    		insert myConnection;
    	}
    }
    
    public void buildConnectionIntegrationKeys(List<Connection__c> myConnections, Map<Id, Connection__c> myOldConnectionMap){
        this.accountIds = getAccountIds(myConnections);
        this.accountActiveConnectionMap = getAccountActiveConnectionMap(accountIds);
        
        for (Connection__c myConnection : myConnections){
    		if (myConnection.Status__c == 'Connected'){
                this.buildConnectionIntegrationKey(myConnection);
                this.addActiveConnection(myConnection);
    		} else {
    			if (myOldConnectionMap != null){
	    			if (myOldConnectionMap.get(myConnection.Id).Status__c == 'Connected'){
	    				this.removeActiveConnection(myConnection);	    				 		
	    			}
    			}    		
    			myConnection.Integration_Connection_Key__c = null;
    		}
        }
        update this.accountActiveConnectionMap.values();        
    }
    
    public void deleteConnectionIntegrationKeys(List<Connection__c> myDeletedConnections){
        this.accountIds = getAccountIds(myDeletedConnections);
        this.accountActiveConnectionMap = getAccountActiveConnectionMap(accountIds);
        
        for (Connection__c myDeletedConnection : myDeletedConnections){
    		if (myDeletedConnection.Status__c == 'Connected'){
    			this.removeActiveConnection(myDeletedConnection);
    		}
        }
        update this.accountActiveConnectionMap.values();
    }
    
	/**
	
	PRIVATE METHODS
	
	**/
	
	private Map<Id, Account> accountActiveConnectionMap;
	private Set<Id> accountIds;
    
    
    private void buildConnectionIntegrationKey(Connection__c myConnection){
    	String concatenator = ':';
    	myConnection.Integration_Connection_Key__c =  myConnection.PSG_Account_ID__c + concatenator
        	                                        + myConnection.Type__c + concatenator
        	                                    	+ myConnection.Platform__c;
    }
    
    private void addActiveConnection(Connection__c myConnection){
    	string activeConnectionKey = myConnection.Type__c + '-' + myConnection.Platform__c;  
		Account myConnectionsAccount = this.accountActiveConnectionMap.get(myConnection.Account__c);		
		if (myConnectionsAccount != null){
	    	if (myConnectionsAccount.Active_Connections__c != null){
	        	if (!myConnectionsAccount.Active_Connections__c.contains(activeConnectionKey)){
	        		myConnectionsAccount.Active_Connections__c = myConnectionsAccount.Active_Connections__c + ';'+ activeConnectionKey; 
	        	}
	    	} else{
	    		myConnectionsAccount.Active_Connections__c = activeConnectionKey;
	    	}
		}    	
    }
    
    private void removeActiveConnection(Connection__c myConnection){
    	string activeConnectionKey = myConnection.Type__c + '-' + myConnection.Platform__c;  
		Account myConnectionsAccount = this.accountActiveConnectionMap.get(myConnection.Account__c);
		if (myConnectionsAccount != null){
			if (myConnectionsAccount.Active_Connections__c != null){
				if (myConnectionsAccount.Active_Connections__c.contains(activeConnectionKey)){
					myConnectionsAccount.Active_Connections__c = myConnectionsAccount.Active_Connections__c.replace(activeConnectionKey, '');
				}
			}
			
		}	
    }
    
    private Set<Id> getAccountIds (List<Connection__c> myConnections){
    	Set<Id> accountIds = new Set<Id>();
    	for (Connection__c myConnection : myConnections){
    		accountIds.add(myConnection.Account__c);
    	}
    	return accountIds;
    }
    
    private Map<Id, Account> getAccountActiveConnectionMap(Set<Id> accountIds){
    	return new Map<Id, Account> ([SELECT Id 
    										,Active_Connections__c 
										FROM Account 
									   WHERE Id IN : accountIds]);    	   	
    }
}