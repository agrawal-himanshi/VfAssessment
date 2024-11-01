public class sample {
	public list<Integer> fList;
    public list<Integer> firstList;
    public list<Integer> secondList;
    
    public list<Integer> getLMN(){
        fList=new Integer[10];
        for(Integer i=0;i<10;i++)
        {
            fList[i]=i+1;
        }
        return fList;
    }
    
    public list<Integer> getABC(){
        return firstList;
    }
    
    public list<Integer> getXYZ(){
        return secondList;
    }
    
    public pageReference Page1(){
        if(firstList==null)
        {
            firstList=new Integer[10];
        }
        for(Integer i=0;i<10;i++)
        {
            firstList[i]=10*(i+1);
        }
        return null;
    }
    
    public pageReference Page2(){
        if(secondList==null)
        {
            secondList=new Integer[10];
        }
        for(Integer i=0;i<10;i++)
        {
            secondList[i]=fList[i]*(i+1);
        }
       return null;
    }
}