public with sharing class ReferralsWrapper {
	
	public Integer key {get; set;}
	
	public Account accountReferral {get; set;}

		
	public ReferralsWrapper(Integer inKey, Account inReferral)
	{
		key=inKey;
		accountReferral=inReferral;
	}


}