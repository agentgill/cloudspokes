public with sharing class ReferralsContactWrapper {
	
	public Integer cKey {get; set;}
	
	public Contact contactReferral {get; set;}

	//Recipients Wrapper
	public ReferralsContactWrapper(Integer inKeyCon, Contact inReferralCon)
	{
		cKey=inKeyCon;
		contactReferral=inReferralCon;
	}
	

}