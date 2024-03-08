# SalesforceUserRecordAccess
Simple tool for displaying in a Screen Flow what record access levels a user has

Developed by Marcus Harikian
LinkedIn: www.linkedin.com/in/marcus-harikian-0194342

Note: You will need to deploy this as a zip file to your sandbox first, then update the Apex Unit Test before deploying to Production. 
Please review the apex class: UserAccessLevelTest

This tool contains the following items:
APEX Classes:
* UserAccessDefinedVars
* UserAccessLevel
* UserAccessLevelTest

FlexiPage (Lightning Page)
* User_Record_Level_Access_by_Record_Type

Flow - this Flow runs in System context as to provide access to all records regardless of the Sharing and Security.
* Get_User_Record_Access_Levels

Layout
* User_Access_Value__mdt-User Access Value Layout

CustomObject (Custom Metadata Type for use with the Data Table in the Screen Flow)
(Reference: Narender Singh on ForcePanda https://forcepanda.wordpress.com/2023/04/11/how-to-use-apex-defined-types-as-source-in-the-data-table/)
* User_Access_Value__mdt

Custom Tab
* User_Record_Level_Access_by_Record_Type

To streamline the deployment process to the org, I added the zip file SalesforceUserRecordAccess_Zipped
You can download this and then deploy it to your sandbox.

If you want to take a look at the code/configuration first, then you can use the Main branch for that and clone it to a repository of your own.
