/******************************************************************************
* @author        Mike Gill
* @date          05.11.2013
* @description   CloudSpokes - Early Stage Opportunity (ESO) 

Class for Early Stage Opportunity process of Web Leads (not designed for bulk)

******************************************************************************/


public with sharing class ESO_LeadHandler {
	

	// Create constructor
	public ESO_LeadHandler(integer size){}
	
	// Create after insert method
	public void OnAfterInsert(Lead [] newLeads){

		
		ESO_Helper helper = new ESO_Helper();
		Map<String, Object> m = helper.LoadESOConfig();
		
	
		Object fieldValue = '';
		Object fieldName = '';
		String queryFilters = '';
		
		
		String queryString = 'select Id, AccountId, Account.Name, Email, FirstName, LastName from Contact where ';
		Integer count = 1;
		String 	productOfInterest = '';



		for(Lead l  : newLeads){
			
			if (l.LeadSource == 'Web'){
				
				productOfInterest = l.ProductInterest__c;
			
	    		for(String name : m.keySet()){
	    			
	    			fieldValue = l.get(name); 
	        		fieldName = m.get(name);
	    				
	    				if (count < m.size()){
	    					
	        				queryFilters += fieldName + ' = \'' + fieldValue + '\' AND ';
	        				System.debug(queryFilters);
	    				}
	    				else{
	    					queryFilters += fieldName + ' = \'' + fieldValue + '\' limit 1';
	    					System.debug(queryFilters);
	    				}
	    				
	    				count++;
	    		}
	    		
			}
		}
		

		
		List<Lead> leadsToDelete = new List<Lead>();
		
		if (queryFilters!=''){
		
		System.debug(queryString+queryFilters);
	
			
			List<Contact> contacts = Database.query(queryString+queryFilters);
			
			System.debug(contacts.size());
			
			
			
			if (contacts.size()==1){
				
				for (Contact contact: contacts){	
					
					for (Lead l : newLeads){
						System.debug('Lead Id = ' + l.Id);
						leadsToDelete.add(new Lead(Id = l.Id));
					}
				
				}
			
			}	
			
			
			 if (leadsToDelete.size()>0){
			
				delete leadsToDelete;
				helper.CreateOpportunity(contacts, productOfInterest);
			 }
				
			
		
		}
		
	}
	
	

	
	
	

}