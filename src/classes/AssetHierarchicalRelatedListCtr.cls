/*
    Global class holiding logic for preparing the asset hierarchy JSON object used to prepare 
    tree view grid on UI.
*/
global class AssetHierarchicalRelatedListCtr {
    
    // Record load limit variable. Setting limit as 1000. Though it can be increated to higher as data is retervied 
    // using js remoting so no issue of hitting <apex:repeat> limit. 
    static final Integer RECORD_LOAD_LIMIT = 1000;
    
    // selected account record if for which assets will be loaded.
    public String selectedAccountId {get; private set;}
    
    public AssetHierarchicalRelatedListCtr(ApexPages.StandardController con) {
        this();
    }
    
    public AssetHierarchicalRelatedListCtr() {
        selectedAccountId = Apexpages.currentPage().getParameters().get('id');
    }
    
    /*
        Global method holding logic for preparing asset hierarchical data to shown UI. This method is call as 
        js remoting call.  
    */
    @RemoteAction 
    global static List<AssetWrapper> getAssetHierarchyData(String accId) {
        
        // If accId is missing i.e blank throw exception to display on UI.
        if(String.isBlank(accId)) {
            throw new AssetHierarchyRelatedListException('No account selected.');
        }
        
        List<AssetWrapper> assetWrapperList = new List<AssetWrapper>(); 
        try {
            // Quering all top root node assets i.e Root_ID__c and Parent_ID__c equals to null.
            List<Asset> rootAssets = [Select Status, SerialNumber, Root_ID__c, Quantity, Price, Parent_ID__c, Name, Id, External_ID__c,
                         Description, AccountId, IsCompetitorProduct, InstallDate, Contact.Name, ContactId From Asset where 
                         AccountId =: accId /*and Root_ID__c = null*/ and Parent_ID__c = null order by Name limit : RECORD_LOAD_LIMIT];
            
            // Quering all Assets except parent Assets i.e Asset record for which Root_ID__c  and Parent_ID__c lookup is not null. 
            List<Asset> childAssets = [Select Status, SerialNumber, Root_ID__c, Quantity, Price, Parent_ID__c, Name, Id, External_ID__c,
                         Description, AccountId, IsCompetitorProduct, InstallDate, Contact.Name, ContactId From Asset where 
                         AccountId =: accId and Root_ID__c != null and Parent_ID__c != null order by Name limit : RECORD_LOAD_LIMIT];
            
            // Preparing map for child assets. 
            Map<String, List<Asset>> childAssetMap = prepareAssetHierarchyMap(childAssets);                  
            
            for(Asset asset : rootAssets) {
                AssetWrapper assetWrapper = new AssetWrapper(asset, childAssetMap.containsKey(asset.External_ID__c));
                
                // Call method for processing child Asset records.
                processChildAssets(assetWrapper, childAssetMap);
                assetWrapperList.add(assetWrapper);
            }
        } 
        catch(Exception e) { throw new AssetHierarchyRelatedListException('Exception while preparing asset hierarchy data for the selected account. Error: '+ e.getMessage()); }

        return assetWrapperList;    
    }
    
    // Custom exception class for asset related list exception.
    global class AssetHierarchyRelatedListException extends Exception {}
    
    /*
        Method for processing the child asset records. This method is called recurservely to process all children 
        assocated with passed parent asset.
    */
    public static void processChildAssets(AssetWrapper parentAssetWrapper, Map<String, List<Asset>> childAssetMap) {
        
        if(parentAssetWrapper != null && parentAssetWrapper.id != null && parentAssetWrapper.externalId != null && childAssetMap != null) {
            
            // getting all child asserts associated with this parent assert. 
            List<Asset> childAssets = childAssetMap.get(parentAssetWrapper.externalId);
            
            if(childAssets != null && !childAssets.isEmpty()) {
                
                for(Asset asset : childAssets) {
                    AssetWrapper assetWr = new AssetWrapper(asset, childAssetMap.containsKey(asset.External_ID__c));
            
                    // Call method for processing child product records.
                    processChildAssets(assetWr, childAssetMap);
                    
                    // Adding the Product2 wrapper as child to the parent product wrapper.
                    parentAssetWrapper.addChild(assetWr);
                }
            }
        }
    }
    
    /*
        Method for preparing list of children asset mapped with there parent asset using the Parent_ID__c custom field on asset. 
    */
    public static Map<String, List<Asset>> prepareAssetHierarchyMap(List<Asset> assets) {
        
        Map<String, List<Asset>> childAssetMap = new Map<String, List<Asset>>();
        
        for(Asset asset : assets) {
            
            if(asset.Parent_ID__c != null) {
                List<Asset> childAssets = childAssetMap.get(asset.Parent_ID__c);
                if(childAssets == null) {
                    childAssets = new List<Asset>();
                    childAssetMap.put(asset.Parent_ID__c, childAssets);
                }
                childAssets.add(asset);
            }
        }
        return childAssetMap;
    }
    
    /*
        Wrapper class holding asset details to display on UI. 
    */
    global class AssetWrapper {
        public String id {get;set;}
        public String externalId {get;set;}
        public String name {get;set;}
        
        // Field/column to display as asset grid
        public String serialNumber {get;set;}
        public String installDate {get;set;}
        public Decimal Quantity {get;set;}
        public String contactName {get;set;}
        public String Status {get;set;}
        public boolean isCompetitorAsset {get;set;}
        
        public List<AssetWrapper> children {get;set;}
        
        //public String state {get { return (children.isEmpty() ? 'open' : state);} private set;} // Possible value as "closed" and "open"
        public String state {get; private set;}
        
        public AssetWrapper(Asset asset, boolean state) {
            this.id = asset.Id;
            this.externalId = asset.External_ID__c;
            this.name = asset.name;
            this.serialNumber = asset.serialNumber;
            this.installDate = asset.InstallDate != null ? asset.InstallDate.month()+'/'+ asset.InstallDate.day()+'/'+ asset.InstallDate.year() : '';
            this.Quantity = asset.Quantity;
            this.contactName = asset.ContactId != null ? asset.Contact.Name : '';
            this.status = asset.status;
            this.isCompetitorAsset = asset.IsCompetitorProduct;
            
            this.children = new List<AssetWrapper>();
            
            this.state = state ? 'closed' : 'open';
        }
        
        public void addChild(AssetWrapper child) {
            this.children.add(child);
        }
    }
    
}