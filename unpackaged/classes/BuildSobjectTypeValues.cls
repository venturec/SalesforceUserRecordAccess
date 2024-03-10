public class BuildSobjectTypeValues 
{
	@InvocableMethod
    public static void buildSobjectTypes()
    {
        List<Sobject_Type__c> sobjType = new List<Sobject_Type__c>([SELECT Id FROM Sobject_Type__c]);
        
        if(!sobjType.isEmpty())
        {
            delete sobjType;
        }
        
        Set<String> sobjectTypeAdded = new Set<String>();
        List<Sobject_Type__c> sobjectTypesToInsert = new List<Sobject_Type__c>();
        List<RecordType> rtList = new List<RecordType>([SELECT SobjectType FROM RecordType ORDER BY SobjectType]);
        for(RecordType rt : rtList)
        {
            if(!sobjectTypeAdded.Contains(rt.SobjectType))
            {
                sobjectTypeAdded.Add(rt.SobjectType);
                Sobject_Type__c st = new Sobject_Type__c();
                st.Sobject_Type__c = rt.SobjectType;
                sobjectTypesToInsert.add(st);
            }
        }
        
        if(!sobjectTypesToInsert.isEmpty())
        {
            insert sobjectTypesToInsert;
        }
    }
}