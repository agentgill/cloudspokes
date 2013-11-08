@isTest
private class AceTestUtil {

	public static Id userId;
	public List<User> users {get; set;}
	static AceAccountsExtension ext;
    
      public void createTestUsers(){

		users = new List<User>();

		Profile p = [select id from Profile where name = 'Standard User'];
			
     	// Create user for tetsing
     	User u = new User ( alias = 'testme', 
                           	email = 'testme@noemail.com', 
                           	emailencodingkey = 'UTF-8', 
                           	lastname = 'test',
                           	languagelocalekey = 'en_US', 
     						localesidkey = 'en_US', 
                           	profileid = p.Id, 
                           	country = 'United Kingdom', 
                           	timezonesidkey = 'Europe/London', 
                           	username = 'testme@noemail.com');
     	users.add(u);
        
        
    
        
        
        
     	insert users;
     	userId = users[0].Id;
     	
	}
	
	public static Employee__c createTestEmployees(){
		Employee__c emp = new Employee__c( Employee_Name__c = userId);
		insert emp;
		return emp;
	}
	
	static testMethod void testMyControllerExtension(){
		
		Accounts__c accts = new Accounts__c();
		accts.Account_Designation__c = 'Test';
		accts.Account_Title__c = 'Test';
		accts.Account_Type__c = 'Test';
		accts.Employee__c = userId;
		accts.Name = '1111';
		accts.Open_Date__c = Date.today()-1;
		ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(accts);
        System.assert(con != null);
        ext = new AceAccountsExtension ( con );
        Test.startTest();
        ext.save();
        ext.cancel();
        
        Test.stopTest();
		
	}
	
	static testMethod void testMyListController(){
		
		AceAccountsListEditController cont = new AceAccountsListEditController();
		Test.startTest();
		cont.save();
		cont.updateAcct();
		cont.removeItem();
		cont.addItems();
		cont.insertAcct();
		Test.stopTest();
		
	}
    
		static testMethod void testMyController(){
		
		AceController cont = new AceController();
		Test.startTest();
		cont.exit();
		cont.start();
		Test.stopTest();
		
	}
	    
 
}