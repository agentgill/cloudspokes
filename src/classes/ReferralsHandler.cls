/*******************************************************************
 * Custom controller for the "Passing Parameters between Visualforce
 * Pages" recipe.
 * Allows searching for accounts matching submitted text and sending
 * the ids to the edit page.
 *******************************************************************/
public with sharing class ReferralsHandler 
{
	
	// wrapper classes for the companies being referred
	public List<ReferralsWrapper> wrappers {get; set;}
	public List<ReferralsContactWrapper> wrapperscon {get; set;}
	
	// when a user chooses to add items, the number of
	// items to add will be present in this property
	public Integer addItemCount {get; set;}
	public Integer addItemCountContact {get; set;}
	
	// when a user deletes a record, the record key will
	// be present in this property
	public Integer keyToDelete {get; set;}
	public Integer keyToDeleteContact {get; set;}
	
	public String fromAddress {get;set;}
	public String ccAddress {get;set;}
	
	// the unique record key master value
	public Integer mainKey {get; set;}
	public Integer mainKeyContact {get; set;}
	
	
	// the search text
	public String name {get; set;}
	public String nameContact {get; set;}
	
	// previews / email
	public String previewSubject {get;set;}
	public String previewBody {get;set;}
	

	
	// the matching accounts
	public List<Account> accounts {get; set;}
	public List<Contact> contacts {get; set;}
	
	// indicator that a search has taken place
	public Boolean searched {get; set;}
	public Boolean searchedContact {get; set;}
	
	// Add refering account on load
	private List<Account> referredAccount=new List<Account>();
	
	Id oppId = ApexPages.currentPage().getParameters().get('accid');
	Id acctId = ApexPages.currentPage().getParameters().get('acctid');
	
	Account acct;
	
	// constructor - extracts the search parameter from the URL and, if
	// present, executes a search to find matching accounts
	public ReferralsHandler()
	{
		searched=false;
		searchedContact=false;
		String nameStr=ApexPages.currentPage().getParameters().get('name');
		String nameStrContact=ApexPages.currentPage().getParameters().get('nameContact');
		String ccAddress=Apexpages.currentPage().getParameters().get('ccAddress');
		Id acctId = ApexPages.currentPage().getParameters().get('acctid');
		
		
		String userName = Userinfo.getName();
		fromAddress = userName;
		
		// Set preview email defaults
		
			String previewSubjectStr = '{!Account.Name} - Referral from Univeral Containers';
			String previewBodyStr = 'I thought you might be interested at looking into {!Account.Name}';
			previewBody = previewBodyStr;
			previewSubject = previewSubjectStr;
		

		
		if (null!=nameStr)
		{
			name=nameStr;
			executeSearch();
		}
		

		if (null!=nameStrContact)
		{
			nameContact=nameStrContact;
			executeContactSearch();
		}
		
		
		
		// Define wrapper variables
		mainKey=1;
		mainKeyContact=1;
		addItemCount=1;
		addItemCountContact=1;
		wrappers=new List<ReferralsWrapper>();
		wrapperscon=new List<ReferralsContactWrapper>();
		
		/*
		
		
		*/
	}
	
	public PageReference addAccount(){
		
		

		if (acctId!=null){
			acct = [select Name, BillingCity, BillingState, BillingPostalCode from Account where Id =:acctId Limit 1];
			System.debug('debug'+acct.Name);
		}
		
		if (acctId!=null){
			wrappers.add(new ReferralsWrapper(0, new Account(Id = acct.Id, 
																			Name = acct.Name,
																			BillingCity = acct.BillingCity,
																			BillingState = acct.BillingState,
																			BillingPostalCode = acct.BillingPostalCode )));
																			
																			
																		
																			
			searched=false;
			executeSearch();
		}
		return null;
	}
	
	public PageReference searchAccounts(){
			
	
		searched=false;
		executeSearch();
		
		if (accounts.size()!=null){
			
				
			
		if ( (addItemCount>0) && (addItemCount<10) )
		{
			for (Integer idx=0; idx<addItemCount; idx++)
			{
			
				wrappers.add(new ReferralsWrapper(mainKey++, new Account(Id = accounts[idx].Id, 
																		Name = accounts[idx].Name,
																		BillingCity = accounts[idx].BillingCity,
																		BillingState = accounts[idx].BillingState,
																		BillingPostalCode = accounts[idx].BillingPostalCode )));
			
			}
		}
		}
		return null;
		
	}
	
	public PageReference searchContacts(){

		searchedContact=false;
		executeContactSearch();
		
		
		if ( (addItemCountContact>0) && (addItemCountContact<10) )
		{
			for (Integer idx=0; idx<addItemCountContact; idx++)
			{
				System.debug('debug'+contacts[idx].Id);
				wrapperscon.add(new ReferralsContactWrapper(mainKeyContact++, new Contact(	
																					Id = contacts[idx].Id,
																					FirstName = contacts[idx].FirstName,	 
																					LastName = contacts[idx].LastName,
																					Phone = contacts[idx].Phone,
																					Email = contacts[idx].Email
																					)));
			
			}
		}
		
		return null;
		
	}
	
	public PageReference removeItem()
	{
		Integer idx=0;
		Boolean found=false;
		for (ReferralsWrapper wrap : wrappers)
		{
			if (wrap.key==keyToDelete)
			{
				found=true;
				break;
			}
			else
			{
				idx++;
			}
		}
		
		if (found)
		{
			wrappers.remove(idx);
		}
		
		return null;
	}
	
	public PageReference removeContactItem()
	{
		Integer idx=0;
		Boolean found=false;
		for (ReferralsContactWrapper wrap : wrapperscon)
		{
			if (wrap.cKey==keyToDeleteContact)
			{
				found=true;
				break;
			}
			else
			{
				idx++;
			}
		}
		
		if (found)
		{
			wrapperscon.remove(idx);
		}
		
		return null;
	}
	
	//TODO: Update to use SOSL
	// action method to search for accounts whose name contains the entered
	public PageReference executeSearch()
	{
		searched=true;
		String searchStr='%' + name + '%';
		accounts=[select id, Name, BillingCity, BillingState, BillingPostalCode from Account where name LIKE :searchStr];
		
		return null;
	}
	
	//TODO: Update to use SOSL
	// action method to search for accounts whose name contains the entered
	public PageReference executeContactSearch()
	{
		searchedContact=true;
		String searchStr='%' + nameContact + '%';
		contacts=[select Id, FirstName, LastName, Phone, Email, Account.Name from Contact where name Like :searchStr];
		
		return null;
	}
	
	public PageReference save(){
		
		System.debug('debug companies selected is'+wrappers.size() + wrappers);
		System.debug('debug contacts selected is '+wrapperscon.size() + wrapperscon);
		
		return null;
	}
	
		public PageReference cancel(){
			
			PageReference result=new PageReference('/'+acctId);
					return result.setRedirect(true);
		return null;
	}
	
	
	
}