public with sharing class SoqlBuilder {

	public class Condition{
		
		public String Field {get; set;}
		public String Value {get; set;}
		public String Operator {get; set;}
		
		public Condition(String field, String value) {
			buildCondition(field, value, '=');
		}
		
		public Condition(String field, String value, String operator){
			buildCondition(field, value, operator);
		}
		
		public String getCondition() {
			if(this.Operator == 'In' || this.Operator == 'Not In'){
				return this.Field + ' ' + this.Operator + ' (' + this.Value + ')';
			}else if(Utilities.isBoolean(this.Value) || Utilities.isDate(this.Value) || 
					Utilities.isDateTime(this.Value) || Utilities.isDouble(this.Value) || this.Value == null) {
				return this.Field + ' ' + this.Operator + ' ' + this.Value;
			}else {
				return this.Field + ' ' + this.Operator + ' \'' + String.escapeSingleQuotes(this.Value) + '\'';
			}
		}
		
		//// Private Methods
		private void buildCondition(String field, String value, String operator) {
			this.Field = field;
			this.Value = value;
			this.Operator = operator;
		}
	}
	
	public static List<SObject> ExecuteSelectQuery(String objectName, List<Condition> conditions) {
		
		return ExecuteSelectQuery('*', objectName, conditions, null, null);
	}

	public static List<SObject> ExecuteSelectQuery(String objectName, List<Condition> conditions, String conditionLogic) {
		
		return ExecuteSelectQuery('*', objectName, conditions, conditionLogic, null);
	}

	/// condition logic ex.: {0} or ({1} and {2})
	public static List<SObject> ExecuteSelectQuery(String myFields, String objectName, List<Condition> conditions, String conditionLogic, String orderBy) {
		List<SObject> listSObjects = new List<SObject>();
		
		String query = BuildQuery('Select', myFields, objectName, conditions, conditionLogic, orderBy);
        if(query == null) { return null; }
        
        system.debug('>>>>>>>>>> SoqlBuilder.ExecuteQuery query = ' + query);
        listSObjects = Database.query(query);
		
		return listSObjects;
	}
	
	/////////// Private Methods
	
	private static String BuildQuery(String queryType, String myFields, String objectName, List<Condition> conditions, String conditionLogic, String orderBy) {
		String query;
		
		// get the object type		
		SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
		if(objectType == null) { return null; }

		// get list of fields
		String fieldList = GetFields(myFields, objectType);
       
        // build query
        query = queryType + ' ' + fieldList + ' From ' + objectName;
        
        // include where clause
        if(conditions != null) {
        	query += ' Where ' + buildCondition(conditions, conditionLogic); //condition;
        }
        
        // include order by clause
        if(orderBy != null && orderBy != '') {
        	query += ' Order by ' + orderBy;
        }
        
        return query;
	}
	
	private static String buildCondition(List<Condition> conditions, String conditionLogic){
        String condition;
        
        if(conditions.size() == 1) { 
        	// only one condition exists
        	condition = conditions.get(0).getCondition();
        }else if(conditions.size() > 1){
	        // get the logic pattern ex. {0} and {1} and {2})
	        if(conditionLogic == NULL) conditionLogic = buildConditionLogic(conditions);
	        system.debug('>>>>>> conditionLogic = ' + conditionLogic);
	        
	        // need to convert the list of conditions to a list of strings in order to use the string format function
	        List<String> arguments = new List<String>();
	        for(Condition myCondition : conditions) {
	        	arguments.add(myCondition.getCondition());
	        }
	        condition = String.format(conditionLogic, arguments);
	        
        }
        
		return condition;
	}
	
	// for each condition in the list build a logic pattern ex. {0} and {1} and {2}
	private static String buildConditionLogic(List<Condition> conditions) {
		String logic = '{0}';
		
		if(conditions.size() > 1){
	        for(Integer i = 1; i < conditions.size(); i++) {
				system.debug('>>>> logic = ' + logic);
	        	logic += ' And {' + i + '}';
				system.debug('>>>> logic = ' + logic);
	        }	
		}
        
        return logic;	
	}

	private static String GetFields(String myFields, SObjectType objectType) {
		String strFields;
		
		if(myFields == null || myFields.contains('*')) {
			String tmpFields;
			// get list of all fields
			List<Schema.SObjectField> listFields = objectType.getDescribe().fields.getMap().values();
			
	        tmpFields = listFields[0].getDescribe().LocalName;
	        for (Integer i = 1; i < listFields.size(); i++) {
	            tmpFields += ',' + listFields[i].getDescribe().LocalName;
	        }
	        
	        if( myFields.contains('*')) {
	        	strFields = myFields.replace('*', tmpFields);
	        }else {
	        	strFields = tmpFields;
	        }
	        
		}else {
			strFields = myFields;
		}
		
		return strFields;
	}
}