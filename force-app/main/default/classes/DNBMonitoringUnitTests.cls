@isTest
public class DNBMonitoringUnitTests {
    
    @TestSetup
    public static void setupTestData(){       
        DNB_API_Token__c searchTokenStorage = new DNB_API_Token__c();
        searchTokenStorage.name = 'DNB_Dev_Search_Token';
        Insert searchTokenStorage;
        
        DNB_API_Token__c dataBlocksTokenStorage = new DNB_API_Token__c();
        dataBlocksTokenStorage.name = 'DNB_Dev_DataBlocks_Token';
        Insert dataBlocksTokenStorage;
        
        List<Account> aList = new List<Account>();
        for(integer x = 0;x<25;x=x+4){
            Account a = new Account();
            a.name = 'Account ' + string.valueOf(x);
            a.DUNS_Number__c = string.valueOf(x);
            a.BillingCity = 'London';
            a.BillingCountry = 'UK';
            aList.add(a);
        }
        Insert aList;
        
    	DNBMonitoringSettings__c monitoringSettings = new DNBMonitoringSettings__c();
        monitoringSettings.name = 'DNB_Dev_Monitoring';
        monitoringSettings.Registration_Number__c  = 'CloudreachRegistrationDev';
        monitoringSettings.Maximum_Notifications__c = 100;       
        Insert monitoringSettings;       
    }
    
	@isTest
    public static void DNBMonitoringParseStringUpdateNotificationTest(){        
    	StaticResource sr = [select id,body from StaticResource Where Name = 'DNBMockStringUpdate'];
		String searchResponse = sr.body.toString();
        
        test.startTest();
        DNBMonitoringHandler.ParseUpdateNotification(searchResponse); 
        test.stopTest();
    }
    
    @isTest
    public static void DNBMonitoringParseObjectUpdateNotificationTest(){    
    	StaticResource sr = [select id,body from StaticResource Where Name = 'DNBMockObjectUpdate'];
		String searchResponse = sr.body.toString();
        
        test.startTest();
        DNBMonitoringHandler.ParseUpdateNotification(searchResponse); 
        test.stopTest();
    }
    
    @isTest
    public static void DNBMonitoringParseCombinedUpdateNotificationTest(){       
    	StaticResource sr = [select id,body from StaticResource Where Name = 'DNBMockCombinedUpdate'];
		String searchResponse = sr.body.toString();
        
        test.startTest();
        DNBMonitoringHandler.ParseUpdateNotification(searchResponse); 
        test.stopTest();
    }
    
    @isTest
    public static void DNBMonitoringParseObjectArrayUpdateNotificationTest(){        
    	StaticResource sr = [select id,body from StaticResource Where Name = 'DNBMockObjectArrayUpdate'];
		String searchResponse = sr.body.toString();
        
        test.startTest();
        DNBMonitoringHandler.ParseUpdateNotification(searchResponse); 
        test.stopTest();
    }
    
    @isTest
    public static void DNBMonitoringAddMonitoringAPITest(){
        DNBMonitoringHandler handler = new DNBMonitoringHandler();
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBAddMonitorRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        HttpResponse res = handler.AddMonitoringAPI('100000');
        test.stopTest(); 
        
        system.assert(res.getStatusCode() == 200);    
    }
    
    @isTest
    public static void DNBMonitoringRemoveMonitoringAPITest(){
        DNBMonitoringHandler handler = new DNBMonitoringHandler();
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockDNBRemoveMonitorRes');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        HttpResponse res = handler.RemoveMonitoringAPI('100000');
        test.stopTest(); 
        
        system.assert(res.getStatusCode() == 200);    
    }
    
    @isTest
    public static void DNBMonitoringPullNotificationAPITest(){
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBMockCombinedUpdate');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        HttpResponse res = DNBMonitoringHandler.PullNotificationsAPI();
        test.stopTest(); 
        
        system.assert(res.getStatusCode() == 200);    
    }
    
    @isTest
    public static void DNBMonitoringRepullNotificationAPITest(){
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DNBMockCombinedUpdate');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');         
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();
        HttpResponse res = DNBMonitoringHandler.RepullNotificationsAPI(-1);
        test.stopTest(); 
        
        system.assert(res.getStatusCode() == 200);    
    }
    
    @isTest
    public static void DNBMonitoringParseStringObjectTest(){
        string objectString = 'DNBTelephoneNumber:[isdCode=86, telephoneNumber=555555100]';
        string fieldName = 'telephoneNumber';
        
        string parsedValue = DNBMonitoringHandler.ParseStringObject(objectString,fieldName);
        system.debug(parsedValue);
    }
    
    @isTest
    public static void DNBMonitoringPreProccessJSONTest(){                
        StaticResource sr = [select id,body from StaticResource Where Name = 'MockDNBMonitoringRawJSON'];
		String searchResponse = sr.body.toString();
        
        test.startTest();
        string proccessedJSON = DNBMonitoringHandler.PreProcessJSONResponse(searchResponse); 
        test.stopTest();
        
        system.assert(proccessedJSON.startsWith('{"notification":['));
    }
    
    @isTest
    public static void DNBMonitoringGenerateAccountIdToNotificationMapTest(){
    	DNBAPIDataObjects.DNBNotificationPull notificationPull = new DNBAPIDataObjects.DNBNotificationPull();
        List<DNBAPIDataObjects.DNBNotification> notificationList = new List<DNBAPIDataObjects.DNBNotification>();
        DNBAPIDataObjects.DNBNotification notification = new DNBAPIDataObjects.DNBNotification();
        DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
        Account a = [SELECT id, DUNS_Number__c FROM Account Limit 1];
        org.duns = a.DUNS_Number__c;
        notification.organization = org;
        notification.type = 'UPDATE';        
        List<DNBAPIDataObjects.DNBNotificationElement> elementList = new List<DNBAPIDataObjects.DNBNotificationElement>();  
        for(integer x = 0; x < 5; x++){
            DNBAPIDataObjects.DNBNotificationElement element = new DNBAPIDataObjects.DNBNotificationElement();
            element.element = 'organization.telephone';
            element.previous = new List<string>{'previous value ' + String.valueOf(x)};
            element.current = new List<string>{'current value ' + String.valueOf(x)};
            element.timestamp = String.valueOf(DateTime.now());
            elementList.add(element);
        }       
        notification.elements = elementList;
        notificationList.add(notification);
        notificationPull.notifications = notificationList;        
        
        test.startTest();
        Map<String,DNBAPIDataObjects.DNBNotification> mapping = DNBMonitoringHandler.GenerateAccountIdToNotificationMap(notificationPull);
        test.stopTest();
        
        system.assert(mapping.get(a.id).organization.duns == a.DUNS_Number__c);
    }
    
    @isTest
    public static void DNBMonitoringUpdateMonitoredAccountsTest(){
    	DNBAPIDataObjects.DNBNotification notification = new DNBAPIDataObjects.DNBNotification();
        DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
        Account a = [SELECT id, DUNS_Number__c, Phone FROM Account Limit 1];
        org.duns = a.DUNS_Number__c;
        notification.organization = org;
        notification.type = 'UPDATE';        
        List<DNBAPIDataObjects.DNBNotificationElement> elementList = new List<DNBAPIDataObjects.DNBNotificationElement>();  
        for(integer x = 0; x < 5; x++){
            DNBAPIDataObjects.DNBNotificationElement element = new DNBAPIDataObjects.DNBNotificationElement();
            element.element = 'organization.telephone';
            element.previous = new List<string>{'5555555555'};
            element.current = new List<string>{'5555555555'};
            element.timestamp = String.valueOf(DateTime.now());
            elementList.add(element);
        }       
        notification.elements = elementList;
        Map<String,DNBAPIDataObjects.DNBNotification> mapping = new Map<String,DNBAPIDataObjects.DNBNotification>();
        mapping.put(a.id,notification);
        system.debug(mapping);
        
        test.startTest();
        Database.SaveResult[] results = DNBMonitoringHandler.UpdateMonitoredAccounts(mapping);
        test.stopTest();
        
        Account a2 = [SELECT id, Phone FROM Account WHERE id =: a.id];
        system.assert(a2.Phone == '5555555555');
    }
    
    @isTest
    public static void DNBMonitoringUpdateMonitoredAccounts2Test(){
    	DNBAPIDataObjects.DNBNotification notification = new DNBAPIDataObjects.DNBNotification();
        DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
        Account a = [SELECT id, DUNS_Number__c, Industry_Code__c FROM Account Limit 1];
        org.duns = a.DUNS_Number__c;
        notification.organization = org;
        notification.type = 'UPDATE';        
        List<DNBAPIDataObjects.DNBNotificationElement> elementList = new List<DNBAPIDataObjects.DNBNotificationElement>();  
        for(integer x = 0; x < 1; x++){
            DNBAPIDataObjects.DNBNotificationElement element = new DNBAPIDataObjects.DNBNotificationElement();
            element.element = 'organization.industryCodes';
            element.previous = new List<string>{'[code=541512, description=Computer Systems Design Services, priority=1, typeDescription=North American Industry Classification System 2017, typeDnbCode=30832]'};
            element.current = new List<string>{'[code=541512, description=Computer Systems Design Services, priority=1, typeDescription=North American Industry Classification System 2017, typeDnbCode=30832]'};
            element.timestamp = String.valueOf(DateTime.now());
            elementList.add(element);
        }       
        notification.elements = elementList;
        Map<String,DNBAPIDataObjects.DNBNotification> mapping = new Map<String,DNBAPIDataObjects.DNBNotification>();
        mapping.put(a.id,notification);
        system.debug(mapping);
        
        test.startTest();
        Database.SaveResult[] results = DNBMonitoringHandler.UpdateMonitoredAccounts(mapping);
        test.stopTest();
        
        Account a2 = [SELECT id, Industry_Code__c FROM Account WHERE id =: a.id];
        system.assert(a2.Industry_Code__c == '541512');
    }
    
    @isTest
    public static void DNBMonitoringUpdateMonitoredAccounts3Test(){
    	DNBAPIDataObjects.DNBNotification notification = new DNBAPIDataObjects.DNBNotification();
        DNBAPIDataObjects.DNBOrganization org = new DNBAPIDataObjects.DNBOrganization();
        Account a = [SELECT id, DUNS_Number__c, Domestic_Ultimate_Name__c FROM Account Limit 1];
        org.duns = a.DUNS_Number__c;
        notification.organization = org;
        notification.type = 'UPDATE';        
        List<DNBAPIDataObjects.DNBNotificationElement> elementList = new List<DNBAPIDataObjects.DNBNotificationElement>();  
        for(integer x = 0; x < 1; x++){
            DNBAPIDataObjects.DNBNotificationElement element = new DNBAPIDataObjects.DNBNotificationElement();
            element.element = 'organization.corporateLinkage.domesticUltimate.primaryName';
            element.previous = new List<string>{'domesticUltimate=DNBDomesticUltimate:[duns=740947049, financials=null, primaryAddress=DNBAddress:[addressCountry=DNBAdressCountry:[isoAlpha2Code=AU, name=Australia], addressCounty=null, addressLocality=DNBAddressLocality:[name=NORTH SYDNEY], addressRegion=DNBAddressRegion:[abbreviatedName=NSW, name=NEW SOUTH WALES], continentalRegion=DNBContinentalRegion:[name=Asia Pacific], postalCode=2060, streetAddress=DNBStreetAddress:[line1=LEVEL 1 177 PACIFIC HIGHWAY, line2=null, line3=null, line4=null], streetName=null, streetNumber=null], primaryName=TPG CORPORATION LIMITED]'};
            element.current = new List<string>{'domesticUltimate=DNBDomesticUltimate:[duns=740947049, financials=null, primaryAddress=DNBAddress:[addressCountry=DNBAdressCountry:[isoAlpha2Code=AU, name=Australia], addressCounty=null, addressLocality=DNBAddressLocality:[name=NORTH SYDNEY], addressRegion=DNBAddressRegion:[abbreviatedName=NSW, name=NEW SOUTH WALES], continentalRegion=DNBContinentalRegion:[name=Asia Pacific], postalCode=2060, streetAddress=DNBStreetAddress:[line1=LEVEL 1 177 PACIFIC HIGHWAY, line2=null, line3=null, line4=null], streetName=null, streetNumber=null], primaryName=TPG CORPORATION LIMITED]'};
            element.timestamp = String.valueOf(DateTime.now());
            elementList.add(element);
        }       
        notification.elements = elementList;
        Map<String,DNBAPIDataObjects.DNBNotification> mapping = new Map<String,DNBAPIDataObjects.DNBNotification>();
        mapping.put(a.id,notification);
        system.debug(mapping);
        
        test.startTest();
        Database.SaveResult[] results = DNBMonitoringHandler.UpdateMonitoredAccounts(mapping);
        test.stopTest();
        
        Account a2 = [SELECT id, Domestic_Ultimate_Name__c FROM Account WHERE id =: a.id];
        system.assert(a2.Domestic_Ultimate_Name__c  == 'TPG CORPORATION LIMITED');
    }
    
    @isTest
    public static void DNBMonitoringGetFieldNameTest(){
        String name1 = DNBMonitoringHandler.GetFieldName('organization.telephone');
        String name2 = DNBMonitoringHandler.GetFieldName('unmapped field');
        
        system.assert(name1 == 'Phone');
        system.assert(name2 == 'Unmapped');
    }
    
    @isTest
    public static void DNBMonitoringGetDNBFieldNameTest(){
        String name1 = DNBMonitoringHandler.GetDNBFieldName('Phone');
        String name2 = DNBMonitoringHandler.GetDNBFieldName('unmapped field');
        
        system.assert(name1 == 'telephone');
        system.assert(name2 == 'Unmapped');
    }
    
    @isTest
    public static void DNBMonitoringGenerateLogRecordTest(){
        Account a = [SELECT id FROM Account Limit 1];
        DNBAPIDataObjects.DNBNotificationElement element = new DNBAPIDataObjects.DNBNotificationElement();
        element.element = 'organization.telephone';
        element.previous = new List<string>{'4405036878'};
        element.current = new List<string>{'4405036879'};
        element.timestamp = String.valueOf(DateTime.now());
        
        DNB_Monitoring_Log__c log = DNBMonitoringHandler.GenerateLogRecord(a.id, true, '', element,'Phone');
        system.assert(log.Account__c == a.id);
    }
    
    @isTest
    public static void DNBMonitoringParseStringObject2Test(){
        string objectString = '[code=541512, description=Computer Systems Design Services, priority=1, typeDescription=North American Industry Classification System 2017, typeDnbCode=30832]';
        string parsedString1 = DNBMonitoringHandler.ParseStringObject(objectString,'code');
        //system.debug(parsedString1);
        system.assert(parsedString1 == '541512');
        string parsedString2 = DNBMonitoringHandler.ParseStringObject(objectString,'description');
        //system.debug(parsedString2);
        system.assert(parsedString2 == 'Computer Systems Design Services');
        string parsedString3 = DNBMonitoringHandler.ParseStringObject(objectString,'typeDescription');
        //system.debug(parsedString3);
        system.assert(parsedString3 == 'North American Industry Classification System 2017');        
    }
    
    @isTest
    public static void DNBMonitoringScheduleTest(){
        Test.startTest(); 
        DNBMonitoringSchedule sh = new DNBMonitoringSchedule();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Monitoring', sch, sh); 
        Test.stopTest(); 
    }
}