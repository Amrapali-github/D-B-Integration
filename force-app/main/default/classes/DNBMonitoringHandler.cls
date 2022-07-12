public class DNBMonitoringHandler implements Queueable{
	    
    @TestVisible
    private static DNBAuthenticationHandler authHandler;
    
    @TestVisible
    public static DNBMonitoringSettings__c  monitoringSettings;
    
    @TestVisible
    private static final string env;
    
    public DNBMonitoringHandler(){
        authHandler = new DNBAuthenticationHandler();         
    }
    
    @future
    public static void ExecuteSchedule(){
        system.enqueueJob(new DNBMonitoringHandler());
    }
    
    public void execute(System.QueueableContext qc){
    	DNBMonitoringSettings__c settings = getMonitoringSettings();
        if(!settings.Missed_Update__c){
            system.debug('Pull');
            if(!test.isRunningTest()){
    			NotificationPullHandler();
            }
        }
        else if(settings.Missed_Update__c){
            system.debug('Repull');
        	if(!test.isRunningTest()){
    			NotificationRepullHandler(-1);
            }    
        }
    }
    
    public static DNBMonitoringSettings__c getMonitoringSettings(){
    	DNBMonitoringSettings__c  monitoringSettings;
        string env = DNBAuthenticationHandler.getEnvironment();
        if(env == 'Dev'){
            monitoringSettings = DNBMonitoringSettings__c.getValues('DNB_Dev_Monitoring');
        }
        else{
            monitoringSettings = DNBMonitoringSettings__c.getValues('DNB_Prod_Monitoring');
        }
        system.debug(monitoringSettings);
        return monitoringSettings;
    }
    
    public HttpResponse AddMonitoringAPI(string duns){        
        Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        String endpoint = 'https://plus.dnb.com/v1/monitoring/registrations/' +  GetMonitoringRegistration() + '/duns/' + duns;
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + DNBAuthenticationHandler.RetrieveSearchAuthenticationToken());
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"duns":"' + duns + '"}');        
        HttpResponse searchRes = http.send(req);  
        system.debug('Add Monitoring Response: ' + searchRes.getBody());
        return searchRes;
    }
    
    public HttpResponse RemoveMonitoringAPI(string duns){        
        Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        String endpoint = 'https://plus.dnb.com/v1/monitoring/registrations/' +  GetMonitoringRegistration() + '/duns/' + duns;
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + DNBAuthenticationHandler.RetrieveSearchAuthenticationToken());
        req.setHeader('Content-Type', 'application/json');        
        HttpResponse searchRes = http.send(req); 
        system.debug('Remove Monitoring Response: ' + searchRes.getBody());
        return searchRes;
    }
    
    public static HttpResponse PullNotificationsAPI(){ 
        system.debug('pull api');
        Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String endpoint = 'https://plus.dnb.com/v1/monitoring/registrations/' + GetMonitoringRegistration() + '/notifications?maxNotifications=' + GetMonitoringMaximumNotifications(); 
        req.setEndpoint(endpoint);
        system.debug(endpoint);
        req.setHeader('Authorization', 'Bearer ' + DNBAuthenticationHandler.RetrieveSearchAuthenticationToken());
        req.setHeader('Content-Type', 'application/json');
		req.setTimeout(120000); 
        HttpResponse searchRes = http.send(req);        
        return searchRes; 
    }
    
    public static HttpResponse RePullNotificationsAPI(integer pastDays){
		system.debug('repull api');        
        Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String endpoint = 'https://plus.dnb.com/v1/monitoring/registrations/' + GetMonitoringRegistration() + '/notifications/replay?maxNotifications=' + GetMonitoringMaximumNotifications() + '&replayStartTimestamp=' + String.valueOf(DateTime.now().addDays(pastDays).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')); 
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + DNBAuthenticationHandler.RetrieveSearchAuthenticationToken());
        req.setHeader('Content-Type', 'application/json');
		req.setTimeout(120000); 
        system.debug('Endpoint: ' + endpoint);
        HttpResponse searchRes = http.send(req);        
        return searchRes; 
    }
    
    public static string PreProcessJSONResponse(string rawJSON){
        string preProcessedJSON = '{"notification":[' + rawJSON + ']}';         
        return preProcessedJSON;
    }
    
    public static DNBAPIDataObjects.DNBNotificationPull ParseUpdateNotification(String preProcessedJSON){ 
        DNBAPIDataObjects.DNBNotificationPull results = new DNBAPIDataObjects.DNBNotificationPull();
        List<DNBAPIDataObjects.DNBNotification> notificationList = new List<DNBAPIDataObjects.DNBNotification>();
        system.debug(preProcessedJSON);
        JSONParser parser = JSON.createParser(preProcessedJSON);
        parser.nextToken();
        system.debug(parser.getText());
        while(parser.getCurrentToken() != null && parser.getCurrentToken() != JSONTOKEN.END_ARRAY){
            DNBAPIDataObjects.DNBNotification notification = new DNBAPIDataObjects.DNBNotification();
            
            system.debug('main loop:' + parser.getText());
            
            //finds "type" field, which should start every notification
            while(parser.getText() != 'type'){
                	//system.debug(parser.getText());
                 	parser.nextToken(); 
            }
            //system.debug(parser.getText());
            //system.debug('found type');
            //finds and assigns the value of type
            parser.nextToken();
            notification.type = parser.getText();
            system.debug(notification.type);
            //finds the "organization" object, 
            while(parser.getText() != 'organization'){
                //system.debug(parser.getText());
                parser.nextToken(); 
            }
            //system.debug(parser.getText());
            system.debug('found organization');
            //finds the value of organization and parses it into a DNBOrganization record
            parser.nextToken();
            DNBAPIDataObjects.DNBOrganization org = (DNBAPIDataObjects.DNBOrganization) parser.readValueAs(DNBAPIDataObjects.DNBOrganization.class);
            notification.organization = org;
            system.debug('duns: ' + org.duns);
            //finds the "elements" array and creates a list to hold each individual element
            while(parser.getText() != 'elements'){ 
                //system.debug(parser.getText());
                parser.nextToken();
            }  
            //system.debug(parser.getText());
            //system.debug('found elements');
            List<DNBAPIDataObjects.DNBNotificationElement> elementList = new List<DNBAPIDataObjects.DNBNotificationElement>();
            //iterates through each item in "elements"
            while(parser.getCurrentToken() != JSONTOKEN.END_ARRAY && parser.nextToken() != null){
                DNBAPIDataObjects.DNBNotificationElement element = new DNBAPIDataObjects.DNBNotificationElement();       
                //finds the "element" field
                while(parser.getText() != 'element'){
                    //system.debug(parser.getText());
                	parser.nextToken();	    
                }
                //system.debug(parser.getText());
                //system.debug('found element');
                //finds the value of element and assigns it
                parser.nextToken();               
                element.element = parser.getText();
                system.debug('element: ' + element.element);
                //determines the apex class type of the element
                //3 outcomes: 
                //"previous" is a single primitive data type; 
                //"previous" is a single custom apex data type;
                //"previous" is an array of custom apex data types;
                string fieldType = GetFieldType(element.element);
                string dataType = '';
                Type elementType;
                system.debug('field type: ' + fieldType);
                if(fieldType != 'string' && fieldType != 'decimal' && fieldType != 'boolean' && fieldType != 'integer' && fieldType != 'NA'){
                	elementType = Type.forName('DNBAPIDataObjects',fieldType);
                    dataType = 'Custom';
                }
                else if(fieldType != 'NA'){
                	dataType = 'Primitive';    
                }
                else{
                    dataType = 'Not Mapped';
                }
                //finds the "previous" field                  
                while(parser.getText() != 'previous'){
                    //system.debug(parser.getText());
                	parser.nextToken();	    
                }
                //system.debug(parser.getText());
                //system.debug('found previous');               
                //finds the value of "previous". If the token is the start of an array, go to the next token
                parser.nextToken();                
                if(parser.getCurrentToken() == JSONTOKEN.START_ARRAY && dataType != 'Not Mapped'){
                    //system.debug(parser.getText());
                	parser.nextToken();
                    dataType = 'Array';
                }
                //system.debug(parser.getText());
                system.debug('element type: ' + elementType);
                system.debug('data type: ' + dataType);
                List<String> previousValues = new List<String>();
                boolean break1 = false;
                string previousValue = 'test';
                //decision tree to get previous value based on the data type
                while(!break1){                    
                    
					//system.debug('previous value: ' + previousValue);                    
                    if(dataType == 'Custom' && parser.getCurrentToken() != JSONToken.VALUE_NULL){
                    	previousValue = (String) parser.readValueAs(elementType).toString();
                        previousValues.add(previousValue);
                        //system.debug('parsed custom object');
                        break1 = true;
                    }
                    else if(dataType == 'Primitive' && parser.getCurrentToken() != JSONToken.VALUE_NULL){
                    	previousValue = parser.getText(); 
                        previousValues.add(previousValue);
                        //system.debug('parsed primitive');
                        break1 = true;
                    }
                    else if(dataType == 'Array' && parser.getCurrentToken() != JSONToken.VALUE_NULL){
                        while(parser.getCurrentToken() != JSONTOKEN.END_ARRAY){
                            //system.debug(parser.getText());
                    		previousValue = (String) parser.readValueAs(elementType).toString();
                            previousValues.add(previousValue);
                            parser.nextToken();
                            //system.debug('parsed array');
                        }
                        break1 = true;
                    }
                    else if(dataType == 'Not Mapped'){   
                        break1 = true;    
                    }
                    else{
                    	break1 = true;   
                    }
                } 
                //assigns previous value
                element.previous = previousValues;
                system.debug('previous value: ' + previousValue); 
                
                //finds the "current" field                  
                while(parser.getText() != 'current'){
                    //system.debug(parser.getText());
                	parser.nextToken();                    
                }
                //system.debug(parser.getText());
                //system.debug('found current');              
                //finds the value of "current". If the token is the start of an array, go to the next token
                parser.nextToken();  
                //system.debug(parser.getText());
                if(parser.getCurrentToken() == JSONTOKEN.START_ARRAY && dataType != 'Not Mapped'){
                    //system.debug(parser.getText());
                	parser.nextToken();
                    //system.debug('data is array');
                    dataType = 'Array';
                }
                
                List<String> currentValues = new List<String>();
                boolean break2 = false;
                string currentValue = 'test';
                //decision tree to get current value based on the data type
                while(!break2){                    
                    //system.debug(currentValue);
                    if(dataType == 'Custom' && parser.getCurrentToken() != JSONToken.VALUE_NULL){
                    	currentValue = (String) parser.readValueAs(elementType).toString();
                        currentValues.add(currentValue);
                        //system.debug('parsed custom object');
                        break2 = true;
                    }
                    else if(dataType == 'Primitive' && parser.getCurrentToken() != JSONToken.VALUE_NULL){
                    	currentValue = parser.getText(); 
                        currentValues.add(currentValue);
                        //system.debug('parsed primitive');
                        break2 = true;
                    }
                    else if(dataType == 'Array' && parser.getCurrentToken() != JSONToken.VALUE_NULL){
                        //system.debug(elementType);
                		//system.debug(dataType);
                        //system.debug(currentValue);
                        while(parser.getCurrentToken() != JSONTOKEN.END_ARRAY){
                            //system.debug(parser.getText());
                    		currentValue = (String) parser.readValueAs(elementType).toString();
                            currentValues.add(currentValue);
                            //system.debug('parsed array');
                            parser.nextToken();
                        }
                        break2 = true;
                    }
                    else if(dataType == 'Not Mapped'){   
                         break2 = true;
                    }
                    else{
                    	break2 = true;    
                    }
                    system.debug('current value: ' + currentValue);
                } 
                //assigns current value
                //system.debug(currentValues);
                element.current = currentValues;

                //finds "timestamp" field
                while(parser.getText() != 'timestamp'){
                    //system.debug(parser.getText());
                	parser.nextToken();	
                }
                //system.debug(parser.getText());
                //system.debug('found timestamp');
                //finds timestamp value and assigns it
                parser.nextToken();
                //system.debug(parser.getText());
                element.timestamp = parser.getText();
                if(element.previous.size() > 0){
                	elementList.add(element);
                    system.debug('added element');                    
                }
                else{
                	system.debug('did not add unmapped element');    
                }                
                //finds end of element
                //2 outcomes:
                //end of notification / element list;
                //there are still elements in the same notification to be processed
                while(parser.getCurrentToken() != JSONTOKEN.END_OBJECT){
                    //system.debug(parser.getText());
                	parser.nextToken();                    
                }
                //system.debug(parser.getText());
                parser.nextToken();                
                system.debug('end of element loop');
                //system.debug(parser.getText());
            }
            //assigns element list and adds completed notification to list
            notification.elements = elementList;
            if(notification.elements.size() > 0){
            	notificationList.add(notification);
                system.debug('added notification');
            }
            else{
            	system.debug('notification for unmapped element not added');   
            }
            
            system.debug('loop complete');
            //finds the end of the notification and goes to the next token
            while(parser.getCurrentToken() != JSONTOKEN.END_OBJECT){
                //system.debug(parser.getText());
                	parser.nextToken();                    
            }
            //system.debug(parser.getText());
            //system.debug('found end of object');
            parser.nextToken();
            //if the next token is null, the loop ends and the results are returned
            //if the next token is not null, the main loop restarts
            system.debug('last token in main loop: ' + parser.getText());
        }
        results.notifications = notificationList;
        //system.debug(results);
        system.debug('return results');
        return results;
    }
    
    @future(callout=true)
    public static void NotificationPullHandler(){
        HttpResponse res = PullNotificationsAPI();
        system.debug(res);
        system.debug(res.getStatusCode());
        if(res.getStatusCode() != 200 && res.getStatusCode() != 204){
            system.debug('Pull Body: ' + res.getBody());
            system.debug('Missed update...');
        	monitoringSettings.Missed_Update__c = true;	
            Update monitoringSettings;
        }
        else if(res.getStatusCode() == 204){
        	system.debug('No more pull notifications');    
        }
        else if(res.getStatusCode() == 200){
            String preProccessJSON = PreProcessJSONResponse(res.getBody());
            DNBAPIDataObjects.DNBNotificationPull notifications = ParseUpdateNotification(preProccessJSON);
            Map<String,DNBAPIDataObjects.DNBNotification> accountIDToNotificationMap = GenerateAccountIdToNotificationMap(notifications);
            Database.SaveResult[] updateResults = UpdateMonitoredAccounts(accountIDToNotificationMap);
            system.debug('Update Results: ' + updateResults);
            List<DNB_Monitoring_Log__c> logList = new List<DNB_Monitoring_Log__c>();
            for(Database.SaveResult sr : updateResults){
                String accountId = sr.getId();
                Boolean isSuccessful = sr.isSuccess();
                List<Database.Error> errors = sr.getErrors();
                String error = '';
                if(errors.size() > 0){
                    error = errors[0].getMessage();
                }
                DNBAPIDataObjects.DNBNotification notification = accountIDToNotificationMap.get(accountId);
                for(DNBAPIDataObjects.DNBNotificationElement element : notification.elements){
                    String fieldName = GetFieldName(element.element);
                    if(fieldName.contains('Object:')){
                    	List<String> fieldNames = ParseObjectFieldNames(fieldName); 
                        for(String field : fieldNames){
                        	DNB_Monitoring_Log__c log = GenerateLogRecord(accountId,isSuccessful,error,element,field);
                            if(log.Account_Field__c != 'Unmapped'){
                                logList.add(log);
                            }    
                        }
                    }
                    else{
                        DNB_Monitoring_Log__c log = GenerateLogRecord(accountId,isSuccessful,error,element,fieldName);
                        if(log.Account_Field__c != 'Unmapped'){
                            logList.add(log);
                        }
                    }
                }
            }
            if(logList.size() > 0){
            	Database.SaveResult[] logInsert = Database.Insert(logList,false);
                for(Database.SaveResult sr : logInsert){
                    system.debug(sr);
                }
            }
            system.debug('queueing next notification pull...');
			system.enqueueJob(new DNBMonitoringHandler());            
        }        
    }
    
    @future(callout=true)
    public static void NotificationRepullHandler(integer pastDays){
        HttpResponse res = RepullNotificationsAPI(pastDays);
        system.debug(res);
        if(res.getStatusCode() != 200 && res.getStatusCode() != 204){
            system.debug('Repull Body: ' + res.getBody());
            system.debug('Missed repull update...');
        }
        else if(res.getStatusCode() == 204){
        	system.debug('No more repull notifications');
            monitoringSettings.Missed_Update__c = false;	
            Update monitoringSettings;
        }
        else if (res.getStatusCode() == 200){
            String preProccessJSON = PreProcessJSONResponse(res.getBody());
            DNBAPIDataObjects.DNBNotificationPull notifications = ParseUpdateNotification(preProccessJSON);
            Map<String,DNBAPIDataObjects.DNBNotification> accountIDToNotificationMap = GenerateAccountIdToNotificationMap(notifications);
            Database.SaveResult[] updateResults = UpdateMonitoredAccounts(accountIDToNotificationMap);
            system.debug('Update Results: ' + updateResults);
            List<DNB_Monitoring_Log__c> logList = new List<DNB_Monitoring_Log__c>();
            for(Database.SaveResult sr : updateResults){
                String accountId = sr.getId();
                Boolean isSuccessful = sr.isSuccess();
                List<Database.Error> errors = sr.getErrors();
                String error = '';
                if(errors.size() > 0){
                    error = errors[0].getMessage();
                }
                DNBAPIDataObjects.DNBNotification notification = accountIDToNotificationMap.get(accountId);
                for(DNBAPIDataObjects.DNBNotificationElement element : notification.elements){
                    String fieldName = GetFieldName(element.element);
                    if(fieldName.contains('Object:')){
                    	List<String> fieldNames = ParseObjectFieldNames(fieldName); 
                        for(String field : fieldNames){
                        	DNB_Monitoring_Log__c log = GenerateLogRecord(accountId,isSuccessful,error,element,field);
                            if(log.Account_Field__c != 'Unmapped'){
                                logList.add(log);
                            }    
                        }
                    }
                    else{
                        DNB_Monitoring_Log__c log = GenerateLogRecord(accountId,isSuccessful,error,element,fieldName);
                        if(log.Account_Field__c != 'Unmapped'){
                            logList.add(log);
                        }
                    }
                }
            }
            if(logList.size() > 0){
            	Database.SaveResult[] logInsert = Database.Insert(logList,false);
                for(Database.SaveResult sr : logInsert){
                    system.debug(sr);
                }
            }            
            system.debug('Repull successful. Queueing next notification pull...');
			system.enqueueJob(new DNBMonitoringHandler());            
        }
        
    }
    
    public static Map<String,DNBAPIDataObjects.DNBNotification> GenerateAccountIdToNotificationMap(DNBAPIDataObjects.DNBNotificationPull notifications){
    	List<String> dunsList = new List<String>();
        Map<String,DNBAPIDataObjects.DNBNotification> dunsToNotificationMap = new Map<String,DNBAPIDataObjects.DNBNotification>();       
        for(DNBAPIDataObjects.DNBNotification notification : notifications.notifications){        	    
            	dunsToNotificationMap.put(notification.organization.duns,notification);
            	dunsList.add(notification.organization.duns);
        } 
        system.debug('DUNS List: ' + dunsList);
        Map<String,DNBAPIDataObjects.DNBNotification> accountIdToNotificationMap = new Map<String,DNBAPIDataObjects.DNBNotification>();
		List<Account> aList = [SELECT id, DUNS_Number__c FROM Account WHERE DUNS_Number__c IN: dunsList];
        for(Account a : aList){
        	accountIdToNotificationMap.put(a.id,dunsToNotificationMap.get(a.DUNS_Number__c));    
        }
        return accountIdToNotificationMap;
    }
    
    public static Database.SaveResult[] UpdateMonitoredAccounts(Map<String,DNBAPIDataObjects.DNBNotification> accountIdToNotificationMap){
        List<Account> aList = [SELECT id, DUNS_Number__c, Prevent_D_B_update__c FROM Account WHERE id IN: accountIdToNotificationMap.keySet()];
        system.debug('Accounts Queried: '+ aList);
    	for(Account a : aList){
            Boolean allowAddressUpdates = AllowAddressUpdate(a);
        	DNBAPIDataObjects.DNBNotification notification = accountIdToNotificationMap.get(a.id);
            for(DNBAPIDataObjects.DNBNotificationElement element : notification.elements){
                system.debug(element.element);
                Boolean isAddressElement = IsAddressElement(element.element);				
                string sfdcFieldName = GetFieldName(element.element);
                list<string> objectFieldNames = new List<string>();
                SObjectType objToken = Schema.getGlobalDescribe().get('Account');
                DescribeSObjectResult objDef = objToken.getDescribe();
                Map<String, SObjectField> fields = objDef.fields.getMap();                
                if(sfdcFieldName.contains('Object:')){
                	objectFieldNames = ParseObjectFieldNames(sfdcFieldName);    
                }               
                if(element.current[0].contains(':[') && sfdcFieldName != 'Unmapped' && objectFieldNames.isEmpty() && (allowAddressUpdates || (!allowAddressUpdates && !isAddressElement))){
                    String DNBFieldName = GetDNBFieldName(sfdcFieldName);
                	String elementValue = ParseStringObject(element.current[0],DNBFieldName);
                    SObjectField fieldToken = fields.get(sfdcFieldName);
                	DescribeFieldResult selectedField = fieldToken.getDescribe();
                	Schema.DisplayType fieldType = selectedField.getType(); 
                	system.debug('Field Type: ' + fieldType);
                    system.debug('Parsed value: ' + elementValue);
                    if(fieldType == Schema.DisplayType.Integer && elementValue != 'null'){
                        system.debug('putting integer value in ' + sfdcFieldName);
                        a.put(sfdcFieldName, Integer.valueOf(elementValue)); 
                    }
                    else if((fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.Textarea || fieldType == Schema.DisplayType.PHONE) && elementValue != 'null'){
                        system.debug('putting string value in ' + sfdcFieldName);
                        a.put(sfdcFieldName, String.valueOf(elementValue));                               
                    }
                    else if(fieldType == Schema.DisplayType.Double && elementValue != 'null'){
                        system.debug('putting Double value in ' + sfdcFieldName);
                        a.put(sfdcFieldName, Double.valueOf(elementValue));                               
                    }
                } 
                else if(sfdcFieldName != 'Unmapped' && objectFieldNames.isEmpty() && (allowAddressUpdates || (!allowAddressUpdates && !isAddressElement))){
                    SObjectField fieldToken = fields.get(sfdcFieldName);
               		DescribeFieldResult selectedField = fieldToken.getDescribe();
                	Schema.DisplayType fieldType = selectedField.getType(); 
                	system.debug('Field Type: ' + fieldType);
                	if(fieldType == Schema.DisplayType.Integer && element.current[0] != 'null'){
                        system.debug('putting integer value in ' + sfdcFieldName);
                        a.put(sfdcFieldName, Integer.valueOf(element.current[0])); 
                    }
                    else if((fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.Textarea || fieldType == Schema.DisplayType.PHONE) && element.current[0] != 'null'){
                        system.debug('putting string value in ' + sfdcFieldName);
                        a.put(sfdcFieldName, String.valueOf(element.current[0]));                               
                    }
                    else if(fieldType == Schema.DisplayType.Double && element.current[0] != 'null'){
                        system.debug('putting Double value in ' + sfdcFieldName);
                        a.put(sfdcFieldName, Double.valueOf(element.current[0]));                               
                    }    
                } 
                else if (!objectFieldNames.isEmpty() && (allowAddressUpdates || (!allowAddressUpdates && !isAddressElement))){
                    for(String field : objectFieldNames){
                        String DNBFieldName = GetDNBFieldName(field);
                        String elementValue = ParseStringObject(element.current[0],DNBFieldName);                                                                         
                        SObjectField fieldToken = fields.get(field);
                		DescribeFieldResult selectedField = fieldToken.getDescribe();
                		Schema.DisplayType fieldType = selectedField.getType(); 
                		system.debug('Field Type: ' + fieldType);
                        system.debug('Parsed value: ' + elementValue);
                        if(fieldType == Schema.DisplayType.Integer && elementValue != 'null'){
                            system.debug('putting integer value in ' + field);
                        	a.put(field, Integer.valueOf(elementValue)); 
                    	}
                        else if((fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.Textarea || fieldType == Schema.DisplayType.PHONE) && elementValue != 'null'){
                            system.debug('putting string value in ' + field);
                        	a.put(field, String.valueOf(elementValue));                               
                        }
                        else if(fieldType == Schema.DisplayType.Double && elementValue != 'null'){
                            system.debug('putting Double value in ' + field);
                        	a.put(field, Double.valueOf(elementValue));                               
                        }
                    }    
                }
            }   
        }
        Database.SaveResult[] saveResults =  Database.Update(aList,false);
        return saveResults;
    }
    
    public static string GetMonitoringRegistration(){
        monitoringSettings = GetMonitoringSettings();
        String registrationNumber = monitoringSettings.Registration_Number__c;
        return registrationNumber;
    }
    
    public static Decimal GetMonitoringMaximumNotifications(){
        monitoringSettings = GetMonitoringSettings();
        Integer maximumNotifications = (Integer) monitoringSettings.Maximum_Notifications__c;
        return maximumNotifications;
    }
    
    public static string GetFieldType(string elementName){
        Map<String,String> fieldTypeMap = new Map<String,String>{
            	'organization.primaryName' => 'string',
                'organization.registeredName' => 'string',
                'organization.primaryAddress' => 'DNBAddress',
                'organization.industryCodes' => 'DNBIndustryCodes',
                'organization.businessEntityType' => 'DNBBusinessEntityType',
                'organization.businessTrading.summary' => 'DNBSummary',
                'organization.businessTrading' => 'DNBBusinessTrading',
                'organization.dnbAssessment.delinquencyScore.nationalPercentile' => 'string',
                'organization.dnbAssessment.failureScore.nationalPercentile' => 'string',
                'organization.dnbAssessment.delinquencyScore' => 'DNBDelinquencyScore',
                'organization.dnbAssessment.failureScore' => 'DNBFailureScore',
                'organization.dnbAssessment.creditLimitRecommendation.maximumRecommendedLimit' => 'DNBMaximumRecommendedLimit',
                'organization.primaryAddress.streetAddress' => 'DNBStreetAddress',
                'organization.primaryAddress.adressCounty' => 'DNBAddressCounty',
                'organization.primaryAddress.adressLocality' => 'DNBAddressLocality',
                'organization.primaryAddress.adressRegion' => 'DNBAddressRegion',
                'organization.primaryAddress.adressCountry' => 'DNBAddressCountry',
                'organization.primaryAddress.continentalRegion' => 'DNBContinentalRegion',
                'organization.registeredAddress' => 'DNBAddress',
                'organization.registeredAddress.streetAddress' => 'DNBStreetAddress',
                'organization.registeredAddress.adressCounty' => 'DNBAddressCounty',
                'organization.registeredAddress.adressRegion' => 'DNBAddressRegion',
                'organization.registeredAddress.adressCountry' => 'DNBAddressCountry',
                'organization.registeredAddress.continentalRegion' => 'DNBContinentalRegion',
                'organization.mailingAddress.adressRegion' => 'DNBAddressRegion',
                'organization.mailingAddress.continentalRegion' => 'DNBContinentalRegion',
                'organization.mostSeniorPrincipal' => 'DNBMostSeniorPrincipal',
                'organization.mostSeniorPrincipal.jobTitles' => 'DNBJobTitles',
                'organization.corporateLinkage.domesticUltimate.primaryAddress.adressCountry' => 'DNBAddressCountry',
                'organization.corporateLinkage.domesticUltimate.primaryAddress.adressLocality' => 'DNBAddressLocality',
                'organization.corporateLinkage.domesticUltimate.primaryAddress.adressRegion' => 'DNBAddressRegion',
                'organization.corporateLinkage.domesticUltimate.primaryAddress.continentalRegion' => 'DNBContinentalRegion',
                'organization.corporateLinkage.domesticUltimate' => 'DNBDomesticUltimate',
                'organization.corporateLinkage.globalUltimate.primaryAddress.adressCountry' => 'DNBAddressCountry',
                'organization.corporateLinkage.globalUltimate.primaryAddress.adressLocality' => 'DNBAddressLocality',
                'organization.corporateLinkage.globalUltimate.primaryAddress.adressRegion' => 'DNBAddressRegion',
                'organization.corporateLinkage.globalUltimate.primaryAddress.continentalRegion' => 'DNBContinentalRegion',
                'organization.corporateLinkage.globalUltimate' => 'DNBGlobalUltimate',
                'organization.financials' => 'DNBFinancials', 
                'organization.registrationNumbers' => 'DNBRegistrationNumbers',
                'organization.corporateLinkage' => 'DNBCorporatLinkage',                
                'organization.latestFinancials' => 'DNBFinancials',
                'organization.dnbAssessment' => 'DNBAssessment',
                'organization.dnbAssessment.creditLimitRecommendation.assessmentDate' => 'string',
                'organization.legalEvents.suits.filings' => 'DNBFilings',
                'organization.legalEvents.liens.filings'  => 'DNBFilings',
                'organization.financingEvents.financingStatementFilings.filings' => 'DNBFilings',
                'organization.numberOfEmployees' => 'DNBNumberOfEmployees',
                'organization.registeredAddress.streetName' => 'string',                
                'organization.telephone' => 'DNBTelephoneNumber',
                'organization.dnbAssessment.delinquencyScore.scoreCommentary' => 'DNBScoreCommentary',
                'organization.dnbAssessment.standardRating.scoreDate' => 'string',
                'organization.dnbAssessment.delinquencyScore.scoreDate' => 'string',
                'organization.dnbAssessment.failureScore.scoreDate' => 'string',
                'organization.websiteAddress' => 'DNBWebsiteAddress',
                'organization.primaryIndustryCode' => 'DNBIndustryCode'
        };
        string fieldType = fieldTypeMap.get(elementName);       
        if(fieldType == null){
        	fieldType = 'NA';
        }
        return fieldType;       
	}
    
    public static String GetFieldName(string elementName){                
    	Map<String,String> fieldNameMap = new Map<String,String>{
            'organization.telephone' => 'Phone',
            'organization.primaryName' => 'Primary_Name__c',
            'organization.registeredName' => 'Registered_Name__c',
            'organization.primaryAddress.addressCountry.name' => 'Primary_Address_Country__c',
            'organization.industryCodes' => 'Object:Industry_Code__c,Industry_Description__c,Industry_Type_Description__c',
            'organization.businessEntityType.description' => 'Entity_Type_Description__c',
            'organization.businessTrading' => 'Object:Paydex_Score__c',
            'organization.dnbAssessment.delinquencyScore.classScore' => 'Delinquency_Score__c',
            'organization.dnbAssessment.delinquencyScore.classScoreDescription' => 'Delinquency_Score_Description__c',
            'organization.dnbAssessment.failureScore.classScore' => 'Failure_Score__c',
            'organization.dnbAssessment.failureScore.classScoreDescription' => 'Failure_Score_Description__c',
            'organization.dnbAssessment.creditLimitRecommendation.maximumRecommendedLimit.dnbCurrency' => 'Credit_Limit_Currency__c',
            'organization.dnbAssessment.creditLimitRecommendation.maximumRecommendedLimit.value' => 'Maximum_Recommended_Credit_Limit__c',
            'organization.dnbAssessment.delinquencyScore.nationalPercentile' => 'Delinquency_Score_National_Percentile__c',
            'organization.dnbAssessment.failureScore.nationalPercentile' => 'Failure_Score_National_Percentile__c',
            'organization.primaryAddress.streetAddress.line1' => 'Primary_Address_Street__c',
            'organization.primaryAddress.addressCounty.name' => 'Primary_Address_County__c',
            'organization.primaryAddress.addressLocality.name' => 'Primary_Address_Locality__c',
            'organization.primaryAddress.addressRegion.name' => 'Primary_Address_Region__c',
            'organization.primaryAddress.addressRegion.abbreviatedName' => 'Primary_Address_Region_Code__c',
            'organization.primaryAddress.postalCode' => 'Primary_Address_Postal_Code__c',
            'organization.primaryAddress.addressCountry.isoAlpha2Code' => 'Primary_Address_Country_Code__c',
            'organization.primaryAddress.continentalRegion.name' => 'Primary_Address_Continental_Region__c',
            'organization.registeredAddress.streetName' => 'Registered_Address_Street_Line_1__c',
            'organization.registeredAddress.addressCounty.name' => 'Registered_State_Province__c',
            'organization.registeredAddress.addressRegion.abbreviatedName' => 'Registered_Address_Region_Code__c',
            'organization.registeredAddress.addressRegion.name' => 'Registered_Country__c',
            'organization.registeredAddress.streetAddress.line1' => 'Street_Address__c',
            'organization.registeredAddress.streetAddress.line2' => 'Street_Address_2__c',
            'organization.registeredAddress.streetAddress.line3' => 'Registered_Address_Street_Line_3__c',
            'organization.registeredAddress.streetAddress.line4' => 'Registered_Address_Street_Line_4__c',
            'organization.registeredAddress.addressLocality.name' => 'City_Name__c',
            'organization.registeredAddress.postalCode' => 'Registered_Zip_Postal_Code__c',
            'organization.mailingAddress.addressCountry.name' => 'Mailing_Address_Country__c',
            'organization.mailingAddress.addressRegion.name' => 'Mailing_Address_Region__c',
            'organization.mailingAddress.continentalRegion.name' => 'Mailing_Address_Continental_Region__c',
            'organization.mostSeniorPrincipal.fullName' => 'Senior_Principal_Name__c',
            'organization.mostSeniorPrincipal.jobTitles' => 'Object:Senior_Principal_Job_Title__c',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.addressCountry.name' => 'Domestic_Ultimate_Country__c',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.addressLocality.name' => 'Domestic_Ultimate_Locality__c',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.addressRegion.abbreviatedName' => 'Domestic_Ultimate_Region_Code__c',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.addressRegion.name' => 'Domestic_Ultimate_Region__c',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.continentalRegion.name' => 'Domestic_Ultimate_Continental_Region__c',
            'organization.corporateLinkage.domesticUltimate.primaryName' => 'Domestic_Ultimate_Name__c',
            'organization.corporateLinkage.globalUltimate.primaryAddress.addressCountry.name' => 'Global_Ultimate_Country__c',
            'organization.corporateLinkage.globalUltimate.primaryAddress.addressLocality.name' => 'Global_Ultimate_Locality__c',
            'organization.corporateLinkage.globalUltimate.primaryAddress.addressRegion.abbreviatedName' => 'Global_Ultimate_Region_Code__c',
            'organization.corporateLinkage.globalUltimate.primaryAddress.addressRegion.name' => 'Global_Ultimate_Region__c',
            'organization.corporateLinkage.globalUltimate.primaryAddress.continentalRegion.name' => 'Global_Ultimate_Continental_Region__c',
            'organization.corporateLinkage.globalUltimate.primaryName' => 'Global_Ultimate_Name__c',
            'organization.websiteAddress' => 'Website',
            'organization.primaryIndustryCode' => 'Sic,SicDesc',
            'organization.financials.yearlyRevenue' => 'AnnualRevenue,CurrencyIsoCode'
        };
        string fieldName = fieldNameMap.get(elementName);
        if(fieldName == null){
        	fieldName = 'Unmapped';
        }                
        return fieldName;
    }
    
    public static string GetDNBFieldName(string SFDCFieldName){
    	Map<String,String> fieldNameMap = new Map<String,String>{
        	'Phone' => 'telephone',
            'Primary_Name__c' => 'primaryName',
            'Registered_Name__c' => 'registeredName',
            'Primary_Address_Country__c' => 'name',
            'Industry_Code__c' => 'code',
            'Industry_Description__c' => 'description',
            'Industry_Type_Description__c' => 'typeDescription',
            'Entity_Type_Description__c' => 'description',
            'Paydex_Score__c' => 'paydexScore',
            'Delinquency_Score__c' => 'classScore',
            'Delinquency_Score_Description__c' => 'classScoreDescription',
            'Failure_Score__c' => 'classScore',
            'Failure_Score_Description__c' => 'classScoreDescription',
            'Credit_Limit_Currency__c' => 'dnbCurrency',
            'Maximum_Recommended_Credit_Limit__c' => 'value',
            'Delinquency_Score_National_Percentile__c' => 'nationalPercentile',
            'Failure_Score_National_Percentile__c' => 'nationalPercentile',
            'Primary_Address_Street__c' => 'line1',
            'Primary_Address_County__c' => 'name',
            'Primary_Address_Locality__c' => 'name',
            'Primary_Address_Region__c' => 'name',
            'Primary_Address_Region_Code__c' => 'abbreviatedName',
            'Primary_Address_Postal_Code__c' => 'postalCode',
            'Primary_Address_Country_Code__c' => 'isoAlpha2Code',
            'Primary_Address_Continental_Region__c' => 'name',
            'Registered_Address_Street_Line_1__c' => 'streetName',
            'Registered_Address_County__c' => 'name',
            'Registered_Address_Region_Code__c' => 'abbreviatedName',
            'Registered_Address_Street_Line_3__c' => 'line3',
            'Registered_Address_Street_Line_4__c' => 'line4',
            'Mailing_Address_Country__c' => 'name',
            'Mailing_Address_Region__c' => 'name',
            'Mailing_Address_Continental_Region__c' => 'name',
            'Senior_Principal_Name__c' => 'fullName',
            'Senior_Principal_Job_Title__c' => 'title',
            'Domestic_Ultimate_Country__c' => 'name',
            'Domestic_Ultimate_Locality__c' => 'name',
            'Domestic_Ultimate_Region_Code__c' => 'abbreviatedName',
            'Domestic_Ultimate_Region__c' => 'name',
            'Domestic_Ultimate_Continental_Region__c' => 'name',
            'Domestic_Ultimate_Name__c' => 'primaryName',
            'Global_Ultimate_Country__c' => 'name',
            'Global_Ultimate_Locality__c' => 'name',
            'Global_Ultimate_Region_Code__c' => 'abbreviatedName',
            'Global_Ultimate_Region__c' => 'name',
            'Global_Ultimate_Continental_Region__c' => 'name',
            'Global_Ultimate_Name__c' => 'primaryName',
            'Website' => 'url',
            'Sic' => 'usSicV4',
            'SicDesc' => 'usSicV4Description',
            'CurrencyIsoCode' => 'dnbCurrency',
            'AnnualRevenue' => 'value',
            'Street_Address__c' => 'line1',
            'Street_Address_2__c' => 'line2',
            'Registered_State_Province__c' => 'name',
            'City_Name__c' => 'name',
            'Registered_Country__c' => 'name',
            'Registered_Zip_Postal_Code__c' => 'postalCode'
        };
        string fieldName = fieldNameMap.get(SFDCFieldName);
        if(fieldName == null){
        	fieldName = 'Unmapped';
        }                
        return fieldName;    
    }
    
    public static List<String> ParseObjectFieldNames(string fieldNames){
        integer rightIndex = fieldNames.length() - 7;
        String processedFieldNames = fieldNames.right(rightIndex);
    	List<String> parsedFieldNames = processedFieldNames.split(','); 
        return parsedFieldNames;
    }
    
    public static DNB_Monitoring_Log__c GenerateLogRecord(String accountId, Boolean isSuccessful, String error,DNBAPIDataObjects.DNBNotificationElement element, String fieldName){
    	system.debug('creating monitoring log...');
        DNB_Monitoring_Log__c log = new DNB_Monitoring_Log__c();        
        log.Account__c = accountId;
        log.Account_Field__c = fieldName;
        log.Update_Success__c = isSuccessful;
        log.Previous_Value__c = element.previous[0];
        log.New_Value__c = element.current[0];
        log.Timestamp__c = element.timeStamp;
        log.Error__c = error;
        return log;
    }
    
    public static string ParseStringObject(string objectString, string fieldName){
    	string parsedValue = '';
        integer index = objectString.indexOf(fieldName + '=');
        integer fieldIndex = index + 1 + fieldName.length(); 
        integer endFieldIndex = objectString.indexOf(',',fieldIndex);
        if(endFieldIndex == -1){
        	endFieldIndex = objectString.indexOf(']',fieldIndex);    
        }        
        system.debug(index);
        system.debug(fieldIndex);
        system.debug(endFieldIndex);
        
        parsedValue = objectString.substring(fieldIndex, endFieldIndex);                
        return parsedValue;
    }
    
    public static boolean AllowAddressUpdate(Account a){
        boolean allowAddress = !a.Prevent_D_B_update__c;
    	return allowAddress;    
    }
    
    public static boolean IsAddressElement(string element){
        List<String> addressElements = new List<String>{
            'organization.primaryAddress.addressCountry.name',
            'organization.primaryAddress.streetAddress.line1',
            'organization.primaryAddress.addressCounty.name',
            'organization.primaryAddress.addressLocality.name',
            'organization.primaryAddress.addressRegion.name',
            'organization.primaryAddress.addressRegion.abbreviatedName',
            'organization.primaryAddress.postalCode',
            'organization.primaryAddress.addressCountry.isoAlpha2Code',
            'organization.primaryAddress.continentalRegion.name',
            'organization.registeredAddress.streetName',
            'organization.registeredAddress.addressCounty.name',
            'organization.registeredAddress.addressLocality.name',
            'organization.registeredAddress.addressRegion.abbreviatedName',
            'organization.registeredAddress.postalCode',
            'organization.registeredAddress.addressRegion.name',
            'organization.registeredAddress.streetAddress.line1',
            'organization.registeredAddress.streetAddress.line2',
            'organization.registeredAddress.streetAddress.line3',
            'organization.registeredAddress.streetAddress.line4',
            'organization.mailingAddress.addressCountry.name',
            'organization.mailingAddress.addressRegion.name',
            'organization.mailingAddress.continentalRegion.name',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.addressCountry.name',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.addressLocality.name',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.addressRegion.abbreviatedName',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.addressRegion.name',
            'organization.corporateLinkage.domesticUltimate.primaryAddress.continentalRegion.name',
            'organization.corporateLinkage.globalUltimate.primaryAddress.addressCountry.name',
            'organization.corporateLinkage.globalUltimate.primaryAddress.addressLocality.name',
            'organization.corporateLinkage.globalUltimate.primaryAddress.addressRegion.abbreviatedName',
            'organization.corporateLinkage.globalUltimate.primaryAddress.addressRegion.name',
            'organization.corporateLinkage.globalUltimate.primaryAddress.continentalRegion.name'
        };
        Boolean isAddress = addressElements.contains(element);
        return isAddress;
    }
}