global with sharing class ManageApprovalInitialSubmitters implements RoleManagerProvider {

    static List<RoleManagerController.ButtonSetting> supportedButtonSettings;

    public static String execute(String buttonName, String paramsString) {
        Map<String, String> params = (Map<String, String>) JSON.deserialize(paramsString, Map<String, String>.class);

        if (buttonName == 'Add') {
            return add(
                    params.get('userOrGroupID'),
                    params.get('recordId'),
                    params.get('type'));
        } else if (buttonName == 'Remove') {
            return remove(
                    params.get('userOrGroupID'),
                    params.get('recordId'));
        }

        throw new AuraHandledException('Button "' + buttonName + '" is not supported');
    }

    private static String add(String userOrGroupID, Id recordId, String type) {
        List<AP_Allowed_Submitter__c> existingSubmitters = [
                SELECT Id,Name, ApprovalProcessDefinition__c,Type__c
                FROM AP_Allowed_Submitter__c
                WHERE Name = :userOrGroupID AND ApprovalProcessDefinition__c = :recordId AND Type__c = :type
        ];
        if (!existingSubmitters.isEmpty()) {
            return JSON.serialize(existingSubmitters[0]);
        }
        AP_Allowed_Submitter__c newSubmitter = new AP_Allowed_Submitter__c(
                Name = userOrGroupID,
                ApprovalProcessDefinition__c = recordId,
                Type__c = type);
        try {
            insert newSubmitter;
            return JSON.serialize(newSubmitter);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static String remove(String userOrGroupID, Id recordId) {
        try {
            delete [SELECT Id FROM AP_Allowed_Submitter__c WHERE Name = :userOrGroupID AND ApprovalProcessDefinition__c = :recordId];
            return 'SUCCESS';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static List<RoleManagerController.MemberInfo> getExisting(String recordId) {
        return getAllInitialSubmitters(recordId);
    }

    private static List<RoleManagerController.MemberInfo> getAllInitialSubmitters(String recordId) {
        List<RoleManagerController.MemberInfo> results = new List<RoleManagerController.MemberInfo>();
        List<AP_Allowed_Submitter__c> initialSubmitters = [SELECT Id, Name, Type__c FROM AP_Allowed_Submitter__c WHERE ApprovalProcessDefinition__c = :recordId];
        Map<String, Set<String>> objectTypeToIdMap = getObjectTypeToIdMap(initialSubmitters);
        Map<String, String> initialSubmitterIdToName = SearchUtils.getMembersByTypeAndId(objectTypeToIdMap);
        for (AP_Allowed_Submitter__c app : initialSubmitters) {
            results.add(new RoleManagerController.MemberInfo(app.Id, app.Name, initialSubmitterIdToName.get(app.Name), initialSubmitterIdToName.get(app.Name) + ' (' + app.Type__c + ')', app));
        }
        return results;
    }

    private static Map<String, Set<String>> getObjectTypeToIdMap(List<AP_Allowed_Submitter__c> initialSubmitters) {
        Map<String, Set<String>> resultMap = new Map<String, Set<String>>();
        for (AP_Allowed_Submitter__c app : initialSubmitters) {
            if (!resultMap.containsKey(app.Type__c)) {
                resultMap.put(app.Type__c, new Set<String>());
            }
            resultMap.get(app.Type__c).add(app.Name);
        }
        return resultMap;
    }

    private static void generateButtonSettings() {
        supportedButtonSettings = new List<RoleManagerController.ButtonSetting>();
        supportedButtonSettings.add(new RoleManagerController.ButtonSetting('Add', new RoleManagerController.ButtonMatchingRule(RoleManagerController.MatchingAction.EXISTS)));
        supportedButtonSettings.add(new RoleManagerController.ButtonSetting('Remove', new RoleManagerController.ButtonMatchingRule(RoleManagerController.MatchingAction.NOTEXISTS)));
        //Sample if Queue or Group sharing is added it can not be removed.
//        supportedButtonSettings.add(new RoleManagerController.ButtonSetting(
//                'Remove',
//                new RoleManagerController.ButtonMatchingRule(RoleManagerController.MatchingAction.VALUEEQUALS, new Map<String, List<String>>{
//                        'Type__c' => (new List<String>{
//                                'Queue', 'Group'
//                        })
//                })
//        ));
    }

    public static List<RoleManagerController.ButtonSetting> getSupportedButtons(String recordId) {
        if (supportedButtonSettings == null) {
            generateButtonSettings();
        }
        return supportedButtonSettings;
    }
}