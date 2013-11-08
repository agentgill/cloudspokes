public with sharing class AceAccountWrapper {
	
	public Integer key {get; set;}
	public Accounts__c acct {get; set;}
		
	public AceAccountWrapper(Integer inKey, Accounts__c inAcct)
	{
		key=inKey;
		acct=inAcct;
	}

}