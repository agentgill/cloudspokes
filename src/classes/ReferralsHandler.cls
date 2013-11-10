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
	

	
	// the unique record key master value
	public Integer mainKey {get; set;}
	public Integer mainKeyContact {get; set;}
	
	
	// the search text
	public String name {get; set;}
	public String nameContact {get; set;}
	

	
	// the matching accounts
	public List<Account> accounts {get; set;}
	public List<Contact> contacts {get; set;}
	
	// indicator that a search has taken place
	public Boolean searched {get; set;}
	public Boolean searchedContact {get; set;}
	
	// constructor - extracts the search parameter from the URL and, if
	// present, executes a search to find matching accounts
	public ReferralsHandler()
	{
		searched=false;
		searchedContact=false;
		String nameStr=ApexPages.currentPage().getParameters().get('name');
		String nameStrContact=ApexPages.currentPage().getParameters().get('nameContact');
		
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
	
		
	}
	
	public PageReference searchAccounts(){
			
	
		searched=false;
		executeSearch();
		
		
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
				if (null!=wrap.contactReferral.id)
				{
					//toDelete.add(wrap.accountReferral);
				}
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
	
	
	// action method to search for accounts whose name contains the entered
	// text
	public PageReference executeSearch()
	{
		searched=true;
		String searchStr='%' + name + '%';
		accounts=[select id, Name, BillingCity, BillingState, BillingPostalCode from Account where name LIKE :searchStr];
		
		return null;
	}
	
	// action method to search for accounts whose name contains the entered
	// text
	public PageReference executeContactSearch()
	{
		searchedContact=true;
		String searchStr='%' + nameContact + '%';
		contacts=[select Id, FirstName, LastName, Phone, Email, Account.Name from Contact where name Like :searchStr];
		
		return null;
	}
	
	
	
}