/* Description:
 * Pulls records in from the UserRecordAccess object and provides limited insights into the overall record level access based on a User and a single test record related to any 
 * sObjectType within the RecordType entries
 * 
 * 
 *  Developed by: Marcus Harikian
 *  LinkedIn: www.linkedin.com/in/marcus-harikian-0194342
 * 
 * 	Developer 			Date			Notes
 *  Marcus Harikian     2024-03-08      Initial Version
 *  
 * 
 * 
 */ 

public class UserAccessLevel 
{
	@InvocableMethod
    public static List<Results> getUserAccessLevels(List<Request> request)
    {
        Request req = (Request)request[0];
        
        Id userId = (Id)req.selectedUser.Id;
        String userFullName = req.selectedUser.Name;
        
        Set<Id> filteredRecordTypeIds = new Set<Id>();

        List<Results> resultsList = new List<Results>();
        
        // Get all of the available record types from RecordType sObject
        Map<Id, RecordType> recordTypes; 
        // For some reason, the filter of: req.selectedRecordTypeId == '' does not work
        // Added a check to see if the length of the record type string value is 18 or 15
        if(req.selectedRecordTypeId.length() == 18 || req.selectedRecordTypeId.length() == 15)
        {
            recordTypes = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE Id = :req.selectedRecordTypeId]);
        }
        else
        {
            recordTypes = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName, SobjectType FROM RecordType]);
        }
        
		// Return an empty resultsList value back to the Flow
        if(recordTypes == null || recordTypes.isEmpty())
        {
            return resultsList;
        }
        
        Map<String, List<Id>> sobjectToRtId = new Map<String, List<Id>>();
        for(RecordType rt : recordTypes.values())
        {
            if(sobjectToRtId.ContainsKey(rt.SobjectType))
            {
                sobjectToRtId.get(rt.SobjectType).add(rt.Id);
            }
            else
            {
                sobjectToRtId.put(rt.SobjectType, new List<Id>{rt.Id});
            }
        }
        
        // Potential problem here with hitting SOQL Query Governor Limits and may need to be reviewed, 
        // but may work if the number of record types is below 100.
        // Added an additional filter on the Record Type Id within the Flow and will pass that in as a variable to Invocable Property
        // We will only select 1 record related to each record type in the sobjectToRtId above
        // Using dynamic SOQL to query up the Id of the sObject record
        
        List<Id> recordIds = new List<Id>();
        
        // This retains the relationship between the found records with the Record Type Id so we can link them back up later
        Map<Id, Id> recordIdToRecordTypeId = new Map<Id, Id>();
        for(String sobjectType : sobjectToRtId.keySet())
        {
            for(Id rtId : sobjectToRtId.get(sobjectType))
            {
                // SECURITY REVIEW
                String strQuery = 'SELECT ID FROM ' + sobjectType + ' WHERE RecordTypeId = \'' + rtId + '\' LIMIT 1';
                try
                {
                	sObject sobj = database.query(strQuery);
                	recordIds.add(sobj.Id);
                    
                    recordIdToRecordTypeId.put(sobj.Id, rtId);
                }
                catch(Exception exc)
                {
                    // Don't care about handling the error. 
                    // We just need the try/catch block in the case where there are no records returned for that particular record type
                }
            }
        }
        
        // Lastly, select the UserRecordAccess using the User.Id passed into the request variable
        // Use the list of RecordId(s) built from the above
        List<UserRecordAccess> uraList = new List<UserRecordAccess>([SELECT
                                                                 RecordId,
                                                                 MaxAccessLevel
                                                                 FROM UserRecordAccess
                                                                WHERE UserId = :userId
                                                                AND RecordId IN :recordIds]);
        
        // Get the key prefixes from all sObjects in the system and use this when needing to find the name of the sObject from UserRecordAccess.RecordId
        Map<String, String> sobjectToKeyPrefix = new Map<String, String>();
        Map<String, Schema.SObjectType> sobjectTypes = Schema.getGlobalDescribe();
        
        for(Schema.SObjectType sobjType : sobjectTypes.values())
        {
            Schema.DescribeSObjectResult sobjDesc = sobjType.getDescribe();
            sobjectToKeyPrefix.put(sobjDesc.getKeyPrefix(), sobjDesc.getName());
        }

        // Now build the User Access array and pass that back as the resultsList to the calling Flow handler        
        Results res = new Results();
        for(UserRecordAccess ura : uraList)
        {
            String keyPrefix = (String)ura.RecordId.substring(0, 3);
            
            UserAccessDefinedVars fua = new UserAccessDefinedVars();
            fua.UserId         = userId;
            fua.UserFullName   = userFullName;
            fua.sObjectType    = sobjectToKeyPrefix.get(keyPrefix);
            fua.recordIdTested = ura.RecordId;
            
            Id recordTypeId = recordIdToRecordTypeId.get(ura.RecordId);
            fua.RecordTypeName = recordTypes.get(recordTypeId).Name;
            fua.RecordTypeDeveloperName = recordTypes.get(recordTypeId).DeveloperName;
            
            fua.AccessLevel = ura.MaxAccessLevel;
           
            res.filteredUserAccess.add(fua);
        }
        
        // NOTE: Flows work with Lists of Lists and therefore if we want to return a collection of values
        // we have to add those values to a List or array first, then add the final result to another list
        // which is why this Invocable method utilizes two inner classes: FilteredUserAccess to hold the list of values returned from UserRecordAccess 
        // and Results.filteredUserAccess which contains the array of values added from the above
        // Finally we add Results to another list before returning it back to the Flow
        resultsList.add(res);
        
        return resultsList;
    }
    
    public class Request 
    {
        @InvocableVariable
        public User selectedUser;
        
        @InvocableVariable
        public String selectedRecordTypeId;
    }
    
    public class Results
    {
        @InvocableVariable public List<UserAccessDefinedVars> filteredUserAccess;
        
        public Results()
        {
            filteredUserAccess = new List<UserAccessDefinedVars>();
        }
    }
}