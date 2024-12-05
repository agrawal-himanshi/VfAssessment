@RestResource(urlMapping='/Account/*')
global class SalesforceAccessForIntegration {
    
    @HttpGet
    global static List<Account> getAccount(){
        return [SELECT Id, Name FROM Account];
    }
        
    @HttpPost
    global static Account createAccount(String accountName) {
        Account acc = new Account();
        acc.Name = accountName;
        insert acc;
        return acc;
    }

}
