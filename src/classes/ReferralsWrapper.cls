public with sharing class ReferralsWrapper {
	
	public Integer key {get; set;}
	public Account referral {get; set;}
		
	public ReferralsWrapper(Integer inKey, Account inReferral)
	{
		key=inKey;
		referral=inReferral;
	}

}