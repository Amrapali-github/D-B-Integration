@isTest
public class DNBControllerIntegrationTests {
	
    @TestSetup
    public static void setupTestData(){        
        DNB_API_Token__c searchTokenStorage = new DNB_API_Token__c();
        searchTokenStorage.name = 'DNB_Dev_Search_Token';
        Insert searchTokenStorage;
        
        DNB_API_Token__c dataBlocksTokenStorage = new DNB_API_Token__c();
        dataBlocksTokenStorage.name = 'DNB_Dev_DataBlocks_Token';
        Insert dataBlocksTokenStorage;
        
        DNBMonitoringSettings__c monitoringSettings = new DNBMonitoringSettings__c();
        monitoringSettings.name = 'DNB_Dev_Monitoring';
        monitoringSettings.Registration_Number__c  = 'CloudreachRegistrationDev';
        monitoringSettings.Maximum_Notifications__c = 100;       
        Insert monitoringSettings;
        
        List<Account> aList = new List<Account>();
        for(integer x = 0;x<25;x=x+4){
            Account a = new Account();
            a.name = 'Account ' + string.valueOf(x);
            a.DUNS_Number__c = string.valueOf(x);
            a.BillingCity = 'London';
            a.BillingCountry = 'UK';
            aList.add(a);
        }
        Account a2 = new Account();
        a2.name = 'Account 217825255';
        a2.DUNS_Number__c = '217825255'; 
        a2.BillingCity = 'London';
        a2.BillingCountry = 'UK';
        aList.add(a2);
        
        Insert aList;
        
        Contact c = new Contact();
        c.lastName = 'test contact';
        c.phone = '5555555555';
        c.AccountId = aList[0].id;
        c.title = 'Dev';
        c.email = 'test@fake.com';
        
        Insert c;
        
        Opportunity o = new Opportunity();
        o.name = 'test';
        o.accountId = aList[0].id;
        o.stageName = 'Prospect';
        o.CloseDate = Date.today();
        o.type = 'New';
        o.Primary_Contact__c = c.id;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CR Sales Process').getRecordTypeId();
        Insert o;
    }
    
    @isTest
    public static void DNBControllerEnrichAccountTest(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        
        controllerExt.dunsParameter = 'test parm1';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('MockDNBSearch2Res');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        controllerExt.getVFCreateAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerEnrichAccountError1Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        
        controllerExt.dunsParameter = 'test parm1';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('DNBErrorRes3');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        controllerExt.getVFCreateAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerEnrichAccountError2Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        
        controllerExt.dunsParameter = 'test parm1';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('DNBErrorRes4');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        controllerExt.getVFCreateAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerEnrichAccountError3Test(){
    	Account a = [SELECT id, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        
        controllerExt.dunsParameter = 'test parm1';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('DNBErrorRes5');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        controllerExt.getVFCreateAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCreateAccountTest(){
    	DNBCustomController controller = new DNBCustomController(); 
        controller.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controller.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        
        controller.dunsParameter = 'test parm1';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('MockDNBSearch2Res');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        for(integer x = 0; x < 25; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
        	controller.searchResults.add(org); 
        }
        
        Test.startTest();
        controller.getVFCreateAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCreateAccountError1Test(){
    	DNBCustomController controller = new DNBCustomController(); 
        controller.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controller.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        
        controller.dunsParameter = 'test parm1';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('DNBErrorRes3');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        for(integer x = 0; x < 25; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
        	controller.searchResults.add(org); 
        }
        
        Test.startTest();
        controller.getVFCreateAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCreateAccountError2Test(){
    	DNBCustomController controller = new DNBCustomController(); 
        controller.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controller.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        
        controller.dunsParameter = 'test parm1';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('DNBErrorRes4');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        for(integer x = 0; x < 25; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
        	controller.searchResults.add(org); 
        }
        
        Test.startTest();
        controller.getVFCreateAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCreateAndAssignAccountTest(){
    	Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        oppController.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        
        oppController.dunsParameter = '4';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('MockDNBSearch2Res');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        for(integer x = 0; x < 25; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
        	oppController.searchResults.add(org); 
        }
        
        Test.startTest();
        oppController.getVFCreateAndAssignAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCreateAndAssignAccountError1Test(){
    	Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        oppController.dunsParameter = '4';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('DNBErrorRes3');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
                
        Test.startTest();
        oppController.getVFCreateAndAssignAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCreateAndAssignAccountError2Test(){
    	Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        oppController.dunsParameter = '4';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('DNBErrorRes4');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
                
        Test.startTest();
        oppController.getVFCreateAndAssignAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerAssignAccountTest(){
    	Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        oppController.dunsParameter = '4';
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('MockDNBSearch2Res');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        oppController.getVFAssignAccountParameter();
        Test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCriteriaSearchTest(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBSearchRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.CriteriaSearchAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCriteriaSearchError1Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        DNBCustomController controller = new DNBCustomController();
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes2');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.CriteriaSearchAPIHandler();
        controller.CriteriaSearchAPIHandler();
        oppController.CriteriaSearchAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCriteriaSearchError2Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        DNBCustomController controller = new DNBCustomController();
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes1');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.CriteriaSearchAPIHandler();
        controller.CriteriaSearchAPIHandler();
        oppController.CriteriaSearchAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCriteriaSearchError3Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        DNBCustomController controller = new DNBCustomController();
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes3');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.CriteriaSearchAPIHandler();
        controller.CriteriaSearchAPIHandler();
        oppController.CriteriaSearchAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCriteriaSearchError4Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        DNBCustomController controller = new DNBCustomController();
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes4');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.CriteriaSearchAPIHandler();
        controller.CriteriaSearchAPIHandler();
        oppController.CriteriaSearchAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCriteriaSearch2Test(){
    	DNBCustomController controller = new DNBCustomController(); 
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBSearchRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controller.CriteriaSearchAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerCriteriaSearch3Test(){
    	Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2); 
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBSearchRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        oppController.CriteriaSearchAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerIdentityResolutionTest(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBSearch3Res');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.IdentityResolutionAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerIdentityResolutionError1Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes1');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.IdentityResolutionAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerIdentityResolutionError2Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes2');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.IdentityResolutionAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerIdentityResolutionError3Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes3');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.IdentityResolutionAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerIdentityResolutionError4Test(){
    	Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes4');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.IdentityResolutionAPIHandler();
        test.stopTest();
    }
    
    @isTest
    public static void DNBControllerNotificationPullHandlerTest(){
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBMockCombinedUpdate');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        DNBMonitoringHandler.NotificationPullHandler();
        test.stopTest(); 
        
        List<DNB_Monitoring_Log__c> logs = [SELECT id, account__c, Account_Field__c, Previous_Value__c, New_Value__c, Timestamp__c, Update_Success__c, Error__c FROM DNB_Monitoring_Log__c];
        system.debug(logs);
    }
    
    @isTest
    public static void DNBControllerNotificationRepullHandlerTest(){
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBMockCombinedUpdate');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        DNBMonitoringHandler.NotificationRepullHandler(-1);
        test.stopTest(); 
        
        List<DNB_Monitoring_Log__c> logs = [SELECT id, account__c, Account_Field__c, Previous_Value__c, New_Value__c, Timestamp__c, Update_Success__c, Error__c FROM DNB_Monitoring_Log__c];
        system.debug(logs);
    }
    
    @isTest
    public static void DNBControllerAddMonitoringAPIError1Test(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        controllerExt.monitoringParameter = '100000';
        
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes6');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.getVFAddMonitoringParameter();
        test.stopTest();    
    }
    
    @isTest
    public static void DNBControllerAddMonitoringAPIError2Test(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        controllerExt.monitoringParameter = '100000';
        
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes4');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.getVFAddMonitoringParameter();
        controllerExt.getVFRemoveMonitoringParameter();
        test.stopTest();    
    }
    
    @isTest
    public static void DNBControllerAddMonitoringAPIError3Test(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc); 
        controllerExt.monitoringParameter = '100000';
        
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBErrorRes7');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        controllerExt.getVFRemoveMonitoringParameter();
        test.stopTest();    
    }
}