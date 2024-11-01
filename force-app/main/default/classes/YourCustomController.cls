public class YourCustomController {
    public YourCustomController(ApexPages.StandardController controller) {
    	Account acc =(Account)controller.getRecord();
    }
    public YourCustomController(){
    	List<Account> acc = [SELECT Name, Industry, Id, Rating FROM Account];
    }
}