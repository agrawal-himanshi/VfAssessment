public with sharing class ClientSidePaginationController {
    
    @AuraEnabled
    public static List<PicklistOptions> fetchObjectList() {
        List<PicklistOptions> objectList = new List<PicklistOptions>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()) {
            Schema.DescribeSObjectResult describeSObjectResultObj = objTyp.getDescribe();
            if(describeSObjectResultObj.isQueryable() && describeSObjectResultObj.isUpdateable() && describeSObjectResultObj.isSearchable()
               && describeSObjectResultObj.isAccessible() && describeSObjectResultObj.isCreateable()) {
                String name = objTyp.getDescribe().getName();
                if(!name.containsignorecase('history') && !name.containsignorecase('tag')&&
                 !name.containsignorecase('share') && !name.containsignorecase('feed'))
                {
                    objectList.add( new PicklistOptions(describeSObjectResultObj.getLabel(), describeSObjectResultObj.getName(), '') );
                }
            }
        }
        objectList.sort();
        return objectList;
    }

    @AuraEnabled
    public static List<PicklistOptions> fetchFieldsList(String objectName) {
        List<PicklistOptions> fieldsList = new List<PicklistOptions>();
        if(String.isNotBlank(objectName)){
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for (String fieldName: fieldMap.keySet()) {  
                Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
                if (field.isAccessible() && field.isCreateable()) {
                    fieldsList.add(new PicklistOptions(field.getLabel(), field.getName(), apexTypetoJSType.get(String.valueof(field.getType())) ));
                }
            }
        }
        fieldsList.sort();
        return fieldsList;     
    }

    @AuraEnabled
    public static List<sObject> fetchRecords(String objectName, List<String> fieldsList) {
        try {
            if(String.isNotBlank(objectName) && fieldsList != null){
                String query = 'SELECT id, ' + String.join(fieldsList, ',') + ' FROM '+ objectName + ' LIMIT 50000';
                return Database.query(query);
            }
            return null;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }    
    }

    public class PicklistOptions implements Comparable {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String datatype;
        public PicklistOptions(String label, String value, String datatype) {
            this.label = label;
            this.value = value;
            this.datatype = datatype;
        }
        
        public Integer compareTo(Object objToCompare) {
            return label.CompareTo(((PicklistOptions)objToCompare).label);
        }
    }

    public static Map<String, String> apexTypetoJSType = new Map<String, String> {
        'ADDRESS' => 'text',
        'ID' => 'text',
        'TEXTAREA' => 'text',
        'STRING' => 'text',
        'REFERENCE' => 'text',
        'PICKLIST' => 'text',
        'MULTIPICKLIST' => 'text',
        'DATE' => 'date',
        'DOUBLE' => 'number',
        'PERCENT' => 'percent',
        'PHONE' => 'phone',
        'URL' => 'url',
        'INTEGER' => 'number',
        'CURRENCY' => 'currency',
        'DATETIME' => 'date',
        'BOOLEAN' => 'boolean',
        'EMAIL' => 'email'
    };
}
