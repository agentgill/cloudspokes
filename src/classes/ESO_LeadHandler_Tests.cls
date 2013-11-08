@isTest
private class ESO_LeadHandler_Tests {

	static {
		
		ESO_Config__c ESO_Config = new ESO_Config__c();
		ESO_Config.Name = 'Web';
		ESO_Config.ESO_Config__c = ' {"FirstName" : "FirstName", "LastName" : "LastName", "Company" : "Account.Name", "Email" : "Email" } ';
		ESO_Config.ESO_Lead_Query__c = 'select FirstName, LastName, Company, Email, ProductInterest__c from Lead where LeadSource != \'Web\'';
        insert 	ESO_Config;
		
		Account a = new Account();
		a.Name = 'Test Company';
		insert a;
	
        Contact c = new Contact();
		c.FirstName = 'Test First';
		c.LastName = 'Test Last';
		c.AccountId = a.Id;
		c.Email = 'mike@cloudava.com';
		insert c;
		//System.debug(c);

		
	}
	
	static testmethod void test_Web(){
		
		Lead lead = new Lead();
		lead.FirstName = 'Test First';
		lead.LastName = 'Test Last';
		lead.Email = 'mike@cloudava.com';
		lead.Company = 'Test Company';
		lead.ProductInterest__c = 'Test';
		lead.LeadSource = 'Web';
		
		Test.startTest();
			insert lead;
        
		Test.stopTest();
		
	}

    static testmethod void test_Bulk() {
    	
    	List<Lead> testLeads = new List<Lead>();
		
		for (Integer i = 0; i < 100; i++){
			Lead l = new Lead();
			l.FirstName = 'Test First';
			l.LastName = 'Test Last';
			l.Email = 'mike@cloudava.com';
			l.Company = 'Test Company';
			l.ProductInterest__c = 'Test';
			l.LeadSource = 'Other';
			testLeads.add(l);
		}
		insert testLeads;
	
    	
        ESO_Config__c config = [select ESO_Lead_Query__c from ESO_Config__c limit 1];
		String leadQuery = config.ESO_Lead_Query__c;
    
     	Test.startTest();
     
     	System.assertEquals(testLeads.size(), 100); 
 		ESO_BatchHandler c = new ESO_BatchHandler(leadQuery);
		Database.executeBatch(c);
	   	Test.stopTest();
     
    }
}