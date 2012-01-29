public class ExceptionClass {
    
    public static Id InsertException(Exception exc) {
 		// save exception
		return CreateException(exc);
    }
    
    /////// Private Methods
    
    private static Id CreateException(Exception exc) {
 		// save exception
		Exception__c ex = new Exception__c();
		ex.Message__c = exc.getMessage();
		ex.Type_Name__c = exc.getTypeName();
		ex.Line_Number__c = exc.getLineNumber();
		ex.Stack_Trace__c = exc.getStackTraceString();
		
		insert ex;

		return ex.Id;
    }
    
}