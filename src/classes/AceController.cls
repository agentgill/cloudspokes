public with sharing class AceController {
	
	public AceController(){}
	
	//public boolean stepOne {get;set; }
	
	public boolean stepTwoOpen {get;set; }

	public boolean stepThreeOpen {get;set;}
	
	public boolean CheckCerts {get;set;}
	
	public Date myDate = Date.today();

	public Id empId {get;set;}
	
	public PageReference start()
	{ 
		PageReference pr=null;		
		pr=Page.AceAccountListPage;
		pr.setRedirect(true);
	
		return pr;
	}
	
	public PageReference exit(){
	
		PageReference pr=null;				
		pr=new PageReference('/home/home.jsp?sdtd=1');
		pr.setRedirect(true);
	
		return pr;
	}
	
	
	public void CheckAccounts(){
		List<Accounts__c> a = [select Id, Name, Employee__c from Accounts__c where Employee__r.Employee_Name__c =: UserInfo.getUserId()  and LastModifiedDate =: myDate];
		if (a.size()>0){
			stepTwoOpen = true;
		}
		
	}
	
	public void CheckHoldings(){
		
		List<Security_Holding__c> h = [select Id from Security_Holding__c where Employee__r.Employee_Name__c =: UserInfo.getUserId() and LastModifiedDate =: myDate];
		if (h.size()>0){
			stepTwoOpen = true;
		}
	}
	
	public void CheckCerts(){
		
		List<Certification__c> c = [select Id from Certification__c where Employee__r.Employee_Name__c =: UserInfo.getUserId() and LastModifiedDate =: myDate];
		if (c.size()>0){
			stepTwoOpen = true;
		}
	}
	
	
	
	

}