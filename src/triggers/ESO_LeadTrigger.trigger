/******************************************************************************
* @author        Mike Gill
* @date          05.11.2013
* @description   CloudSpokes - Early Stage Opportunity (ESO) 

Trigger to call ESO_LeadHandler to create Early Stage Opportunities when Leads
are created with LeadSource of 'Web'

******************************************************************************/

trigger ESO_LeadTrigger on Lead (after insert) {
	
	// Instantiate handler class
	ESO_LeadHandler handler = new ESO_LeadHandler(Trigger.size);
	
	// Call handler
	if (Trigger.isAfter && Trigger.isInsert){
		handler.OnAfterInsert(Trigger.new);
	}

}