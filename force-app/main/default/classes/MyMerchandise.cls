public class MyMerchandise {
	public List<Merchandise__c> merchandiseList{get;set;}
        public MyMerchandise()
        {
        merchandiseList=[SELECT Id,Name,Job_Description__c,Price__c,Total_Inventory__c FROM Merchandise__c];
        }
}