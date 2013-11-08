/******************************************************************************
* @author        Mike Gill
* @date          05.11.2013
* @description   CloudSpokes - Early Stage Opportunity (ESO) 

This class implements batchable interface for processing Early stage opportunities
where the LeadSource is not equal to 'Web'

******************************************************************************/

global class ESO_BatchHandler implements 

   Database.Batchable<sObject> {

   global final String query;
   
   
   global ESO_BatchHandler(String q) {
       query = q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
   		
      return Database.getQueryLocator(query);
      
   }
   
   global void execute(Database.BatchableContext BC, List<Lead> scope){
       System.debug('SCOPE = '+scope);
       	// Load helper class
       	ESO_Helper helper = new ESO_Helper();
		Map<String, Object> m = helper.LoadESOConfig();


		// Create empty lists for bulk processing
		List<Lead> leadsToDelete = new List<Lead>();
		List<Opportunity> earlyOppsToCreate = new List<Opportunity>();
		List<OpportunityContactRole> contactRoles = new List<OpportunityContactRole>();
	
		// Interate query scope
		for(Lead l  : scope){
				
				Object fieldValue = '';
				Object fieldName = '';
				Integer count = 1;
				String queryString = 'select Id, Email, AccountId, Account.Name from Contact where ';
				String queryFilters = '';
				
				// Iterate ESO JSON config for matching
	    		for(String name : m.keySet()){
	    		
	    			fieldValue = l.get(name); 
	        		fieldName = m.get(name);
	    				
	    				if (count < m.size()){
	    					
	        				queryFilters += fieldName + ' = \'' + fieldValue + '\' AND ';
	        			
	    				}
	    				else{
	    					queryFilters += fieldName + ' = \'' + fieldValue + '\'  limit 1';
	    	
	    				}
	    				
	    				count++;
	    		}
	    
	    			// Query contact record using lead data
	    			
	    			//String mystring = 'Select Id, FirstName, LastName, AccountId, Account.Name, Email from Contact limit 1';
	    			String myString = queryString+queryFilters;
	    			//System.debug('Contact Query String = '+myString);
	    			List<Contact> c = Database.query(myString);
	    			
	    			// If contact is found start ESO process
	    			if (c.size()==1){
	    				// Add current lead to leads to be deleted list
	    				leadsToDelete.add(new Lead(Id = l.Id));
	    				// Insert Opportunity for found Account/Contact
	    				earlyOppsToCreate.add(new Opportunity (
	    														AccountId = c[0].AccountId,
	    														CloseDate = Date.today(),
																Name = c[0].Account.Name + ':' + l.ProductInterest__c,
																StageName = 'Validate',
																LeadSource = 'Web',
																Description = c[0].Id
	    														)
	    													);
	    				
	    				
	    			}
	    		
			}  	// End leads for processing
			
					// Insert ESO
					insert earlyOppsToCreate;
					
					// Iterate create opps to create contact roles
					for (Opportunity o: earlyOppsToCreate){									
	    					contactRoles.add( new OpportunityContactRole ( OpportunityId = o.Id,
	    																   ContactId =	o.Description,
	    																   IsPrimary = true,
	    																   Role = 'Champion' ) 
	    																);
	    				
	    				}
	    			// Insert contact roles
	    			insert contactRoles;
					
					// finally delete original lead from system
					delete leadsToDelete;
					
                	
      
   }

   global void finish(Database.BatchableContext BC){
   	
   	
   	
   	 AsyncApexJob a = 
           [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC.getJobId()];
                          
       // Send an email to the Apex job's submitter 
       //   notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Record Clean Up Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     
   }
	

}