@isTest
public class ClientSidePaginationControllerTest {

    @isTest
    static void testFetchObjectList() {
        // Test for fetching object list
        Test.startTest();
        List<ClientSidePaginationController.PicklistOptions> objectList = ClientSidePaginationController.fetchObjectList();
        
        // Ensure there are objects returned
        System.assertNotEquals(objectList, null, 'Object List should not be null');

        // Verify that the label and value are populated
        System.assertNotEquals(objectList[0].label, null, 'Label should not be null');
        System.assertNotEquals(objectList[0].value, null, 'Value should not be null');
        
        Test.stopTest();
    }

    @isTest
    static void testFetchFieldsList() {
        // Test for fetching fields list for a specific object
        Test.startTest();
        
        // Create a dummy Account object for testing fields
        String objectName = 'Account'; // Use a valid object name here
        
        List<ClientSidePaginationController.PicklistOptions> fieldsList = ClientSidePaginationController.fetchFieldsList(objectName);
        
        // Ensure fields list is returned
        System.assertNotEquals(fieldsList, null, 'Fields List should not be null');
        
        // Check if at least one field has a label and value
        System.assertNotEquals(fieldsList[0].label, null, 'Field Label should not be null');
        System.assertNotEquals(fieldsList[0].value, null, 'Field Value should not be null');
        
        Test.stopTest();
    }

    @isTest
    static void testFetchRecords() {
        // Test for fetching records based on object name and fields
        Test.startTest();
        
        // Using 'Account' object and two sample fields for the test
        String objectName = 'Account';
        List<String> fieldsList = new List<String>{'Name', 'Phone'};
        
        List<sObject> records = ClientSidePaginationController.fetchRecords(objectName, fieldsList);
        
        // Assert records are returned
        System.assertNotEquals(records, null, 'Records should not be null');
        
        Test.stopTest();
    }

    @isTest
    static void testFetchRecordsNoFields() {
        // Test for no fields scenario
        Test.startTest();
        
        String objectName = 'Account';
        List<String> fieldsList = new List<String>(); // Empty fields list
        
        try {
            List<sObject> records = ClientSidePaginationController.fetchRecords(objectName, fieldsList);
            System.assertEquals(records, null, 'Records should be null when no fields are selected');
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assertEquals(e.getMessage(), 'Script-thrown exception', 'Exception message should be handled');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testPicklistOptionsSorting() {
        // Test that picklist options are being sorted
        Test.startTest();
        
        List<ClientSidePaginationController.PicklistOptions> objectList = ClientSidePaginationController.fetchObjectList();
        
        // Check if sorting works by comparing first and second labels
        String firstLabel = objectList[0].label;
        String secondLabel = objectList[1].label;
        
        System.assert(firstLabel.compareTo(secondLabel) <= 0, 'The labels should be sorted');
        
        Test.stopTest();
    }
}