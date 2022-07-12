public class DNBAuthenticationHandler implements Schedulable {
    
    @TestVisible
    private final DNB_API_Token__c searchTokenStorage;
    @TestVisible
    private final DNB_API_Token__c dataBlocksTokenStorage;
    @TestVisible
    private final string env;
    
    public DNBAuthenticationHandler(){
        this.env = getEnvironment();        
        this.searchTokenStorage = getSearchTokenStorage(); 
        this.dataBlocksTokenStorage = getDataBlocksTokenStorage(); 
    }
    
    public static String getEnvironment(){
    	String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        string env = '';
        if(baseURL == 'https://cloudreach.lightning.force.com'){
        	env = 'Prod';
        }
        else{
            env = 'Dev';
        }
        return env;
    }
    
    public static DNB_API_Token__c getSearchTokenStorage(){
    	DNB_API_Token__c tokenStorage;
        string env = DNBAuthenticationHandler.getEnvironment();
        if(env == 'Dev'){
            tokenStorage = DNB_API_Token__c.getValues('DNB_Dev_Search_Token');
        }
        else{
            tokenStorage = DNB_API_Token__c.getValues('DNB_Prod_Search_Token');
        }
        return tokenStorage;
    }
    
    public static DNB_API_Token__c getDataBlocksTokenStorage(){
    	DNB_API_Token__c tokenStorage;
        string env = DNBAuthenticationHandler.getEnvironment();
        if(env == 'Dev'){
            tokenStorage = DNB_API_Token__c.getValues('DNB_Dev_DataBlocks_Token');
        }
        else{
            tokenStorage = DNB_API_Token__c.getValues('DNB_Prod_DataBlocks_Token');
        }
        return tokenStorage;
    }
    
    //allows daily schedule
    public void execute(SchedulableContext sc){
    	DNBAuthenticationHandler.GenerateSearchAuthenticationToken();
        DNBAuthenticationHandler.GenerateDataBlocksAuthenticationToken();
    }
    
    //daily authentication call
    @future(callout=true)
    public static void GenerateSearchAuthenticationToken(){
        string endpoint = '';
        String env = DNBAuthenticationHandler.getEnvironment();
        switch on env{
            when 'Prod'{
            	  endpoint = 'callout:DNB_Prod_Search_Authentication'; 
            }
            when 'Dev'{
                endpoint = 'callout:DNB_Dev_Search_Authentication';
            }
        }        
    	Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST'); 
        String body = '{"grant_type" : "client_credentials"}';
        req.setHeader('Content-Type', 'application/json');
     	req.setBody(body);
        req.setEndpoint(endpoint);
        System.debug('Request: ' + req);
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        
        JSONParser parser = JSON.createParser(res.getBody());        
        DNBAPIDataObjects.DNBToken tokenResult = (DNBAPIDataObjects.DNBToken) parser.readValueAs(DNBAPIDataObjects.DNBToken.class);
        DNB_API_Token__c tokenStorage = getSearchTokenStorage();        
        tokenStorage.token__c = tokenResult.access_token;
        tokenStorage.last_refresh__c = DateTime.now();
        Update tokenStorage;        
    }
    
    @future(callout=true)
    public static void GenerateDataBlocksAuthenticationToken(){
        string endpoint = '';
        String env = DNBAuthenticationHandler.getEnvironment();
        switch on env{
            when 'Prod'{
            	  endpoint = 'callout:DNB_Prod_DataBlock_Authentication'; 
            }
            when 'Dev'{
                endpoint = 'callout:DNB_Dev_DataBlock_Authentication';
            }
        }        
    	Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST'); 
        String body = '{"grant_type" : "client_credentials"}';
        req.setHeader('Content-Type', 'application/json');
     	req.setBody(body);
        req.setEndpoint(endpoint);
        System.debug('Request: ' + req);
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        
        JSONParser parser = JSON.createParser(res.getBody());        
        DNBAPIDataObjects.DNBToken tokenResult = (DNBAPIDataObjects.DNBToken) parser.readValueAs(DNBAPIDataObjects.DNBToken.class);
        DNB_API_Token__c tokenStorage = getDataBlocksTokenStorage();        
        tokenStorage.token__c = tokenResult.access_token;
        tokenStorage.last_refresh__c = DateTime.now();
        Update tokenStorage;        
    }
    
    //error handling authentication call
    public HttpResponse RefreshSearchAuthenticationToken(){      
        string endpoint = '';
        switch on env{
            when 'Prod'{
            	endpoint = 'callout:DNB_Prod_Search_Authentication'; 
            }
            when 'Dev'{
                endpoint = 'callout:DNB_Dev_Search_Authentication';
            }
        } 
        
        Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST'); 
        String body = '{"grant_type" : "client_credentials"}';
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);
        req.setEndpoint(endpoint);
        System.debug('Request: ' + req);
        HttpResponse res = http.send(req);
            
        if(res.getStatusCode() == 200){
            System.debug(res);
            System.debug(res.getBody()); 
                
            JSONParser parser = JSON.createParser(res.getBody());        
            DNBAPIDataObjects.DNBToken tokenResult = (DNBAPIDataObjects.DNBToken) parser.readValueAs(DNBAPIDataObjects.DNBToken.class);
            DNB_API_Token__c tokenStorage = getSearchTokenStorage();        
            tokenStorage.token__c = tokenResult.access_token;
            tokenStorage.last_refresh__c = DateTime.now();
            Update tokenStorage;
        }                          
        return res;
    }
    
    public HttpResponse RefreshDataBlocksAuthenticationToken(){      
        string endpoint = '';
        switch on env{
            when 'Prod'{
            	endpoint = 'callout:DNB_Prod_DataBlock_Authentication'; 
            }
            when 'Dev'{
                endpoint = 'callout:DNB_Dev_DataBlock_Authentication';
            }
        } 
        
        Http http = new http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST'); 
        String body = '{"grant_type" : "client_credentials"}';
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);
        req.setEndpoint(endpoint);
        System.debug('Request: ' + req);
        HttpResponse res = http.send(req);
            
        if(res.getStatusCode() == 200){
            System.debug(res);
            System.debug(res.getBody()); 
                
            JSONParser parser = JSON.createParser(res.getBody());        
            DNBAPIDataObjects.DNBToken tokenResult = (DNBAPIDataObjects.DNBToken) parser.readValueAs(DNBAPIDataObjects.DNBToken.class);
            DNB_API_Token__c tokenStorage = getDataBlocksTokenStorage();        
            tokenStorage.token__c = tokenResult.access_token;
            tokenStorage.last_refresh__c = DateTime.now();
            Update tokenStorage;
        }                          
        return res;
    }
    
    public static  String RetrieveSearchAuthenticationToken(){
        DNB_API_Token__c searchTokenStorage = getSearchTokenStorage();
        String token = searchTokenStorage.token__c;
        return token;
    } 
    
    public static String RetrieveDataBlocksAuthenticationToken(){
        DNB_API_Token__c dataBlocksTokenStorage = getDataBlocksTokenStorage();
        String token = dataBlocksTokenStorage.token__c;
        return token;
    }
}