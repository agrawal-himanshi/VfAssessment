/*  
    Class Name  : LoginController
    Description : For custom login page of community
    Created Date: 
    Name        : Himanshi Agrawal
*/
public with sharing class LoginController {
    

    /*  
        * @methodname: login
        * @description: Logining in user to the Community
        * @param: userName, password, url
        * @return: String
    */
    
	 @AuraEnabled
    public static String login(String userName, String password, String url){
        System.debug('userName');
        System.debug(userName);
        System.debug(password);
        System.debug(url);

        try{
            ApexPages.PageReference loginPageRef = Site.login(userName, password, url);
            System.debug('dfghjk');
            System.debug(userName);
            System.debug(password);
            System.debug(url);
            aura.redirect(loginPageRef);
            return 'success';
        }
        catch(Exception e){
            System.debug(e.getMessage());
            return e.getMessage();
        }
    } 
}