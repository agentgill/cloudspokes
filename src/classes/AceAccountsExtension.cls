public with sharing class AceAccountsExtension {
	
	// the Lead standard controller being extended 
	private ApexPages.StandardController stdCtrl {get; set;}
	
	// indicator that an error occurred
	public Boolean error {get; set;}
	
	// the error message
	public String errorMsg {get; set;}
	
	// contstructor
	public AceAccountsExtension(ApexPages.StandardController std)
	{
		stdCtrl=std;
		error=false; 
	}
	
	// action method to validate the input and save the lead
	public PageReference save()
	{ 
		PageReference pr=null;
		Date dtToday = date.today();
		 
		errorMsg='';
		error=false;
		Accounts__c acct=(Accounts__c) stdCtrl.getRecord();
		if ( 	 
			
		 		(String.isEmpty(acct.Name)) || 
				(String.isEmpty(acct.Account_Title__c)) ||
				(String.isEmpty(acct.Account_Designation__c)) ||
				(String.isEmpty(acct.Reason_for_addition__c)) ||
				(String.isEmpty(acct.Account_type__c))
			  )
		{
		
			errorMsg='Please enter all required fields';
			error=true;
		}
		else if (acct.Open_Date__c == null || acct.Open_Date__c >  dtToday){
			errorMsg='Open date must be equal or before today';
			error=true;
			
		}
		else
		{
			try
			{
				Employee__c emp = [select Id, Name, Employee_Name__c from Employee__c where Employee_Name__c =: UserInfo.getUserId()];
				acct.Employee__c = emp.Id;
				upsert acct;
				pr=Page.AceAccountListPage;
				pr.setRedirect(true);
			}
			catch (Exception e)
			{
				
				errorMsg='An error has occurred: ' + e.getMessage();
				error=true;
			}
		}
		return pr;
	}
	
	public PageReference cancel(){
		PageReference pr=null;
		pr=Page.AceAccountListPage;
		pr.setRedirect(true);
		return pr;
		
	}

}