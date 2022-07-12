public class DNBErrorHandling {

    public static DNBAPIDataObjects.DNBError ParseError(String errorResponse){
    	JSONParser parser = JSON.createParser(errorResponse);
        while(parser.getText() != 'error' && errorResponse.contains('error')){
        	parser.nextToken();    
        }
        parser.nextToken();
        DNBAPIDataObjects.DNBError apiError = (DNBAPIDataObjects.DNBError) parser.readValueAs(DNBAPIDataObjects.DNBError.class);
        system.debug(apiError);
        return apiError;
    }
    
    public static string GetErrorMessage(string errorCode){
        string errorMessage = '';
        system.debug('Error Code: ' + errorCode);
        Map<String,String> errorCodeMap = new Map<String,String>{
        	'10002' => 'A required parameter is missing or a parameter value is missing.'    
        };
        errorMessage = errorCodeMap.get(errorCode);
        system.debug('Error Message: ' + errorMessage);
        return errorMessage;
    }
    
    public static string ProcessErrorJSON(string errorResponse){
        string processedJSON = '';
        if(errorResponse.contains('"errors":')){
            Integer leftIndex = errorResponse.indexOf('"errors":') + 9;
            Integer midIndex = errorResponse.indexOf(':',leftIndex);
            Integer rightIndex = errorResponse.indexOf('}',midIndex);
            //system.debug(errorResponse.left(leftIndex));
            //system.debug(errorResponse.mid(midIndex + 1, rightIndex - midIndex - 1));
            //system.debug(errorResponse.right(errorResponse.length() - rightIndex - 1));
            processedJSON = errorResponse.left(leftIndex) + errorResponse.mid(midIndex + 1, rightIndex - midIndex - 1) + errorResponse.right(errorResponse.length() - rightIndex - 1);
        }
        else{
        	processedJSON = errorResponse;     
        }
        system.debug('Processed JSON: ' + processedJSON);
        return processedJSON;
    }
}