public class UserAccessDefinedVars {

    @AuraEnabled public String UserId;
    @AuraEnabled public String UserFullName;
	@AuraEnabled public String sObjectType;
	@AuraEnabled public String RecordIdTested;
    @AuraEnabled public String RecordTypeName;
    @AuraEnabled public String RecordTypeDeveloperName;
    @AuraEnabled public String AccessLevel;
    
    // Required: no-argument constructor
    public UserAccessDefinedVars() {}
}