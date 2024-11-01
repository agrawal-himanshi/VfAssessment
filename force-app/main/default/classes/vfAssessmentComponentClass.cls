public class vfAssessmentComponentClass {
    public String selectedSobject{get;set;}  
    public List<String> fieldOption{get;set;}  
    public List<wrapperclass> recordQuery{get;set;}
    public String stringList{get;set;}
    public List<String> fieldsCopy{get;set;}
    public ApexPages.StandardSetController setCon{get;set;}
    public Integer size{get;set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
    public Boolean masterCheckBox{get;set;}

    public void recordsMethod(){
        fieldsCopy = fieldOption;
        stringList = String.join(fieldsCopy, ',');
        String query1 = 'SELECT ' + stringList + ' FROM ' + selectedSobject; 
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query1));
        setCon.setPageSize(size); 
        recordQuery = new List<wrapperclass>();
        for(sObject objct : setcon.getRecords())
        {
            recordQuery.add(new wrapperclass(objct));
        }
    }

    //constructor
    public vfAssessmentComponentClass(){
        size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        masterCheckBox = false;
    }

    //Changes the size of pagination
    public void refreshPageSize() {
        setCon.setPageSize(size);
        recordQuery.clear();
        for(sObject objct : setcon.getRecords())
        {
            recordQuery.add(new wrapperclass(objct));
        }
    }

    //method for first button
    public void firstBtn(){
        recordQuery.clear();
        setCon.first();
        for(sObject objct : setcon.getRecords())
        {
            recordQuery.add(new wrapperclass(objct));
        }
    }

    //method for previous button
    public void previousBtn(){
        recordQuery.clear();
        setCon.previous();
        for(sObject objct : setcon.getRecords())
        {
            recordQuery.add(new wrapperclass(objct));
        }
    }

    //method for next button
    public void nextBtn(){
        recordQuery.clear();
        setCon.next();
        for(sObject objct : setcon.getRecords())
        {
            recordQuery.add(new wrapperclass(objct));
        }
    }

    //method for last button
    public void lastBtn(){
        recordQuery.clear();
        setCon.last();
        for(sObject objct : setcon.getRecords())
        {
            recordQuery.add(new wrapperclass(objct));
        }
    }

    // public PageReference SaveAsCSV() {
    //     renderAsExcel='application/vnd.ms-excel⌗Account Report.csv';
    //     return null;

    // }


    public class wrapperclass {
        public sObject obj{get;set;}
        public Boolean check{get;set;}
        public wrapperclass(sObject obj){
            this.obj = obj;
        }
    }
}



	
//     public List<WrapperClass> myList;
//     public List<WrapperClass> SelectedList{get;set;}
//     public void SelectedRecord()
//     {
//         SelectedList=new List<WrapperClass>();
//         for(WrapperClass obj:myList)
//         {
//             if(obj.MyCheck==true)
//             {
//                 SelectedList.add(obj);
//             }
//         }
//     }
//     public class WrapperClass
//     {
//         public SObject NestObj{get;set;}
//         public Boolean MyCheck{get;set;}
//         public WrapperClass(SObject NestObj)
//         {
//             this.NestObj=NestObj;
//         }
//     }
// }


