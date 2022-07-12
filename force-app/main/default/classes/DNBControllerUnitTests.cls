@isTest
public class DNBControllerUnitTests {
    
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
        Integer counter = 0;
        for(integer x = 0;x<25;x=x+4){
            Account a = new Account();
            a.name = 'Account ' + string.valueOf(x);           
            a.BillingCity = 'London';
            a.BillingCountry = 'UK';
            if(math.mod(counter,2) == 0){
                a.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cloudamize Customer').getRecordTypeId();
                a.DUNS_Number__c = 'CMZ' + string.valueOf(x);
            }
            else{
                a.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
                a.DUNS_Number__c = string.valueOf(x);
            }
            aList.add(a);
            counter++;
        }
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
        Insert o;
    }
    
    @isTest
    public static void DNBControllerTest() {     
        DNBCustomController controller = new DNBCustomController();
        
        System.assert(controller.authHandler != null);
        System.assert(controller.searchDone == false);
        System.assert(controller.resultsPerPage == 10); 
        System.assert(controller.maximumResultsReturned == 50); 
        System.assert(controller.currentDNBAPIPage == 1);         
    }
    
    @isTest
    public static void DNBControllerExtensionTest() { 
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controller = new DNBControllerExtension(sc);
        
        System.assert(controller.authHandler != null);
        System.assert(controller.searchDone == false);
        System.assert(controller.resultsPerPage == 10); 
        System.assert(controller.maximumResultsReturned == 50); 
        System.assert(controller.currentDNBAPIPage == 1);
        System.assert(controller.refreshPage == false);
        System.assert(controller.account != null);
    }
    
    @isTest
    public static void DNBOpportunityControllerExtensionTest() { 
        Opportunity o = [SELECT id, accountId, recordTypeId FROM Opportunity LIMIT 1];        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension controller = new DNBOpportunityControllerExtension(sc);
        
        System.assert(controller.authHandler != null);
        System.assert(controller.searchDone == false);
        System.assert(controller.resultsPerPage == 10); 
        System.assert(controller.maximumResultsReturned == 50); 
        System.assert(controller.currentDNBAPIPage == 1);
        System.assert(controller.refreshPage == false);
        System.assert(controller.opportunity != null);
    }
    
    @isTest
    public static void DNBControllerIdentityResolutionAPITest() {
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controller = new DNBControllerExtension(sc);
                
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBSearchRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        HttpResponse res = controller.IdentityResolutionAPI();
        test.stopTest(); 
        
        system.assert(res.getStatusCode() == 200);
    }
        
    @isTest
    public static void DNBControllerDataBlocksAPITest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('MockDNBSearch2Res');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        HttpResponse res1 = controller.StandardDataBlocksAPI('1000000');
        HttpResponse res2 = controllerExt.StandardDataBlocksAPI('1000000');
        HttpResponse res3 = oppController.StandardDataBlocksAPI('1000000');
        test.stopTest();
        
        system.assert(res1.getStatusCode() == 200);
        system.assert(res2.getStatusCode() == 200);
        system.assert(res3.getStatusCode() == 200);         
    }
    
    @isTest
    public static void DNBControllerParseDataBlockTest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);

        StaticResource sr = [select id,body from StaticResource Where Name = 'DNBDataBlockMockResponse'];
        
        test.startTest();
        DNBAPIDataObjects.DNBOrganization enrichedOrg = controller.parseDataBlocks(sr.body.toString());
        DNBAPIDataObjects.DNBOrganization enrichedOrg2 = controllerExt.parseDataBlocks(sr.body.toString());
        DNBAPIDataObjects.DNBOrganization enrichedOrg3 = oppController.parseDataBlocks(sr.body.toString());
        test.stopTest();
        
        system.assert(enrichedOrg.duns == '744677712');
        system.assert(enrichedOrg.registrationNumbers[0].registrationNumber == '35083688340');
        system.assert(enrichedOrg.countryISOAlpha2Code == 'AU');
        system.assert(enrichedOrg.primaryName == 'TRUSTED CLOUD PTY LIMITED');
        system.assert(enrichedOrg.registeredName == 'TRUSTED CLOUD PTY LIMITED');
        system.assert(enrichedOrg.mailingAddress != null); 
        system.assert(enrichedOrg.primaryAddress.addressCountry.name == 'Australia'); 
        system.assert(enrichedOrg.primaryAddress.addressCountry.isoAlpha2Code == 'AU');
        system.assert(enrichedOrg.primaryAddress.addressLocality.name == 'MOUNT WAVERLEY');
        system.assert(enrichedOrg.primaryAddress.addressRegion.name == 'VICTORIA');
        system.assert(enrichedOrg.primaryAddress.addressRegion.abbreviatedName == 'VIC');
        system.assert(enrichedOrg.primaryAddress.streetAddress.line1 == '366 STEPHENSONS ROAD');
        system.assert(enrichedOrg.primaryAddress.streetAddress.line2 == null);
        system.assert(enrichedOrg.primaryAddress.postalCode == '3149');
        system.assert(enrichedOrg.primaryAddress.streetNumber == null);
        system.assert(enrichedOrg.primaryAddress.streetName == null);
        system.assert(enrichedOrg.primaryAddress.addressCounty.name == 'testName');
        system.assert(enrichedOrg.latestFinancials != null);
        system.assert(enrichedOrg.financials[0].yearlyRevenue[0].value != null);
        system.assert(enrichedOrg.financials[0].yearlyRevenue[0].dnbCurrency == 'AUD');
        system.assert(enrichedOrg.businessTrading != null);
        system.assert(enrichedOrg.dnbAssessment.creditLimitRecommendation.assessmentDate == 'test');
        system.assert(enrichedOrg.dnbAssessment.creditLimitRecommendation.maximumRecommendedLimit.value == 2.3);
        system.assert(enrichedOrg.dnbAssessment.failureScore.classScore == 2);
        system.assert(enrichedOrg.dnbAssessment.failureScore.classScoreDescription == null);
        system.assert(enrichedOrg.dnbAssessment.delinquencyScore.classScore == null);
        system.assert(enrichedOrg.dnbAssessment.delinquencyScore.classScoreDescription == null);
        system.assert(enrichedOrg.dnbAssessment.delinquencyScore.scoreCommentary.description == 'test');
        system.assert(enrichedOrg.dnbAssessment.delinquencyScore.scoreCommentary.dnbCode == 1);
        system.assert(enrichedOrg.corporateLinkage.globalUltimate.duns == '740947049');
        system.assert(enrichedOrg.corporateLinkage.globalUltimate.primaryName == 'TPG CORPORATION LIMITED');
        system.assert(enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.continentalRegion.name == 'Asia Pacific');
        system.assert(enrichedOrg.corporateLinkage.globalUltimate.financials == null);
        system.assert(enrichedOrg.corporateLinkage.domesticUltimate.duns == '740947049');
        system.assert(enrichedOrg.corporateLinkage.domesticUltimate.primaryName == 'TPG CORPORATION LIMITED');
        system.assert(enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.continentalRegion.name == 'Asia Pacific');
        system.assert(enrichedOrg.corporateLinkage.domesticUltimate.financials == null);
        system.assert(enrichedOrg.businessTrading[0].summary[0].paydexScore == 5);
        system.assert(enrichedOrg.telephone[0].telephonenumber == '395199500');
        system.assert(enrichedOrg.telephone[0].isdCode == '61');
        system.assert(enrichedOrg.dnbAssessment.standardRating.scoreDate == '2022-03-07');
        system.assert(enrichedOrg.globalUltimate.numberOfEmployees[0].value != null);
        system.assert(enrichedOrg.industryCodes[0].code == '541512');
        system.assert(enrichedOrg.industryCodes[0].description == 'Computer Systems Design Services');
        system.assert(enrichedOrg.industryCodes[0].typeDescription == 'North American Industry Classification System 2017');
        system.assert(enrichedOrg.industryCodes[0].typeDnBCode == 30832);
        system.assert(enrichedOrg.industryCodes[0].priority == 1);
        
    }
    
    @isTest
    public static void DNBControllerParseSearchResultsTest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);

        StaticResource sr = [select id,body from StaticResource Where Name = 'DNBMockSearchCriteriaRes'];
        String searchResponse = sr.body.toString();
        
        test.startTest();
        List<DNBAPIDataObjects.DNBOrganization> results1 = controller.parseSearchResults(searchResponse,'searchCandidates');
        List<DNBAPIDataObjects.DNBOrganization> results2 = controllerExt.parseSearchResults(searchResponse,'searchCandidates');
        List<DNBAPIDataObjects.DNBOrganization> results3 = oppController.parseSearchResults(searchResponse,'searchCandidates');
        test.stopTest();
        
        system.assert(results1[0].duns == '804735132');
        system.assert(results1[0].primaryName == 'Gorman Manufacturing Company, Inc.');
        system.assert(results1[0].financials[0].yearlyRevenue[0].value == 22589957);
        
        system.assert(results2[0].duns == '804735132');
        system.assert(results2[0].primaryName == 'Gorman Manufacturing Company, Inc.');
        system.assert(results2[0].financials[0].yearlyRevenue[0].value == 22589957);
        
        system.assert(results3[0].duns == '804735132');
        system.assert(results3[0].primaryName == 'Gorman Manufacturing Company, Inc.');
        system.assert(results3[0].financials[0].yearlyRevenue[0].value == 22589957);
    }
        
    @isTest
    public static void DNBControllerCriteriaSearchAPITest() {   
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBSearch2Res');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        HttpResponse searchRes1 = controller.CriteriaSearchAPI();
        HttpResponse searchRes2 = controllerExt.CriteriaSearchAPI();
        HttpResponse searchRes3 = oppController.CriteriaSearchAPI();
        test.stopTest();
        
        system.assert(searchRes1.getStatusCode() == 200);
        system.assert(searchRes2.getStatusCode() == 200);
        system.assert(searchRes3.getStatusCode() == 200);
    }
    
    @isTest
    public static void DNBControllerUpdateSearchUITest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        system.assert(controller.searchDone == false);
        controller.UpdateSearchUI();
        system.assert(controller.searchDone == true);
        
        system.assert(controllerExt.searchDone == false);
        controllerExt.UpdateSearchUI();
        system.assert(controllerExt.searchDone == true);
        
        system.assert(oppController.searchDone == false);
        oppController.UpdateSearchUI();
        system.assert(oppController.searchDone == true);
    }
    
    @isTest
    public static void DNBControllerGetPageCountTest() {     
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        controller.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controller.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();        
        controller.getPageCount(); 
        controllerExt.getPageCount();
        oppController.getPageCount();        
        system.assert(controller.totalPages == 0);
        system.assert(controllerExt.totalPages == 0);
        system.assert(oppController.totalPages == 0);
        
        for(integer x = 0; x < 25; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
            controller.searchResults.add(org);   
            controllerExt.searchResults.add(org);
            oppController.searchResults.add(org);
        } 
        
        controller.getPageCount(); 
        controllerExt.getPageCount();
        oppController.getPageCount();
        system.debug(controller.totalPages);
        system.assert(controller.totalPages == 3);
        system.assert(controllerExt.totalPages == 3);
        system.assert(oppController.totalPages == 3);
    }
    
    @isTest
    public static void DNBControllerGetCurrentPageResultsTest(){     
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        controller.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controller.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();         
        for(integer x = 0; x < 25; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
            controller.searchResults.add(org);
            controllerExt.searchResults.add(org); 
            oppController.searchResults.add(org);
        }
        
        controller.getPageCount();
        controller.getCurrentPageResults();
        controllerExt.getPageCount();
        controllerExt.getCurrentPageResults();
        oppController.getPageCount();
        oppController.getCurrentPageResults();
        system.assert(controller.currentResults.size() == controller.resultsPerPage);
        system.assert(controllerExt.currentResults.size() == controllerExt.resultsPerPage);
        system.assert(oppController.currentResults.size() == controllerExt.resultsPerPage);

        for(integer x = 0;x < controller.currentResults.size();x++){           
            system.assert(controller.currentResults[x].duns == string.valueOf(x));
            system.assert(controllerExt.currentResults[x].duns == string.valueOf(x));
            system.assert(oppController.currentResults[x].duns == string.valueOf(x));
        }
        
        controller.currentPage = 3;
        controller.getCurrentPageResults();
        controllerExt.currentPage = 3;
        controllerExt.getCurrentPageResults();
        oppController.currentPage = 3;
        oppController.getCurrentPageResults();
        system.assert(controller.currentResults.size() == Math.mod(controller.searchResults.size(), controller.resultsPerPage));
        system.assert(controllerExt.currentResults.size() == Math.mod(controllerExt.searchResults.size(), controller.resultsPerPage));
        system.assert(oppController.currentResults.size() == Math.mod(controllerExt.searchResults.size(), controller.resultsPerPage));
        
        for(integer x = 0;x < controller.currentResults.size();x++){           
            system.assert(controller.currentResults[x].duns == string.valueOf(x + 20));
        }
        
        for(integer x = 0;x < controllerExt.currentResults.size();x++){           
            system.assert(controllerExt.currentResults[x].duns == string.valueOf(x + 20));
        }
        
        for(integer x = 0;x < oppController.currentResults.size();x++){           
            system.assert(oppController.currentResults[x].duns == string.valueOf(x + 20));
        }
        
        for(integer x = 25; x < 30; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
            controller.searchResults.add(org);
            controllerExt.searchResults.add(org);
            oppController.searchResults.add(org);
        }
        
        controller.getPageCount();
        controller.getCurrentPageResults();
        controller.currentPage = controller.totalPages;
        controllerExt.getPageCount();
        controllerExt.getCurrentPageResults();
        controllerExt.currentPage = controller.totalPages;
        oppController.getPageCount();
        oppController.getCurrentPageResults();
        oppController.currentPage = controller.totalPages;
        system.assert(controller.currentResults.size() == 10);
        system.assert(controllerExt.currentResults.size() == 10);
        system.assert(oppController.currentResults.size() == 10);
    }
    
    @isTest
    public static void DNBControllerPageNavigatorsTest(){      
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId, recordTypeId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        controller.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controller.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        
        for(integer x = 0; x < 25; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
            controller.searchResults.add(org); 
            controllerExt.searchResults.add(org);
            oppController.searchResults.add(org);
        }
        
        controller.getPageCount();
        controller.getCurrentPageResults();
        controllerExt.getPageCount();
        controllerExt.getCurrentPageResults();
        oppController.getPageCount();
        oppController.getCurrentPageResults();
        
        system.assert(controller.currentPage == 1);        
        controller.nextPage();
        system.assert(controllerExt.currentPage == 1);        
        controllerExt.nextPage();
        system.assert(oppController.currentPage == 1);        
        oppController.nextPage();
        system.assert(controller.currentPage == 2);
        controller.nextPage();
        system.assert(controllerExt.currentPage == 2);
        controllerExt.nextPage();
        system.assert(oppController.currentPage == 2);        
        oppController.nextPage();
        system.assert(controller.currentPage == 3);
        controller.firstPage();
        system.assert(controllerExt.currentPage == 3);
        controllerExt.firstPage();
        system.assert(oppController.currentPage == 3);        
        oppController.firstPage();
        system.assert(controller.currentPage == 1);
        controller.lastPage();
        system.assert(controllerExt.currentPage == 1);
        controllerExt.lastPage();
        system.assert(oppController.currentPage == 1);        
        oppController.lastPage();
        system.assert(controller.currentPage == 3);
        controller.previousPage();
        system.assert(controllerExt.currentPage == 3);
        controllerExt.previousPage();
        system.assert(oppController.currentPage == 3);        
        oppController.previousPage();
        system.assert(controller.currentPage == 2);
        controller.previousPage();
        system.assert(controllerExt.currentPage == 2);
        controllerExt.previousPage();
        system.assert(oppController.currentPage == 2);        
        oppController.previousPage();
        system.assert(controller.currentPage == 1);  
        system.assert(controllerExt.currentPage == 1);
        system.assert(oppController.currentPage == 1); 
    }
    
    @isTest
    public static void DNBControllerCheckForDuplicatesTest(){  
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account WHERE recordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        controller.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controller.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        
        for(integer x = 0; x < 25; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
            controller.searchResults.add(org); 
            controllerExt.searchResults.add(org);
            oppController.searchResults.add(org);
        }
        
        controller.getPageCount();
        controller.getCurrentPageResults();
        controllerExt.getPageCount();
        controllerExt.getCurrentPageResults();
        oppController.getPageCount();
        oppController.getCurrentPageResults();
        
        controller.checkForDuplicates(controller.currentResults);
        controllerExt.checkForDuplicates(controllerExt.currentResults);
        oppController.checkForDuplicates(oppController.currentResults);
                
        List<DNBAPIDataObjects.DNBOrganization> duplicates = new List<DNBAPIDataObjects.DNBOrganization>();
        List<DNBAPIDataObjects.DNBOrganization> duplicates2 = new List<DNBAPIDataObjects.DNBOrganization>();
        List<DNBAPIDataObjects.DNBOrganization> duplicates3 = new List<DNBAPIDataObjects.DNBOrganization>();
        
        for(DNBAPIDataObjects.DNBOrganization org : controller.currentResults){
            if(!String.isBlank(org.duplicateLink)){
                duplicates.add(org);   
            }
        }
        for(DNBAPIDataObjects.DNBOrganization org : controllerExt.currentResults){
            if(!String.isBlank(org.duplicateLink)){
                duplicates2.add(org);   
            }
        }
        for(DNBAPIDataObjects.DNBOrganization org : oppController.currentResults){
            if(!String.isBlank(org.duplicateLink)){
                duplicates3.add(org);   
            }
        }        
        system.assert(duplicates.size() == 1);
        system.assert(duplicates2.size() == 1);
        system.assert(duplicates3.size() == 1);
        controller.nextPage();
        controller.checkForDuplicates(controller.currentResults);
        duplicates.clear();
        controllerExt.nextPage();
        controllerExt.checkForDuplicates(controllerExt.currentResults);
        duplicates2.clear();
        oppController.nextPage();
        oppController.checkForDuplicates(oppController.currentResults);
        duplicates3.clear();
        for(DNBAPIDataObjects.DNBOrganization org : controller.currentResults){
            if(!String.isBlank(org.duplicateLink)){
                duplicates.add(org);   
            }
        }
        for(DNBAPIDataObjects.DNBOrganization org : controllerExt.currentResults){
            if(!String.isBlank(org.duplicateLink)){
                duplicates2.add(org);   
            }
        }
        for(DNBAPIDataObjects.DNBOrganization org : oppController.currentResults){
            if(!String.isBlank(org.duplicateLink)){
                duplicates3.add(org);   
            }
        }
        system.debug(duplicates.size());
        system.debug(duplicates2.size());
        system.debug(duplicates3.size());
        system.assert(duplicates.size() == 1);
        system.assert(duplicates2.size() == 1);
        system.assert(duplicates3.size() == 1);
        controller.nextPage();
        controller.checkForDuplicates(controller.currentResults);
        duplicates.clear();
        controllerExt.nextPage();
        controllerExt.checkForDuplicates(controllerExt.currentResults);
        duplicates2.clear();
        oppController.nextPage();
        oppController.checkForDuplicates(oppController.currentResults);
        duplicates3.clear();
        for(DNBAPIDataObjects.DNBOrganization org : controller.currentResults){
            if(!String.isBlank(org.duplicateLink)){
                duplicates.add(org);   
            }
        }
        for(DNBAPIDataObjects.DNBOrganization org : controllerExt.currentResults){
            if(!String.isBlank(org.duplicateLink)){
                duplicates2.add(org);   
            }
        }
        for(DNBAPIDataObjects.DNBOrganization org : oppController.currentResults){
            if(!String.isBlank(org.duplicateLink)){
                duplicates3.add(org);   
            }
        }
        system.debug(duplicates.size());
        system.debug(duplicates2.size());
        system.debug(duplicates3.size());
        system.assert(duplicates.size() == 1);
        system.assert(duplicates2.size() == 1);
        system.assert(duplicates3.size() == 1);
    }
    
    @isTest
    public static void DNBControllerCreateAccountTest(){
        DNBCustomController controller = new DNBCustomController();
        Opportunity o = [SELECT id, accountId, recordTypeId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        DNBAPIDataObjects.DNBOrganization enrichedOrg = new DNBAPIDataObjects.DNBOrganization();        
        enrichedOrg.duns = '101';
        enrichedOrg.primaryName = 'Account 101';
        enrichedOrg.registeredName = 'Account 101';
        enrichedOrg.industryCodes = new List<DNBAPIDataObjects.DNBIndustryCodes>();
        enrichedOrg.businessTrading = new List<DNBAPIDataObjects.DNBBusinessTrading>();
        enrichedOrg.corporateLinkage = new DNBAPIDataObjects.DNBCorporateLinkage(); 
        enrichedOrg.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();       
        DNBAPIDataObjects.DNBOrganization enrichedOrg2 = new DNBAPIDataObjects.DNBOrganization();
        enrichedOrg2.duns = 'CMZ201';
        enrichedOrg2.primaryName = 'Account 201';
        enrichedOrg2.registeredName = 'Account 201';
        enrichedOrg2.industryCodes = new List<DNBAPIDataObjects.DNBIndustryCodes>();
        enrichedOrg2.businessTrading = new List<DNBAPIDataObjects.DNBBusinessTrading>();
        enrichedOrg2.corporateLinkage = new DNBAPIDataObjects.DNBCorporateLinkage();
        enrichedOrg2.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cloudamize Customer').getRecordTypeId();
       
        List<Account> aList1 = [SELECT id, recordTypeId FROM Account WHERE DUNS_Number__c = '100' OR DUNS_Number__c = '101'];
        system.assert(aList1.size() == 0);
        List<Account> aList2 = [SELECT id, recordTypeId FROM Account WHERE DUNS_Number__c = 'CMZ200' OR DUNS_Number__c = 'CMZ201'];
        system.assert(aList1.size() == 0);
        
        test.startTest();
        Database.SaveResult result = controller.createAccount(enrichedOrg);
        Database.SaveResult result2 = oppController.createAccount(enrichedOrg2);
        test.stopTest();
        
        List<Account> aList3 = [SELECT id, recordTypeId FROM Account WHERE DUNS_Number__c = '100' OR DUNS_Number__c = '101'];
        system.assert(result.isSuccess());
        system.assert(aList3.size() == 1);
        List<Account> aList4 = [SELECT id, recordTypeId FROM Account WHERE DUNS_Number__c = 'CMZ200' OR DUNS_Number__c = 'CMZ201'];
        system.assert(result.isSuccess());
        system.assert(aList4.size() == 1);
    }
    
    @isTest
    public static void DNBControllerEnrichAccountTest(){
        Account a = [SELECT id, name, DUNS_Number__c, Primary_Name__c, billingCity, billingCountry, recordTypeId FROM Account WHERE recordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);

        DNBAPIDataObjects.DNBOrganization enrichedOrg = new DNBAPIDataObjects.DNBOrganization();
        
        enrichedOrg.duns = a.DUNS_Number__c;
        enrichedOrg.primaryName = 'New Name';
        enrichedOrg.registeredName = 'New Name';
        enrichedOrg.industryCodes = new List<DNBAPIDataObjects.DNBIndustryCodes>();
        enrichedOrg.businessTrading = new List<DNBAPIDataObjects.DNBBusinessTrading>();
        enrichedOrg.corporateLinkage = new DNBAPIDataObjects.DNBCorporateLinkage();
        enrichedOrg.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
       
        test.startTest();
        controllerExt.enrichAccount(enrichedOrg);
        test.stopTest();
        
        List<Account> aList1 = [SELECT id, name, DUNS_Number__c, Primary_Name__c, recordTypeId FROM Account WHERE DUNS_Number__c =: a.DUNS_Number__c];
        
        system.assert(aList1[0].name != 'New Name');
        system.assert(aList1[0].Primary_Name__c  == 'New Name');
    }
    
    @isTest
    public static void DNBControllerNewSearchTest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        DNBCustomController controller = new DNBCustomController();
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        DNBAPIDataObjects.DNBOrganization enrichedOrg = new DNBAPIDataObjects.DNBOrganization();
        controller.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controller.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        
        for(integer x = 0; x < 50; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
            org.primaryName = 'Account ' + String.valueOf(x);
            controller.searchResults.add(org);
            controllerExt.searchResults.add(org);
            oppController.searchResults.add(org);
        }
        
        controller.searchDone = true;
        controller.getPageCount();
        controller.getCurrentPageResults();
        
        controllerExt.searchDone = true;
        controllerExt.getPageCount();
        controllerExt.getCurrentPageResults();
        
        oppController.searchDone = true;
        oppController.getPageCount();
        oppController.getCurrentPageResults();
        
        system.assert(controller.searchResults.size() > 0);
        system.assert(controller.currentResults.size() > 0);
        system.assert(controllerExt.searchResults.size() > 0);
        system.assert(controllerExt.currentResults.size() > 0);
        system.assert(oppController.searchResults.size() > 0);
        system.assert(oppController.currentResults.size() > 0);
        
        controller.newSearch();
        controllerExt.newSearch();
        oppController.newSearch();
        
        system.assert(controller.searchResults == null);
        system.assert(controller.currentResults == null);
        system.assert(!controller.searchDone);
        system.assert(controllerExt.searchResults == null);
        system.assert(controllerExt.currentResults == null);
        system.assert(!controllerExt.searchDone);  
        system.assert(oppController.searchResults == null);
        system.assert(oppController.currentResults == null);
        system.assert(!oppController.searchDone);
    }
    
    @isTest
    public static void DNBControllerRequestMoreResultsTest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        controller.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controller.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        controllerExt.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.searchResults = new List<DNBAPIDataObjects.DNBOrganization>();
        oppController.currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        
        for(integer x = 0; x < 50; x++){
            DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
            org.duns = String.valueOf(x);
            org.primaryName = 'Account ' + String.valueOf(x);
            controller.searchResults.add(org);
            controllerExt.searchResults.add(org);
            oppController.searchResults.add(org);
        }
        
        controller.getPageCount();
        controller.getCurrentPageResults(); 
        controllerExt.getPageCount();
        controllerExt.getCurrentPageResults();
        oppController.getPageCount();
        oppController.getCurrentPageResults();
        system.assert(controller.currentDNBAPIPage == 1);
        system.assert(controllerExt.currentDNBAPIPage == 1);
        system.assert(oppController.currentDNBAPIPage == 1);
        
        system.debug(controller.currentResults.size());
        system.debug(controllerExt.currentResults.size());
        system.debug(oppController.currentResults.size());
        
        controller.requestMoreResults();
        controllerExt.requestMoreResults();
        oppController.requestMoreResults();
        
        system.assert(controller.currentPage == 1);
        system.assert(controller.currentDNBAPIPage == 2);
        system.assert(controllerExt.currentPage == 1);
        system.assert(controllerExt.currentDNBAPIPage == 2);
        system.assert(oppController.currentPage == 1);
        system.assert(oppController.currentDNBAPIPage == 2);
                
        controller.currentDNBAPIPage = 20;
        controller.currentPage = controller.totalPages;
        system.debug(controller.currentResults.size());        
        controller.requestMoreResults();
        
        controllerExt.currentDNBAPIPage = 20;
        controllerExt.currentPage = controller.totalPages;
        system.debug(controllerExt.currentResults.size());
        controllerExt.requestMoreResults();
        
        oppController.currentDNBAPIPage = 20;
        oppController.currentPage = controller.totalPages;
        system.debug(oppController.currentResults.size());
        oppController.requestMoreResults();
               
        system.assert(controller.currentPage == controller.totalPages);
        system.assert(controller.currentDNBAPIPage == 1);
        system.assert(controllerExt.currentPage == controllerExt.totalPages);
        system.assert(controllerExt.currentDNBAPIPage == 1);
        system.assert(oppController.currentPage == oppController.totalPages);
        system.assert(oppController.currentDNBAPIPage == 1);
        
        
    }

    @isTest
    public static void DNBControllerGenerateSearchRequestBodyTest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBCustomController controller = new DNBCustomController();
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        Opportunity o = [SELECT id, accountId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        
        controller.businessName = 'cloud';
        controller.City = 'london';
        controller.Country = 'UK';
        oppController.businessName = 'cloud';
        oppController.City = 'london';
        oppController.Country = 'UK';
        
        Test.startTest();
        String requestBody1 = controller.GenerateSearchRequestBody();
        String requestBody2 = controllerExt.GenerateSearchRequestBody();
        String requestBody3 = oppController.GenerateSearchRequestBody();
        Test.stopTest();
        
        system.assert(requestBody1.length() > 30);
        system.assert(requestBody2.length() > 30);
        system.assert(requestBody3.length() > 30);
    } 
    
    @isTest
    public static void DNBControllerGenerateQueryStringTest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a); 
        DNBControllerExtension controllerExt = new DNBControllerExtension(sc);
        
        Test.startTest();
        String queryString = controllerExt.GenerateQueryString();
        Test.stopTest();
        
        system.assert(!queryString.contains('\\s+'));
    }
    
    @isTest
    public static void DNBControllerAssignAccountTest(){
        Opportunity o = [SELECT id, accountId, recordTypeId FROM Opportunity LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);
        DNBOpportunityControllerExtension oppController = new DNBOpportunityControllerExtension(sc2);
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, recordTypeId FROM Account LIMIT 1];
        
        Database.SaveResult result1 = oppController.assignAccount(a.id);
        Database.SaveResult result2 = oppController.assignAccount(a.DUNS_Number__c);
        
        system.assert(result1.isSuccess());
        system.assert(result2.isSuccess());
    }
    
    @isTest
    public static void DNBMonitoringAddMonitoringAPITest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, DNB_Data_Monitoring__c, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controller = new DNBControllerExtension(sc);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBAddMonitorRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        a.DNB_Data_Monitoring__c = false;
        Update a;
        String accountId = a.id;
        
        test.startTest();
        controller.getVFAddMonitoringParameter();
        test.stopTest(); 
        
        Account a2 = [SELECt id, DNB_Data_Monitoring__c FROM Account WHERE id =:  accountId];
        system.assert(a2.DNB_Data_Monitoring__c == true);    
    }
    
    @isTest
    public static void DNBMonitoringRemoveMonitoringAPITest(){
        Account a = [SELECT id, name, DUNS_Number__c, billingCity, billingCountry, DNB_Data_Monitoring__c, recordTypeId FROM Account LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        DNBControllerExtension controller = new DNBControllerExtension(sc);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBRemoveMonitorRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        a.DNB_Data_Monitoring__c = true;
        Update a;
        String accountId = a.id;
        
        test.startTest();
        controller.getVFRemoveMonitoringParameter();
        test.stopTest(); 
        
        Account a2 = [SELECt id, DNB_Data_Monitoring__c FROM Account WHERE id =:  accountId];
        system.assert(a2.DNB_Data_Monitoring__c == false);    
    }
    
    @isTest
    public static void DNBErrorHandlingProcessErrorJSON1Test(){
        StaticResource sr = [select id,body from StaticResource Where Name = 'DNBErrorRes1'];
        String searchResponse = sr.body.toString();
        
        test.startTest();
        string proccessedJSON = DNBErrorHandling.ProcessErrorJSON(searchResponse); 
        test.stopTest();
        
        system.assertNotEquals(searchResponse, proccessedJSON);
    }
    
    @isTest
    public static void DNBErrorHandlingProcessErrorJSON2Test(){
        StaticResource sr = [select id,body from StaticResource Where Name = 'DNBErrorRes2'];
        String searchResponse = sr.body.toString();
        
        test.startTest();
        string proccessedJSON = DNBErrorHandling.ProcessErrorJSON(searchResponse); 
        test.stopTest();
        
        system.assertEquals(searchResponse, proccessedJSON);
    }
    
    @isTest
    public static void DNBErrorHandlingGetErrorMessageTest(){
        test.startTest();
        string message = DNBErrorHandling.GetErrorMessage('10002'); 
        test.stopTest();
        
        system.assertEquals('A required parameter is missing or a parameter value is missing.',message);
    }
    
    @isTest
    public static void DNBErrorHandlingParseErrorTest(){
        StaticResource sr = [select id,body from StaticResource Where Name = 'DNBErrorRes2'];
        String searchResponse = sr.body.toString();
        
        test.startTest();
        DNBAPIDataObjects.DNBError error = DNBErrorHandling.ParseError(searchResponse); 
        test.stopTest();
        
        system.assert(error.errorCode == '21501');   
    }
}