# Role Manager

Lightning Web Component that provides a general manager UI great for Lookup and Assign scenarios common to Setup application.

## Possible use cases 
1. Record Sharing
2. Selecting Approval process initial submitters
3. Adding Approvers to Approval Step Definitions
...

# Admin usage

Administrator can add  roleManager component to any object if it has corresponding RoleManager. Each role manager has set of allowed actions. Admin is able to control object types that is going to be used in member.

## Component Parameters:
1. Edit Tab Name* - Name of the tab, which is used to show existing members (Remove Members)
2. Add Tab Name*  - Name of the tab, which is used to add new members (Add Members)
3. Supported Add Capabilities* - Action names, which will be shown on Add Tab (Read, Read/Write)
4. Supported Edit Capabilities* - Action names, which will be shown on Edit Tab (None)
5. Manager Name* - name of apex class, which is used as a manager (ManageSharingSettings)
6. Available Object Types* - Supported objects types (User, Role...)

*required parameter 
### Supported Member Types:
1. User
2. Role_subordinates
3. Role
4. Group
5. Queue

Developer can add another types by extending SearchUtils class.

## Supported RoleManagers
1. ManageSharingSettings - used for record sharing, utilizes Salesforce standard sharing mechanism. Object needs to support sharing.
### Supported Member Actions
    1.1 'Read' - sets read access for selected member
    1.2 'None' - removes access for selected member
    1.3 'Read/Write'  - sets read/write  access for selected member
2. ManageApprovalStepApprovers - manager to add/remove step approvers to/from approval process
### Supported Member Actions
    1.1 'Add' - add member to Approval Process Step Approvers
    1.2 'Remove' - remove member to Approval Process Step Approvers
3. ManageApprovalInitialSubmitters - manager to add/remove initial submitters to/from approval process
### Supported Member Actions
    1.1 'Add' - add member to Approval Process Initial Submitters
    1.2 'Remove' - remove member from Approval Process Initial Submitters
    
# Developer Usage
    
    In addition to everything that admin can do, developer can add its own manager classes, thus extending standard functionality. Each Manager Class has to implement RoleManagerProvider with following methods:
    
    1. String execute(String buttonName, String paramsString) - method to execute button action
    2. List<RoleManagerController.MemberInfo> getExisting(String recordId) - method to get existing members for specified in parameters record Id
    3. List<RoleManagerController.ButtonSetting> getSupportedButtons() - method to get supported buttons. Developer has to include all buttons that should be supported return statement of this method.
    
## Button Options
    Developer is able to control action availability by setting up ButtonSettings. Each ButtonSetting has ButtonMatchingRule which determines whether button is disabled or not and disabledValues.
    
    class ButtonMatchingRule {
                @AuraEnabled global MatchingAction matchingAction;
                @AuraEnabled global Map<String, List<String>> disabledValues;
                }
                
## Button Matching Actions:
    enum MatchingAction {
            EXISTS, NOTEXISTS, VALUEEQUALS, SUPPORTED
        }
    EXISTS - button is disabled if member exists in member table
    NOTEXISTS - button is disabled if member does not exist in member table
    VALUEEQUALS - button is disabled if value in member table equals values passed to disabledValues attribute of ButtonMatchingRule class
    SUPPORTED - button is always enabled
### Button Disabled Values
    Is map of values for each field which will make the button disabled
    This example will make button disabled if Type__c field of Member equals to 'Queue' or 'Group' :
    new Map<String, List<String>>{
                            'Type__c' => (new List<String>{
                                    'Queue', 'Group'
                            }
    

