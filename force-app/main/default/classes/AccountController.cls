public class AccountController {
    public Boolean Edit{get;set;}
    public List<sobject> acclist{get;set;}
     public AccountController() {        
        acclist =  [SELECT Id, Name , Rating , Industry From Account LIMIT 1] ;
         Edit = false ;
    }
     
	 public PageReference save(){
        update acclist ;
        Edit = false ;
        return null;
            //new PageReference('https://briskmindssoftwarepvt2-dev-ed--c.develop.vf.force.com/apex/Assignment1') ; 
    }
    
    public PageReference quicksave(){
        update acclist ;
        return null ;
    }
    
   public PageReference edit(){
        Edit = true ;
        return null ;
    }
    
    public PageReference Deletion(){
        delete acclist ;
        return null;
            //new PageReference('https://briskmindssoftwarepvt2-dev-ed--c.develop.vf.force.com/apex/Assignment1') ; 
    }
    
    public PageReference cancel(){
        Edit = false;
        return null ;
    }
}