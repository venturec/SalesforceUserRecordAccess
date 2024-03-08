/* Description:
 * Test class to cover UserAccessLevel apex class
 * 		1) Run a query on your record types to get a single record type. In this case the record type I'm using is related to the Account and is called 'Customer'
 *      2) When creating the test record, add any additional required fields from your org and make sure all Validation rules are accounted for
 * 
 *  Marcus Harikian
 *  LinkedIn: www.linkedin.com/in/marcus-harikian-0194342
 * 
 * 	Developer 			Date			Notes
 *  Marcus Harikian     2024-03-08      Initial Version
 * 
 * 
 */ 

@isTest
public class UserAccessLevelTest 
{
	static User testUser;
    static Account testAccount;
    static Id recordTypeId;
    
    static void setup()
    {
        testUser = [SELECT Id, Name FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];

        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer' LIMIT 1];
        recordTypeId = rt.Id;
        
        // Using the Account as the test record, but can be any sobject which has a record type associated with it
        testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.RecordTypeId = rt.Id;
        /* 
           Add additional required fields based on your org's setup, configuration and customization.
           Make sure to account for any validation rules, record triggered flows and apex validations
		*/
        
        insert testAccount;
    }
    
    @isTest
    static void testUserAccessLevels()
    {
        setup();
        
        UserAccessLevel.Request req = new UserAccessLevel.Request();
        req.selectedUser = testUser;
        req.selectedRecordTypeId = '';
        
        List<UserAccessLevel.Request> reqList = new List<UserAccessLevel.Request>{req};
        
        Test.startTest();
        UserAccessLevel.getUserAccessLevels(reqList);
        Test.stopTest();
    }
    
    @isTest
    static void testUserAccessLevelsWithRT()
    {
        setup();
        
        UserAccessLevel.Request req = new UserAccessLevel.Request();
        req.selectedUser = testUser;
        req.selectedRecordTypeId = recordTypeId;
        
        List<UserAccessLevel.Request> reqList = new List<UserAccessLevel.Request>{req};
        
        Test.startTest();
        UserAccessLevel.getUserAccessLevels(reqList);
        Test.stopTest();
    }
}