/**
    Test class covering code coverage for AssetHierarchicalRelatedListCtr class 
 */
@isTest
private class AssetHierarchicalRelatedListCtrTest {
    
    static Account acc;
    static Asset rootA, rootB, rootC, childA1, childA2, childB1, childB2, subChildA1_1, subChildB2_1;
    
    /*  
        Method for creating test data used in test method.
        Data Asset Hierrachy 
        -> Root Asset A 
            -> Child Asset A1
                -> Sub Child Asset A1.1
            -> Child Asset A2
        -> Root Asset B
            -> Child Asset B1
            -> Child Asset B2
                -> -> Sub Child Asset B2.1
        -> Root Asset C
        
    */
    static void initTestData() {
        acc = new Account(Name='Test Account008');
        insert acc;
        
        Contact contact1 = new Contact(Firstname = 'sfdcdev', LastName = 'Appirio', AccountId = acc.Id);
        Contact contact2 = new Contact(Firstname = 'sfdcdev2', LastName = 'Appirio', AccountId = acc.Id);
        insert new List<Contact>{contact1, contact2}; 
        
        rootA = new Asset(Name = 'Root Asset A', External_ID__c = 'ROOT-A', AccountId = acc.Id, Status = 'Registered', InstallDate = system.today().addDays(-4), ContactId = contact1.Id);
        rootB = new Asset(Name = 'Root Asset B', External_ID__c = 'ROOT-B', AccountId = acc.Id, Status = 'Installed', InstallDate = system.today().addDays(-2), ContactId = contact1.Id);
        rootC = new Asset(Name = 'Root Asset C', External_ID__c = 'ROOT-C', AccountId = acc.Id, Status = 'Registered', InstallDate = system.today().addDays(-1), ContactId = contact2.Id);
        
        childA1 = new Asset(Name = 'Child Asset A1', External_ID__c = 'CHILD-A1', Parent_ID__c = 'ROOT-A', Root_ID__c = 'ROOT-A', AccountId = acc.Id, Status = 'Registered', InstallDate = system.today().addDays(-4), ContactId = contact1.Id);
        childA2 = new Asset(Name = 'Child Asset A2', External_ID__c = 'CHILD-A2', Parent_ID__c = 'ROOT-A', Root_ID__c = 'ROOT-A', AccountId = acc.Id, Status = 'Installed', InstallDate = system.today().addDays(-3), ContactId = contact2.Id);
        
        childB1 = new Asset(Name = 'Child Asset B1', External_ID__c = 'CHILD-B1', Parent_ID__c = 'ROOT-B', Root_ID__c = 'ROOT-B', AccountId = acc.Id, Status = 'Installed', InstallDate = system.today().addDays(-4), ContactId = contact1.Id);
        childB2 = new Asset(Name = 'Child Asset B1', External_ID__c = 'CHILD-B2', Parent_ID__c = 'ROOT-B', Root_ID__c = 'ROOT-B', AccountId = acc.Id, Status = 'Registered', InstallDate = system.today().addDays(-2), ContactId = contact2.Id);
        
        subChildA1_1 = new Asset(Name = 'Sub Child Asset A1.1', External_ID__c = 'SUB-CHILD-A1.1', Parent_ID__c = 'CHILD-A1', Root_ID__c = 'ROOT-A', AccountId = acc.Id, Status = 'Registered', InstallDate = system.today().addDays(-1), ContactId = contact1.Id);
        subChildB2_1 = new Asset(Name = 'Sub Child Asset B2.1', External_ID__c = 'SUB-CHILD-B2.1', Parent_ID__c = 'CHILD-B2', Root_ID__c = 'ROOT-B', AccountId = acc.Id, Status = 'Installed', InstallDate = system.today().addDays(-1), ContactId = contact1.Id);
        
        insert new List<Asset> {rootA, rootB, rootC, childA1, childA2, childB1, childB2, subChildA1_1, subChildB2_1};
    }
    
    /*
        Basic test. Calling cunstractor with account id set in page context.
    */
    static testMethod void standarControllerTest() {
        initTestData();

        Test.setCurrentPage(Page.AssetHierarchicalRelatedList);
        Apexpages.currentPage().getParameters().put('Id', acc.Id);
        
        Test.startTest();
        AssetHierarchicalRelatedListCtr controller = new AssetHierarchicalRelatedListCtr(new ApexPages.Standardcontroller(acc));
        
        System.assertEquals(acc.Id, controller.selectedAccountId);
        
        Test.stopTest();
    }
    
    /*
        getAssetHierarchyData method test.
    */
    static testMethod void getAssetHierarchyDataTest1() {
        initTestData();

        Test.setCurrentPage(Page.AssetHierarchicalRelatedList);
        Apexpages.currentPage().getParameters().put('Id', acc.Id);
        
        Test.startTest();
        AssetHierarchicalRelatedListCtr controller = new AssetHierarchicalRelatedListCtr(new ApexPages.Standardcontroller(acc));
        
        System.assertEquals(acc.Id, controller.selectedAccountId);
        
        List<AssetHierarchicalRelatedListCtr.AssetWrapper> assetWrapperList = AssetHierarchicalRelatedListCtr.getAssetHierarchyData(acc.Id);
        
        System.assert(!assetWrapperList.isEmpty(), 'Returned assetWrapperList will not be empty');
        
        // Top or root asset count will be equals to three i.e  rootA, rootB and rootC
        System.assertEquals(3, assetWrapperList.size());
        
        System.assertEquals('Root Asset A', assetWrapperList.get(0).Name);
        
        System.assert(!assetWrapperList.get(0).children.isEmpty(), 'Root Asset A child are not empty.');
        
        // Root asset A had 2 child childA1 and childA2
        System.assertEquals(2, assetWrapperList.get(0).children.size());
        
        Test.stopTest();
    }
    
    /*
        getAssetHierarchyData method test with acc id argument as null.
    */
    static testMethod void getAssetHierarchyDataTest2() {
        initTestData();

        Test.setCurrentPage(Page.AssetHierarchicalRelatedList);
        Apexpages.currentPage().getParameters().put('Id', acc.Id);
        
        Test.startTest();
        AssetHierarchicalRelatedListCtr controller = new AssetHierarchicalRelatedListCtr(new ApexPages.Standardcontroller(acc));
        
        System.assertEquals(acc.Id, controller.selectedAccountId);
        try {
            
            List<AssetHierarchicalRelatedListCtr.AssetWrapper> assetWrapperList = AssetHierarchicalRelatedListCtr.getAssetHierarchyData(null);
            
            System.assert(false, 'Expecting exception while calling getAssetHierarchyData with null account id');
        } catch(AssetHierarchicalRelatedListCtr.AssetHierarchyRelatedListException e) {
            
            System.assert(true, 'Expecting exception while calling getAssetHierarchyData with null account id');
        }
        
        Test.stopTest();
    }
}