/******************************************************************************
* @author        Mike Gill
* @date          05.11.2013
* @description   CloudSpokes - Early Stage Opportunity (ESO) 

This class implements Schedulable interface for calling batch class


******************************************************************************/

global class ESO_Scheduler implements Schedulable {
   global void execute(SchedulableContext ctx) {

		
		//String leadQuery = 'select Id, FirstName, LastName, Email, Company, ProductInterest__c from Lead where LeadSource = \'Web\'';
       	
       	ESO_Config__c config = [select ESO_Lead_Query__c from ESO_Config__c limit 1];
		String leadQuery = config.ESO_Lead_Query__c;
       
       
        // Execute batch           
      	ESO_BatchHandler c = new ESO_BatchHandler(leadQuery);
      	Database.executeBatch(c, 100);
   }   

      
}