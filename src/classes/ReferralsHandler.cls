/*******************************************************************
 * Custom controller for the "Passing Parameters between Visualforce
 * Pages" recipe.
 * Allows searching for accounts matching submitted text and sending
 * the ids to the edit page.
 *******************************************************************/
public with sharing class ReferralsHandler 
{
	
		// wrapper classes for the contacts being managed
	public List<ReferralsWrapper> wrappers {get; set;}
	
	// when a user chooses to add items, the number of
	// items to add will be present in this property
	public Integer addItemCount {get; set;}
	
	// when a user deletes a record, the record key will
	// be present in this property
	public Integer keyToDelete {get; set;}
	
	// the unique record key master value
	public Integer mainKey {get; set;}
	
	
	// the search text
	public String name {get; set;}
	
	// the matching accounts
	public List<Account> accounts {get; set;}
	
	// indicator that a search has taken place
	public Boolean searched {get; set;}
	
	// constructor - extracts the search parameter from the URL and, if
	// present, executes a search to find matching accounts
	public ReferralsHandler()
	{
		searched=false;
		String nameStr=ApexPages.currentPage().getParameters().get('name');
		if (null!=nameStr)
		{
			name=nameStr;
			executeSearch();
		}
		
		
		// Define wrapper variables
		mainKey=1;
		addItemCount=1;
		wrappers=new List<ReferralsWrapper>();
		
		List<Account> acc = [select Name from Account limit 1];
		
		for (Account a : acc)
		{
			wrappers.add(new ReferralsWrapper(mainKey++, a)); 
		}
		
		
	}
	
	public PageReference addAccounts(){
		

		
		//Account acct = [select Id, Name from Account];
		
		executeSearch();
		
		
		if ( (addItemCount>0) && (addItemCount<10) )
		{
			for (Integer idx=0; idx<addItemCount; idx++)
			{
			
				wrappers.add(new ReferralsWrapper(mainKey++, new Account(Id = accounts[idx].Id, Name = accounts[idx].Name )));
			
			}
		}
		
		return null;
		
	}
	
	// action method to search for accounts whose name contains the entered
	// text
	public PageReference executeSearch()
	{
		searched=true;
		String searchStr='%' + name + '%';
		accounts=[select id, Name, Industry, Type from Account where name LIKE :searchStr];
		
		return null;
	}
	
	// action method to allow editing of the matching accounts - redirects the user to the
	// EditFromSearch page and passes the account ids as parameters on the URL
	public PageReference edit()
	{
		PageReference pr=Page.ReferralsPage;
		Integer idx=1;
		for (Account acc : accounts)
		{
			pr.getParameters().put('account' + idx, acc.id);
			idx++;
		}
		
		return pr;
	}
}