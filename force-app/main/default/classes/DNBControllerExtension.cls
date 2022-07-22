public class DNBControllerExtension {
    
    @TestVisible
    private final Account account;
           
    //settings
    @TestVisible
    private final integer resultsPerPage;
    @TestVisible
    private final integer maximumResultsReturned;
    
    //authentication handler
    @TestVisible
    private DNBAuthenticationHandler authHandler;
    @TestVisible
    private DNBMonitoringHandler monitoringHandler;
    
    public List<DNBAPIDataObjects.DNBOrganization> searchResults{get; set;}
    public List<DNBAPIDataObjects.DNBOrganization> currentResults{get; set;}
    
    //page state variables
    public boolean searchDone{get; set;}
    public Decimal totalPages{get; set;}
    public Decimal currentPage{get; set;}
    public integer currentDNBAPIPage{get; set;}
    public string dunsParameter {get;set;}
    public string monitoringParameter {get;set;}
    public Boolean refreshPage {get; set;}
    public Boolean isCMZ {get;set;}
    
    //adjust constructor to identity CMZ accounts
    public DNBControllerExtension(ApexPages.StandardController stdController){
        this.account = [SELECT id, DUNS_Number__c, name, BillingCity, BillingCountry, DNB_Data_Monitoring__c, recordTypeId FROM Account WHERE Id = :stdController.getId()];
        authHandler = new DNBAuthenticationHandler();
        monitoringHandler = new DNBMonitoringHandler();
        resultsPerPage = 10;
        maximumResultsReturned = 50;
        currentDNBAPIPage = 1;
        searchDone = false;
        refreshPage = false;
        if(this.account.recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cloudamize Customer').getRecordTypeId()){
            this.isCMZ = true;
        }
        else if(this.account.recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId()){
        	this.isCMZ = false; 
        }
    }
    
    public void CriteriaSearchAPIHandler(){
    	HttpResponse searchRes = CriteriaSearchAPI();
        if(searchRes.getStatusCode() == 200){
        	searchResults = parseSearchResults(searchRes.getBody(),'searchCandidates'); 
            system.debug(searchResults);
        	getPageCount();
        	currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        	getCurrentPageResults();
        	system.debug(currentPage);
        	system.debug(totalPages);
        	checkForDuplicates(searchResults);
        	updateSearchUI();
        }
        else{
        	system.debug(searchRes.getBody());
            string processedError = DNBErrorHandling.ProcessErrorJSON(searchRes.getBody());
            DNBAPIDataObjects.DNBError error = DNBErrorHandling.ParseError(processedError);            
            if(error.errorCode == '10002'){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,error.errorMessage + ': ' + error.errorDetails[0].parameter + '; ' + error.errorDetails[0].errors));
            }
            else if(error.errorCode == '21501'){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No match for the given search criteria. Please update your location search criteria and try again.'));               
            }
            else if(error.errorCode == '00004' || error.errorCode == '00040'){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid access token. Refreshing...Please try again'));   
                authHandler.RefreshSearchAuthenticationToken();
                authHandler = new DNBAuthenticationHandler();                
            }            
            else{
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown error. Please contact IT. Error Code: ' + error.errorCode));    
            }
        }
    }
    
    public void IdentityResolutionAPIHandler(){
    	HttpResponse searchRes = IdentityResolutionAPI();
        if(searchRes.getStatusCode() == 200){
        	searchResults = parseSearchResults(searchRes.getBody(),'matchCandidates');
            system.debug(searchResults);
        	getPageCount();
        	currentResults = new List<DNBAPIDataObjects.DNBOrganization>();
        	getCurrentPageResults();
        	system.debug(currentPage);
        	system.debug(totalPages);
        	checkForDuplicates(searchResults);
        	updateSearchUI();
        }
        else{
        	system.debug(searchRes.getBody());
            string processedError = DNBErrorHandling.ProcessErrorJSON(searchRes.getBody());
            DNBAPIDataObjects.DNBError error = DNBErrorHandling.ParseError(processedError);            
            if(error.errorCode == '10002'){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,error.errorMessage + ': ' + error.errorDetails[0].parameter + '; ' + error.errorDetails[0].errors));
            }
            else if(error.errorCode == '21501'){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No match for the given search criteria. Please update your location search criteria and try again.'));               
            }
            else if(error.errorCode == '00004' || error.errorCode == '00040'){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid access token. Refreshing...Please try again'));   
                authHandler.RefreshSearchAuthenticationToken();
                authHandler = new DNBAuthenticationHandler();                
            }
            else{
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown error. Please contact IT. Error Code: ' + error.errorCode));    
            }    
        }
    }
    
    //make cleanseMatch API call 
    public HttpResponse IdentityResolutionAPI(){
        Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String endpoint = 'https://plus.dnb.com/v1/match/cleanseMatch';
        endpoint += GenerateQueryString();
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + DNBAuthenticationHandler.RetrieveSearchAuthenticationToken());
        req.setHeader('Content-Type', 'application/json');        
        HttpResponse searchRes = http.send(req);
        System.debug(searchRes);
        return searchRes;           
    }
    
    public HttpResponse StandardDataBlocksAPI(string duns){        
        Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String endpoint = 'https://plus.dnb.com/v1/data/duns/' + duns + '?blockIDs=companyfinancials_L2_v2%2Ccompanyinfo_L2_v1%2Ceventfilings_L1_v1%2Cfinancialstrengthinsight_L2_v1%2Chierarchyconnections_L1_v1%2Cpaymentinsight_L1_v1%2Cprincipalscontacts_L1_v2&tradeUp=hq&customerReference=customer%20reference%20text&orderReason=6332'; 
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + DNBAuthenticationHandler.RetrieveDataBlocksAuthenticationToken());
        req.setHeader('Content-Type', 'application/json');        
        HttpResponse searchRes = http.send(req);        
        return searchRes;
    }
    
    public List<DNBAPIDataObjects.DNBOrganization> parseSearchResults(String res, string requestType){
        JSONParser parser = JSON.createParser(res);
        List<DNBAPIDataObjects.DNBOrganization> results = new List<DNBAPIDataObjects.DNBOrganization>();
        String parsingMatchTerm = requestType;
        
        while (parser.nextToken() != null) {
             if (parser.getText() == parsingMatchTerm) {
             	while (parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY) {
                	if(parser.getCurrentToken() == JSONToken.START_OBJECT) {  
                    	DNBAPIDataObjects result = (DNBAPIDataObjects) parser.readValueAs(DNBAPIDataObjects.class); 
                        results.add(result.organization);
                    }
                }
             }
        }
        return results;
    }
    
    public DNBAPIDataObjects.DNBOrganization parseDataBlocks(String responseBody){
        DNBAPIDataObjects.DNBOrganization enrichedOrg = new DNBAPIDataObjects.DNBOrganization();
        boolean foundOrg = false;
        
        JSONParser parser = JSON.createParser(responseBody);
        while (parser.nextToken() != null) {
            if (parser.getText() == 'organization') {
                system.debug('found organization');
                while (parser.nextToken() != null && !foundOrg) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        foundOrg = true;
                        enrichedOrg = (DNBAPIDataObjects.DNBOrganization) parser.readValueAs(DNBAPIDataObjects.DNBOrganization.class); 
                    }
                }
            }
        }   
        system.debug(enrichedOrg);
    	return enrichedOrg;
    }
    //adjust to remove 'CMZ' when searching D&B
    public String GenerateQueryString(){
        Integer parameterCount = 0;
        String parameters = '?';
        if(account.DUNS_Number__c != '' && !isCMZ){
            parameters += 'duns='+ account.DUNS_Number__c;
            parameterCount++;
        }
        else if(account.DUNS_Number__c != '' && isCMZ){
        	parameters += 'duns='+ account.DUNS_Number__c.substringAfter('CMZ');
            parameterCount++;    
        }
        if(account.name != ''){
            if(parameterCount > 0){
            	parameters += '&';    
            }
            parameters += 'name=' + account.name.replaceAll( '\\s+', '%20');
            parameterCount++;
        }
        
        System.debug('Called GenerateQueryString: '+ parameters);
        return parameters;
    }
    //bypass monitoring call if cmz
    public void enrichAccountHandler(string duns){
    	HttpResponse apiResponse = StandardDataBlocksAPI(duns);
        system.debug(apiResponse.getStatusCode());
        if(apiResponse.getStatusCode() == 200){
            HttpResponse monitoringResponse;
            if(!account.DNB_Data_Monitoring__c  && !isCMZ){
            	monitoringResponse = monitoringHandler.AddMonitoringAPI(duns);    
            }            
        	DNBAPIDataObjects.DNBOrganization enrichedOrg = parseDataBlocks(apiResponse.getBody());
            Database.SaveResult saveResult = enrichAccount(enrichedOrg);
            if(monitoringResponse != null && saveResult.isSuccess()){
                if(monitoringResponse.getStatusCode() == 200){
                    account.DNB_Data_Monitoring__c = true;
                    Update account;
                    refreshPage = true;
                }
                else if(monitoringResponse.getStatusCode() != 200){                
                    system.debug(monitoringResponse.getBody());
                    string processedError = DNBErrorHandling.ProcessErrorJSON(monitoringResponse.getBody());
                    DNBAPIDataObjects.DNBError error = DNBErrorHandling.ParseError(processedError);
                    if(error.errorCode == '40002' || error.errorCode == '21012' || error.errorCode == '40105' || error.errorCode == '10001'){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,error.errorMessage));               
                    }
                    else if(error.errorCode == '21007'){
            			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account has been enriched, but the Monitoring registration is no longer active. Please contact IT.'));    
            		}
                    else{
                    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown error. Please contact IT.'));    
                	}
                }                
            }
            else if(saveResult.isSuccess()){
                system.debug('account already monitored');
                refreshPage = true;    
            }
            else{
            	system.debug(saveResult);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Account was not enriched. Error: ' + saveResult.getErrors()[0].getMessage()));    
            }
        }
        else{
            system.debug(apiResponse.getBody());
            string processedError = DNBErrorHandling.ProcessErrorJSON(apiResponse.getBody());
            DNBAPIDataObjects.DNBError error = DNBErrorHandling.ParseError(processedError);
            if(error.errorCode == '00004' || error.errorCode == '00040'){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid access token. Refreshing...Please try again'));   
                authHandler.RefreshDataBlocksAuthenticationToken();
                authHandler = new DNBAuthenticationHandler();                
            }            
            else{
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown error. Please contact IT. Error Code: ' + error.errorCode));    
            }
        }                        
    }
    
    public HttpResponse CriteriaSearchAPI(){
        Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String endpoint = 'https://plus.dnb.com/v1/search/criteria';
        req.setEndpoint(endpoint);
        req.setBody(GenerateSearchRequestBody());
        req.setHeader('Authorization', 'Bearer ' + DNBAuthenticationHandler.RetrieveSearchAuthenticationToken());
        req.setHeader('Content-Type', 'application/json');        
        HttpResponse searchRes = http.send(req);
        System.debug(searchRes);
        return searchRes;                  
    }
    
    public String GenerateSearchRequestBody(){
        String requestBody = '{';
        
        if(!String.isBlank(account.name)){
            requestBody += '"primaryName":"' + account.name + '",';
        }
        if(!String.isBlank(account.BillingCity)){
            requestBody += '"addressLocality":"' + account.BillingCity + '",';
        }
        if(!String.isBlank(account.BillingCountry)){
            requestBody += '"countryISOAlpha2Code":"' + account.BillingCountry + '",';
        }
        requestBody += '"pageNumber": '+ currentDNBAPIPage + ',"pageSize": ' + maximumResultsReturned + ',"returnNavigators": true}';
        System.debug('Called GenerateSearchRequestBody: '+ requestBody);
        return requestBody;
    }
    //append 'CMZ' to DUNs based on account type
    public Database.SaveResult enrichAccount(DNBAPIDataObjects.DNBOrganization enrichedOrg){        
		//replace currency and annual revenue
        Account a = [SELECT 
                     id, name, duns_number__c, Primary_Name__c, Registered_Name__c,
                     Industry_Code__c, Industry_Description__c, Industry_Type_Description__c,
                     Entity_Type_Description__c, Paydex_Score__c, Delinquency_Score__c,
                     Delinquency_Score_Description__c, Delinquency_Score_National_Percentile__c,
                     Failure_Score__c, Failure_Score_Description__c, Failure_Score_National_Percentile__c,
                     Credit_Limit_Currency__c, Maximum_Recommended_Credit_Limit__c, Primary_Address_Postal_Code__c,
                     Primary_Address_Country__c, Primary_Address_Country_Code__c, Primary_Address_Street__c,
                     Primary_Address_County__c, Primary_Address_Locality__c, Primary_Address_Region__c,
                     Primary_Address_Region_Code__c, Primary_Address_Continental_Region__c,
                     Registered_Address_Street_Line_1__c, Registered_Address_Region_Code__c,
                     Registered_Address_County__c, Registered_Address_Street_Line_3__c, Registered_Address_Street_Line_4__c,
                     Mailing_Address_Country__c, Mailing_Address_Region__c, Mailing_Address_Continental_Region__c,
                     Senior_Principal_Name__c, Senior_Principal_Job_Title__c, Domestic_Ultimate_Name__c,
                     Domestic_Ultimate_Country__c, Domestic_Ultimate_Locality__c, Domestic_Ultimate_Region_Code__c,
                     Domestic_Ultimate_Region__c, Domestic_Ultimate_Continental_Region__c, Global_Ultimate_Name__c,
                     Global_Ultimate_Country__c, Global_Ultimate_Locality__c, Global_Ultimate_Region_Code__c,
                     Global_Ultimate_Region__c, Global_Ultimate_Continental_Region__c, Website, Sic, SicDesc,
                     CurrencyIsoCode, AnnualRevenue, Street_Address__c, Street_Address_2__c, Registered_State_Province__c,
                     City_Name__c, Registered_Country__c, Registered_Zip_Postal_Code__c, Prevent_D_B_update__c 
                     FROM Account WHERE id =:account.id];
        
        a.Primary_Name__c = enrichedOrg.primaryName;
        if(!isCMZ){
        	a.DUNS_Number__c = enrichedOrg.duns;
        }
        else if(isCMZ){
            a.DUNS_Number__c = 'CMZ' + enrichedOrg.duns; 
        }
        a.Registered_Name__c = enrichedOrg.registeredName;
        if(enrichedOrg.websiteAddress != null){
        	if(!enrichedOrg.websiteAddress.isEmpty()){
            	system.debug('passed website');
                a.website = enrichedOrg.websiteAddress[0].url;
        	}
        } 
        if(enrichedOrg.industryCodes != null){
            if(!enrichedOrg.industryCodes.isEmpty()){
                system.debug('passed industry');
                a.Industry_Code__c = enrichedOrg.industryCodes[0].code;
                a.Industry_Description__c = enrichedOrg.industryCodes[0].description;
                a.Industry_Type_Description__c = enrichedOrg.industryCodes[0].typeDescription;
            }
        }
        if(enrichedOrg.primaryIndustryCode != null){
            system.debug('passed primary industry');
        	a.Sic = enrichedOrg.primaryIndustryCode.usSicV4;
            a.SicDesc = enrichedOrg.primaryIndustryCode.usSicV4Description;
        }
        //replace currency and annual revenue fields
        if(enrichedOrg.financials != null){
            if(!enrichedOrg.financials.isEmpty()){
                if(enrichedOrg.financials[0].yearlyRevenue != null){
                    if(!enrichedOrg.financials[0].yearlyRevenue.isEmpty()){
                        a.Yearly_Revenue_Currency__c = enrichedOrg.financials[0].yearlyRevenue[0].dnbCurrency;
                        a.Yearly_Revenue_Value__c = enrichedOrg.financials[0].yearlyRevenue[0].value;
                    }    
                }   
            }            
        }
        if(enrichedOrg.businessEntityType != null){
            system.debug('passed entity type');
        	a.Entity_Type_Description__c = enrichedOrg.businessEntityType.description;
        }
        if(!enrichedOrg.businessTrading.isEmpty()){
            system.debug('passed businessTrading');
            if(enrichedOrg.businessTrading[0].summary != null){
                if(!enrichedOrg.businessTrading[0].summary.isEmpty()){
                    a.Paydex_Score__c = enrichedOrg.businessTrading[0].summary[0].paydexScore;
                }
            }
        }
        if(enrichedOrg.dnbAssessment != null){
            system.debug('passed dnb Assessment');
            if(enrichedOrg.dnbAssessment.delinquencyScore != null){
            	a.Delinquency_Score__c = enrichedOrg.dnbAssessment.delinquencyScore.classScore;
            	a.Delinquency_Score_Description__c = enrichedOrg.dnbAssessment.delinquencyScore.classScoreDescription;
                a.Delinquency_Score_National_Percentile__c = enrichedOrg.dnbAssessment.delinquencyScore.nationalPercentile;
            }
            if(enrichedOrg.dnbAssessment.failureScore != null){
            	a.Failure_Score__c = enrichedOrg.dnbAssessment.failureScore.classScore;
            	a.Failure_Score_Description__c = enrichedOrg.dnbAssessment.failureScore.classScoreDescription;
                a.Failure_Score_National_Percentile__c = enrichedOrg.dnbAssessment.failureScore.nationalPercentile;
            }
            if(enrichedOrg.dnbAssessment.creditLimitRecommendation != null){
                if(enrichedOrg.dnbAssessment.creditLimitRecommendation.maximumRecommendedLimit != null){
                    a.Credit_Limit_Currency__c = enrichedOrg.dnbAssessment.creditLimitRecommendation.maximumRecommendedLimit.dnbCurrency;
                    a.Maximum_Recommended_Credit_Limit__c = enrichedOrg.dnbAssessment.creditLimitRecommendation.maximumRecommendedLimit.value;
                } 
            }
            if(enrichedOrg.dnbAssessment.standardRating != null){
                a.Standard_Rating__c = enrichedOrg.dnbAssessment.standardRating.rating;
            }            
        }
        if(enrichedOrg.primaryAddress != null && DNBMonitoringHandler.AllowAddressUpdate(a)){
            system.debug('passed primary address');
            a.Primary_Address_Postal_Code__c = enrichedOrg.primaryAddress.postalCode;
            if(enrichedOrg.primaryAddress.addressCountry != null){
                a.Primary_Address_Country__c = enrichedOrg.primaryAddress.addressCountry.name;
                a.Primary_Address_Country_Code__c = enrichedOrg.primaryAddress.addressCountry.isoAlpha2Code;
            }
            if(enrichedOrg.primaryAddress.streetAddress != null){
                a.Primary_Address_Street__c = enrichedOrg.primaryAddress.streetAddress.line1;
            }
            if(enrichedOrg.primaryAddress.addressCounty != null){
                a.Primary_Address_County__c = enrichedOrg.primaryAddress.addressCounty.name;
            }
            if(enrichedOrg.primaryAddress.addressLocality != null){
                a.Primary_Address_Locality__c = enrichedOrg.primaryAddress.addressLocality.name;
            }
            if(enrichedOrg.primaryAddress.addressRegion != null){
                a.Primary_Address_Region__c = enrichedOrg.primaryAddress.addressRegion.name;           
                a.Primary_Address_Region_Code__c = enrichedOrg.primaryAddress.addressRegion.abbreviatedName;
            }
            if(enrichedOrg.primaryAddress.continentalRegion != null){                    
                a.Primary_Address_Continental_Region__c = enrichedOrg.primaryAddress.continentalRegion.name;
            }
        }
        if(enrichedOrg.registeredAddress != null && DNBMonitoringHandler.AllowAddressUpdate(a)){
            system.debug('passed registered address');
			a.Registered_Address_Street_Line_1__c = enrichedOrg.registeredAddress.streetName; 
            a.Registered_Zip_Postal_Code__c  = enrichedOrg.registeredAddress.postalCode;
            if(enrichedOrg.registeredAddress.addressRegion != null){
                a.Registered_Address_Region_Code__c = enrichedOrg.registeredAddress.addressRegion.abbreviatedName;
            }
            if(enrichedOrg.registeredAddress.addressCounty != null){
                a.Registered_State_Province__c  = enrichedOrg.registeredAddress.addressCounty.name;
                a.Registered_Address_County__c = enrichedOrg.registeredAddress.addressCounty.name;
            }
            if(enrichedOrg.registeredAddress.streetAddress != null){
                a.Street_Address__c = enrichedOrg.registeredAddress.streetAddress.line1;
                a.Street_Address_2__c = enrichedOrg.registeredAddress.streetAddress.line2;
                a.Registered_Address_Street_Line_3__c = enrichedOrg.registeredAddress.streetAddress.line3;
                a.Registered_Address_Street_Line_4__c = enrichedOrg.registeredAddress.streetAddress.line4;
            }
            if(enrichedOrg.registeredAddress.addressCountry != null){
                
            }
            if(enrichedOrg.registeredAddress.addressRegion != null){
            	a.Registered_Address_Region_Code__c = enrichedOrg.registeredAddress.addressRegion.abbreviatedName;
                a.Registered_Country__c = enrichedOrg.registeredAddress.addressRegion.name;
            }
            if(enrichedOrg.registeredAddress.addressLocality != null){
                a.City_Name__c  = enrichedOrg.registeredAddress.addressLocality.name;
            }
        } 
        if(enrichedOrg.mailingAddress != null && DNBMonitoringHandler.AllowAddressUpdate(a)){
            system.debug('passed mailing address');
            if(enrichedOrg.mailingAddress.addressCountry != null){
                a.Mailing_Address_Country__c = enrichedOrg.mailingAddress.addressCountry.name;
            }
            if(enrichedOrg.mailingAddress.addressRegion != null){
                a.Mailing_Address_Region__c = enrichedOrg.mailingAddress.addressRegion.name;
            }
            if(enrichedOrg.mailingAddress.continentalRegion != null){
                a.Mailing_Address_Continental_Region__c = enrichedOrg.mailingAddress.continentalRegion.name;
            }
        }
        if(enrichedOrg.mostSeniorPrincipal != null){
            system.debug('passed senior principal');
        	a.Senior_Principal_Name__c = enrichedOrg.mostSeniorPrincipal.fullName;
            if(enrichedOrg.mostSeniorPrincipal.jobTitles != null){
                if(!enrichedOrg.mostSeniorPrincipal.jobTitles.isEmpty()){
                    a.Senior_Principal_Job_Title__c = enrichedOrg.mostSeniorPrincipal.jobTitles[0].title;
                }
            }
        }
        if(enrichedOrg.corporateLinkage.domesticUltimate != null){
            system.debug('passed domestic');
            a.Domestic_Ultimate_Name__c = enrichedOrg.corporateLinkage.domesticUltimate.primaryName;
            if(enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress != null){
                if(enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.addressCountry != null){
                    a.Domestic_Ultimate_Country__c = enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.addressCountry.name;
                }
                if(enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.addressLocality != null){
                    a.Domestic_Ultimate_Locality__c = enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.addressLocality.name;
                }
                if(enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.addressRegion != null){
                    a.Domestic_Ultimate_Region_Code__c = enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.addressRegion.abbreviatedName;
                    a.Domestic_Ultimate_Region__c = enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.addressRegion.name;
                }
                if(enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.continentalRegion != null){
                    a.Domestic_Ultimate_Continental_Region__c = enrichedOrg.corporateLinkage.domesticUltimate.primaryAddress.continentalRegion.name;
                }  
            }
        }
        if(enrichedOrg.corporateLinkage.globalUltimate != null){
            system.debug('passed global');
            a.Global_Ultimate_Name__c = enrichedOrg.corporateLinkage.globalUltimate.primaryName;
            if(enrichedOrg.corporateLinkage.globalUltimate.primaryAddress != null){
                if(enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.addressCountry != null){
                    a.Global_Ultimate_Country__c = enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.addressCountry.name;
                }
                if(enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.addressLocality != null){
                    a.Global_Ultimate_Locality__c = enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.addressLocality.name;
                }
                if(enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.addressRegion != null){
                    a.Global_Ultimate_Region_Code__c = enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.addressRegion.abbreviatedName;
                    a.Global_Ultimate_Region__c = enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.addressRegion.name;
                }
                if(enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.continentalRegion != null){
                    a.Global_Ultimate_Continental_Region__c = enrichedOrg.corporateLinkage.globalUltimate.primaryAddress.continentalRegion.name;
                }
            }
        }
        Database.SaveResult result = Database.Update(a,false);
        system.debug('Update Result: ' + result);
        return result;
    }
    
    @TestVisible
    private void updateSearchUI(){
        searchDone = true;
        System.debug('Updated UI with search results');
    }
    
    @TestVisible
    private void getPageCount(){
    	Decimal resultTotal = searchResults.size();
        Decimal exactPageCount = (resultTotal / resultsPerPage);
        Double roundedPageCount = Math.ceil(exactPageCount);
        integer pageCount = Integer.valueOf(roundedPageCount);
        currentPage = 1;
        totalPages = pageCount;
        system.debug('Got page count: ' + totalPages);
    }
    
    @TestVisible
    private void getCurrentPageResults(){
        boolean finalPage = (totalPages == currentPage);
        integer finalPageResultCount = Math.mod(searchResults.size(), resultsPerPage);
        if(finalPageResultCount == 0){
        	finalPageResultCount = 10;    
        }
        currentResults.clear();
        if(!finalPage){
            for(integer x = (Integer.valueOf(currentPage) - 1) * Integer.valueOf(resultsPerPage); x < (currentPage - 1) * resultsPerPage + resultsPerPage; x++){
                currentResults.add(searchResults[x]);    
            }
            system.debug('Got current page results');
        }
        else if(finalPage){
        	for(integer x = (Integer.valueOf(currentPage) - 1) * Integer.valueOf(resultsPerPage); x < (currentPage - 1) * resultsPerPage + finalPageResultCount; x++){
                currentResults.add(searchResults[x]);    
            }
            system.debug('Got final page results');
        }        
    }
    
    @TestVisible
    private void checkForDuplicates(List<DNBAPIDataObjects.DNBOrganization> currentResults){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm().left(URL.getSalesforceBaseUrl().toExternalForm().indexOf('--c.visualforce.com'));
        List<String> DUNSList = new List<String>();        
        for(DNBAPIDataObjects.DNBOrganization org : currentResults){
           DUNSList.add(org.duns); 
        }
		system.debug(DUNSList);        
    	List<Account> duplicateAccounts = [SELECT id, DUNS_Number__c FROM Account WHERE DUNS_Number__c IN : DUNSList];
        if(duplicateAccounts.size() > 0){
            for(Account a : duplicateAccounts){
                for(DNBAPIDataObjects.DNBOrganization org : currentResults){
                    if(a.DUNS_Number__c == org.duns){
                        org.duplicateLink = baseUrl + '.lightning.force.com/lightning/r/Account/' + a.id + '/view';
                    }
                }
            }
        }
		system.debug('Marked duplicate accounts');        
    }
    
    public void nextPage(){
    	currentPage += 1;
        getCurrentPageResults();
    }
    
    public void previousPage(){
    	currentPage -= 1;
        getCurrentPageResults();    
    }
    
    public void firstPage(){
    	currentPage = 1;
        getCurrentPageResults();    
    }
    
    public void lastPage(){
    	currentPage = totalPages;
        getCurrentPageResults();    
    }
    
    public void requestMoreResults(){
        if(currentResults.size() != 10 || currentDNBAPIPage * maximumResultsReturned >= 1000){
            newSearch();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No more results. Please refine your search criteria.'));
            system.debug('cannot request more results');
        }
        else{
    		currentPage = 1;
        	currentDNBAPIPage += 1;
            if(!test.isRunningTest()){
  				CriteriaSearchAPIHandler();
            }
        	system.debug('requested more results');
        }	
    }
    
    public void newSearch(){
    	searchDone = false;
        searchResults = null;
        currentResults = null;
        currentDNBAPIPage = 1;
    }
    
    public void getVFCreateAccountParameter(){
        system.debug(dunsParameter);
        enrichAccountHandler(dunsParameter);
    }
    
    public void getVFAddMonitoringParameter(){
        system.debug(monitoringParameter);
        HttpResponse monitoringResponse = monitoringHandler.AddMonitoringAPI(monitoringParameter);
        if(monitoringResponse.getStatusCode() == 200){
            account.DNB_Data_Monitoring__c = true;
            Update account;
            refreshPage = true;
        }
        else{
            system.debug(monitoringResponse.getBody());
            string processedError = DNBErrorHandling.ProcessErrorJSON(monitoringResponse.getBody());
            DNBAPIDataObjects.DNBError error = DNBErrorHandling.ParseError(processedError);
            if(error.errorCode == '40002' || error.errorCode == '21012' || error.errorCode == '40105' || error.errorCode == '10001'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,error.errorMessage));               
            }
            else if(error.errorCode == '21007'){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Monitoring registration is no longer active. Please contact IT.'));    
            }
            else{
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown error. Please contact IT. Error Code: ' + error.errorCode));    
            }
        }
    }
    
    public void getVFRemoveMonitoringParameter(){
        system.debug(monitoringParameter);
        HttpResponse monitoringResponse = monitoringHandler.RemoveMonitoringAPI(monitoringParameter);
        if(monitoringResponse.getStatusCode() == 200){
            account.DNB_Data_Monitoring__c = false;
            Update account;
            refreshPage = true;
        }
        else{
            system.debug(monitoringResponse.getBody());
            string processedError = DNBErrorHandling.ProcessErrorJSON(monitoringResponse.getBody());
            DNBAPIDataObjects.DNBError error = DNBErrorHandling.ParseError(processedError);           
            if(error.errorCode == '21005' || error.errorCode == '10001'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,error.errorMessage));               
            }
            else{
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown error. Please contact IT. Error Code: ' + error.errorCode));    
            }
        }
    }
}