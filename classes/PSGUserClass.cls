public with sharing class PSGUserClass {
    
    private static final Integer TOKEN_DURATION_DAYS = 7;

    public static List<PSG_User__c> findAllByPSGIds(Set<Id> Ids) {
        return [SELECT Id
                      ,Name
                      ,Active__c
                      ,Email__c
                      ,Phone__c
                      ,Title__c
                  FROM PSG_User__c
                 WHERE Id IN :Ids];
    }   
    
    public static PSG_User__c findById(Id psgUserId) {
        return [SELECT Id
                  ,Name
                  ,Active__c
                  ,Email__c
                  ,Phone__c
                  ,Title__c
              FROM PSG_User__c
             WHERE Id = :PsgUserId];
  } 
    

    public static PSG_User__c findByEmail(String email) {
        PSG_User__c psgUser;
        
        List<SoqlBuilder.Condition> conditions = new List<SoqlBuilder.Condition>();
        conditions.add(new SoqlBuilder.Condition('Email__c', email));
        conditions.add(new SoqlBuilder.Condition('Active__c', 'true'));
        psgUser = findBy(conditions);

        return psgUser;
    }

    public static PSG_User__c findByName(String userName) {
        PSG_User__c psgUser;
        
        List<SoqlBuilder.Condition> conditions = new List<SoqlBuilder.Condition>();
        conditions.add(new SoqlBuilder.Condition('Name', userName));
        conditions.add(new SoqlBuilder.Condition('Active__c', 'true'));
        psgUser = findBy(conditions);
        
        return psgUser;
    }

    public static void generateToken(PSG_User__c psgUser) {
        // generate a token
        psgUser.ReContracting_Token__c = getToken(psgUser.Name);
        psgUser.Token_Issued_Date__c = system.today();
        psgUser.Token_Verified__c = false;
        update psgUser;
    }
    
    public static void verifyToken(PSG_User__c psgUser, String token){
        if(token != NULL && psgUser.ReContracting_Token__c == token && 
           psgUser.Token_Issued_Date__c.addDays(TOKEN_DURATION_DAYS) >= System.today()){
              
              psgUser.Token_Verified__c = true;
              update psgUser;
        }
    }
    
    public static Boolean isAuthenticatedUser(PSG_User__c psgUser){
        return (psgUser != NULL && 
                psgUser.ReContracting_Token__c != NULL && 
                psgUser.Token_Verified__c == true && 
                psgUser.Token_Issued_Date__c.addDays(TOKEN_DURATION_DAYS) >= System.today()
                );
        
    }
    
    ///// Private Methods
    private static PSG_User__c findBy(List<SoqlBuilder.Condition> conditions) {
        PSG_User__c psgUser;
        
        List<SObject> results = SoqlBuilder.ExecuteSelectQuery('PSG_User__c', conditions);
        
        if(results.isEmpty() == false) {
            psgUser = (PSG_User__c)results.get(0);
        }
        
        return psgUser;
    }
    
    private static String getToken(String psgUserName){
        // Computes a message authentication code (MAC) for the input string, using the private key and the specified algorithm. 
        String algorithmName = 'hmacSHA1';
        String input = psgUserName + system.now() + Crypto.getRandomLong();
        String privateKey = 'qeoix@!poium*#l;jwqero435w34';
        
        Blob mac = Crypto.generateMac(algorithmName,  Blob.valueOf(input), Blob.valueOf(privateKey));
        String macUrl = EncodingUtil.urlEncode(EncodingUtil.base64Encode(mac), 'UTF-8');    
        
        return macUrl;
    }

    private static PSG_User__c findUser(String whereClause) {
        
        String soql = 'SELECT Id ' +
                  ',Name ' +
                  ',Active__c ' +
                  ',Email__c ' +
                  ',Phone__c ' +
                  ',Title__c ' +
              'FROM PSG_User__c ' +
              'WHERE ' + whereClause +
              'LIMIT 1';
     
        PSG_User__c user = Database.query(soql);
        return user;
    }
}