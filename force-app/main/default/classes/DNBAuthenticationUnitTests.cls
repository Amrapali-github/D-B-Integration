@isTest
public class DNBAuthenticationUnitTests {
	
    @isTest(SeeAllData=True)
    public static void AuthHandlerConstructionTest(){        
        DNBAuthenticationHandler handler = new DNBAuthenticationHandler();
        System.assert(handler.env != null);
        System.assert(handler.searchTokenStorage != null);
        System.assert(handler.dataBlocksTokenStorage != null);
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerGetEnvironmentTest(){        
        String env = DNBAuthenticationHandler.getEnvironment();
        
        if(URL.getSalesforceBaseUrl().toExternalForm() == 'https://cloudreach.lightning.force.com'){
            System.assert(env == 'Prod');
        }
        else{
            System.assert(env == 'Dev');
        }
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerGetSearchTokenStorageTest(){        
    	DNB_API_Token__c token = DNBAuthenticationHandler.getSearchTokenStorage();
        
        if(URL.getSalesforceBaseUrl().toExternalForm() == 'https://cloudreach.lightning.force.com'){
            System.Assert(token.name == 'DNB_Prod_Search_Token');
        }
        else{
            System.Assert(token.name == 'DNB_Dev_Search_Token');
        }        
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerGetDataBlocksTokenStorageTest(){        
    	DNB_API_Token__c token = DNBAuthenticationHandler.getDataBlocksTokenStorage();
        
        if(URL.getSalesforceBaseUrl().toExternalForm() == 'https://cloudreach.lightning.force.com'){
            System.Assert(token.name == 'DNB_Prod_DataBlocks_Token');
        }
        else{
            System.Assert(token.name == 'DNB_Dev_DataBlocks_Token');
        }        
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerGenerateAuthenticationSearchTokenTest(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBTokenRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        DNB_API_Token__c token = DNBAuthenticationHandler.getSearchTokenStorage();
        
        System.assert(token.token__c != '8pO6X4zVzVE8R324a30VKr8t6111');
        
        test.startTest();
        DNBAuthenticationHandler.GenerateSearchAuthenticationToken();      
        test.stopTest();
        
        token = DNBAuthenticationHandler.getSearchTokenStorage();
        
        System.assert(token.token__c == '8pO6X4zVzVE8R324a30VKr8t6111');
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerGenerateAuthenticationDataBlocksTokenTest(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBTokenRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        DNB_API_Token__c token = DNBAuthenticationHandler.getDataBlocksTokenStorage();
        
        System.assert(token.token__c != '8pO6X4zVzVE8R324a30VKr8t6111');
        
        test.startTest();
        DNBAuthenticationHandler.GenerateDataBlocksAuthenticationToken();      
        test.stopTest();
        
        token = DNBAuthenticationHandler.getDataBlocksTokenStorage();
        
        System.assert(token.token__c == '8pO6X4zVzVE8R324a30VKr8t6111');
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerRefreshSearchTokenTest(){
        
        DNBAuthenticationHandler handler = new DNBAuthenticationHandler();
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBTokenRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        DNB_API_Token__c token = DNBAuthenticationHandler.getSearchTokenStorage();
        
        System.assert(token.token__c != '8pO6X4zVzVE8R324a30VKr8t6111');
        
        test.startTest();
        handler.RefreshSearchAuthenticationToken();     
        test.stopTest();
        
        token = DNBAuthenticationHandler.getSearchTokenStorage();
        
        System.assert(token.token__c == '8pO6X4zVzVE8R324a30VKr8t6111');
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerRefreshDataBlocksTokenTest(){
        
        DNBAuthenticationHandler handler = new DNBAuthenticationHandler();
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBTokenRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        DNB_API_Token__c token = DNBAuthenticationHandler.getDataBlocksTokenStorage();
        
        System.assert(token.token__c != '8pO6X4zVzVE8R324a30VKr8t6111');
        
        test.startTest();
        handler.RefreshDataBlocksAuthenticationToken();     
        test.stopTest();
        
        token = DNBAuthenticationHandler.getDataBlocksTokenStorage();
        
        System.assert(token.token__c == '8pO6X4zVzVE8R324a30VKr8t6111');
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerRetrieveSearchTokenTest(){
    	DNBAuthenticationHandler handler = new DNBAuthenticationHandler();
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBTokenRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        String token = DNBAuthenticationHandler.RetrieveSearchAuthenticationToken();
        System.assert(token != '8pO6X4zVzVE8R324a30VKr8t6111');
        
        test.startTest();
        handler.RefreshSearchAuthenticationToken();     
        test.stopTest();
        
        handler = new DNBAuthenticationHandler();
        token = DNBAuthenticationHandler.RetrieveSearchAuthenticationToken();
        System.assert(token == '8pO6X4zVzVE8R324a30VKr8t6111');
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerRetrieveDataBlocksTokenTest(){
    	DNBAuthenticationHandler handler = new DNBAuthenticationHandler();
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBTokenRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        String token = DNBAuthenticationHandler.RetrieveDataBlocksAuthenticationToken();
        System.assert(token != '8pO6X4zVzVE8R324a30VKr8t6111');
        
        test.startTest();
        handler.RefreshDataBlocksAuthenticationToken();     
        test.stopTest();
        
        handler = new DNBAuthenticationHandler();
        token = DNBAuthenticationHandler.RetrieveDataBlocksAuthenticationToken();
        System.assert(token == '8pO6X4zVzVE8R324a30VKr8t6111');
    }
    
    @isTest(SeeAllData=True)
    public static void AuthHandlerScheduleTest() {
    	DNBAuthenticationHandler handler = new DNBAuthenticationHandler();
    	String jobId = System.schedule('myJobTestJobName', '0 0 12 * * ?', handler);
    }
}