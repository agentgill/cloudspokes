/*******************************************************************
 * Custom controller for the "Managing a List of Records" recipe.
 * Manages a list of contact records, holding insert/delete 
 * information in memory until the user chooses to save the changes.
 *******************************************************************/
public with sharing class AceAccountsListEditController 
{
	// wrapper classes for the contacts being managed
	public List<AceAccountWrapper> wrappers {get; set;}
	
	// when a user chooses to add items, the number of
	// items to add will be present in this property
	public Integer addItemCount {get; set;}
	
	// when a user deletes a record, the record key will
	// be present in this property
	public Integer keyToDelete {get; set;}
	
	
	public Integer keyToUpdate {get; set;}
	
	// the unique record key master value
	public Integer mainKey {get; set;}
	
	// the records to delete when the user saves their work
	private List<Accounts__c> toDelete=new List<Accounts__c>();
	
	// constructor
	public AceAccountsListEditController()
	{
		mainKey=1;
		addItemCount=3;
		wrappers=new List<AceAccountWrapper>();
		
		// get the first five contacts from the database to ensure there is some data present on the page
		List<Accounts__c> accounts=[select id, 	Name,
												Account_Designation__c, 
												Account_Title__c, 
												Account_Type__c, 
												Employee__c, 
												Open_Date__c, 
												Reason_for_Addition__c from Accounts__c order by CreatedDate limit 5];
		for (Accounts__c a : accounts)
		{
			wrappers.add(new AceAccountWrapper(mainKey++, a));
		}
	}
	
	// add a number of items to the list
	public PageReference addItems()
	{
		if ( (addItemCount>0) && (addItemCount<10) )
		{
			for (Integer idx=0; idx<addItemCount; idx++)
			{
				wrappers.add(new AceAccountWrapper(mainKey++, new Accounts__c()));
			}
		}
		
		return null;
	}
	
	// remove (delete) an item from the list
	public PageReference removeItem()
	{
		Integer idx=0;
		Boolean found=false;
		for (AceAccountWrapper wrap : wrappers)
		{
			if (wrap.key==keyToDelete)
			{
				found=true;
				if (null!=wrap.acct.id)
				{
					toDelete.add(wrap.acct);
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
			wrappers.remove(idx);
		}
		
		return null;
	}
	
	public PageReference updateAcct(){
		PageReference result=null;
		Integer idx=0;
		Boolean found=false;
		for (AceAccountWrapper wrap : wrappers)
		{
			if (wrap.key==keyToUpdate){
				found=true;
				if (null!=wrap.acct.Id){
			
					result=new PageReference('/apex/AceAccountPage?id='+wrap.acct.id);
					return result.setRedirect(true);
				}
				break;
			}
			
		}
		
		return null;
		
		
	}

	public PageReference insertAcct(){
		PageReference result=null;
		result=Page.AceAccountPage;
		result.setRedirect(true);
		return result;
		
	}
	// save the users work
	public PageReference save()
	{
		PageReference result=null;
		Boolean error=false;
		List<Accounts__c> toUpsert=new List<Accounts__c>();
		
		// make sure that if any data has been entered, the
		// last name is present as this is required
		/*
		for (AceAccountWrapper wrapper : wrappers)
		{
			if ( (!String.IsBlank(wrapper.a.FirstName)) || 
			     (!String.IsBlank(wrapper.a.LastName)) )
			{
				if (String.IsBlank(wrapper.a.LastName))
				{
					wrapper.cont.a.addError('Required');
					error=true;
				}
				else
				{
					toUpsert.add(wrapper.a);
				}
			}
		}
		*/
		
		if (!error)
		{
			delete toDelete;
			//upsert toUpsert;
		
			// return the user to the contacts tab
			result=Page.AceLandingPage;
			result.setRedirect(true);
		}
		
		return result;
	} 
}