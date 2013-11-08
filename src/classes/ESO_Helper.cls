/******************************************************************************
* @author        Mike Gill
* @date          05.11.2013
* @description   CloudSpokes - Early Stage Opportunity (ESO) 

Helper class for Early Stage Opportunity (ESO)


******************************************************************************/

public class ESO_Helper {
	
	// Method to deserialise custom setting JSON string into MAP
	public Map<String, Object> LoadESOConfig(){
	
		ESO_Config__c ESO_Config = [select Name, ESO_Config__c, ESO_Disable__c from ESO_Config__c limit 1];
				
		Map<String, Object> esoMap = new Map<String ,Object>();	
		return esoMap = (Map<String, Object>) JSON.deserializeUntyped(ESO_Config.ESO_Config__c);
		
		
	}
	
	// Generate Query String for Leads
    /*
	public String GetLeadQuery(){
			ESO_Config__c ESO_Config = [select Name, ESO_Config__c, ESO_Disable__c from ESO_Config__c limit 1];		
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(ESO_Config.ESO_Config__c);

		Object fieldName = '';
		String leadQuery = 'select ';
		Integer count = 1;
		
			for ( String name : m.keySet()){
				
					if (count < m.size()){
	        				leadQuery += fieldName + ', ';
	    				}
	    				else{
	    					leadQuery += fieldName + ', ProductInterest__c from Lead where LeadSource != \'Web\'';
	    				}
	    				
	    				count++;
		
			}

		return leadQuery;
	}
	*/
	// Web Lead Helper Method - Create Opp & Contact Role (Not for bulk operation)
	public void CreateOpportunity(Contact [] existingContact, String product){

		
		
			Opportunity o = new Opportunity();
			o.AccountId = existingContact[0].AccountId;
			o.CloseDate = Date.today();
			o.Name = existingContact[0].Account.Name + ':' + product;
			o.StageName = 'Validate';
			o.LeadSource = 'Web';
			insert o;
			OpportunityContactRole role = new OpportunityContactRole();
			role.OpportunityId = o.Id;
			role.ContactId = existingContact[0].Id;
			role.IsPrimary = true;
			role.Role = 'Champion';
			insert role;
		

		
		
	}

	
	
}