public class ClassForAssessment {
   Map<String, Schema.SObjectType> globaldesc = Schema.getGlobalDescribe();
   public Boolean show{get;set;}
   public String selectedSobject{get; set;}
   public Boolean fieldPage{get;set;}
   public String fieldLabel{get;set;}
   public List<SelectOption> objectOptions{get;set;}
   public List<SelectOption> sortFieldValues{get;set;}
   public List<String> selectedFieldsForAdd{get; set;}
   public List<String> selectedFieldsForRemove{get; set;}
   public List<SelectOption> fieldLst{get;set;}
   public Boolean addBtnDisable{get;set;}
   public Boolean removeBtnDisable{get;set;}
   public Boolean processBtnDisable{get;set;}
   public List<Sobject> fetchRecords{get;set;}

   public ClassForAssessment(){
      fieldPage = false;
      show = true;
      objectOption();
        
   }

   public void objectOption(){
         objectOptions = new List<SelectOption>();
         objectOptions.add(new SelectOption('----None----',' ----None----'));
         for(Schema.SObjectType thisObj : globaldesc.values()) {
            Schema.DescribeSObjectResult describeSObjectResultObj = thisObj.getDescribe();
            if(describeSObjectResultObj.isCustom()){
                objectOptions.add(new SelectOption(describeSObjectResultObj.getName(), describeSObjectResultObj.getLabel()));
            }
         }
         for(String val : System.Label.Standard_List_Controllers.split(',')){
            objectOptions.add(new SelectOption(val,val));
         }
         objectOptions.sort();
   }

   public void resetBtn() {
      if(selectedSobject != '----None----'){
         fieldLabel = globaldesc.get(selectedSobject).getDescribe().getLabel();
         show = False; 
         fieldPage = true;
         fieldValues();
      }
      else{
        show = true; 
        fieldPage = false;
      }
   }

   public void defaultNone(){
      selectedSobject = '----None----';
      show = true;
      fieldPage = false;
   }
   
  
   public void fieldValues(){
      List<SelectOption> fieldValue = new List<SelectOption>();
         Map<String, Schema.sObjectField> fieldmap = globaldesc.get(selectedSobject).getDescribe().fields.getMap();
           //fields:- Access the fields member variable of an sObject token with a field member variable
            Set<String> fieldSet = fieldmap.keySet();
            for(String field:fieldSet){
               SObjectField sObjFields = fieldmap.get(field);
               DescribeFieldResult selectedField = sObjFields.getDescribe(); 
               fieldValue.add(new SelectOption(selectedField.getLabel(),selectedField.getLabel()));
            }      
            sortFieldValues = sortSelectOptionList(fieldValue);  
            addBtnDisable = false;
            removeBtnDisable = true;
            processBtnDisable = true;
            fieldLst = new List<selectoption>();
   }

      public List<SelectOption> sortSelectOptionList(List<SelectOption> fieldValue)
      {
         List<string> sortable = new  List<string>();
         for(SelectOption so: fieldValue)
         {
            // replace blank with '_!' so we know the final split will have two components
            sortable.Add((string.isblank(so.getLabel())?'_!':so.getLabel()) + '@!@' + (string.isblank(so.getValue())?'_!':so.getValue()));
         }
         // sort the list
         sortable.sort();
         System.debug(sortable);
         List<SelectOption> targetList = new  List<SelectOption>();
         // split the value/name components and re create the list
         for(string s: sortable)
         {
                  targetList.Add(new  SelectOption(s.split('@!@')[1].replace('_!',''), s.split('@!@')[0].replace('_!','')));
         }
         return targetList;
      }

   public void addFields(){
      if(selectedFieldsForAdd.size() != 0){
         if(fieldLst == null){
            fieldLst = new List<SelectOption>();
         }
            for(String val : selectedFieldsForAdd){
               for(Integer i=0; i< sortFieldValues.size(); i++){
                  if(val == sortFieldValues[i].getValue()){
                     sortFieldValues.remove(i);
                     fieldLst.add(new SelectOption(val, val));
                  }
               }
            }
            fieldLst = sortSelectOptionList(fieldLst);   
            if(sortFieldValues.size()==0){
               addBtnDisable = true;
            }
            else{
               addBtnDisable = false;
            }
            removeBtnDisable = false;
            processBtnDisable = false;
      }
      
   }

   public void removeFields(){
      if(selectedFieldsForRemove.size() > 0){
         for(String val : selectedFieldsForRemove){
            for(Integer i=0; i< fieldLst.size(); i++){
               if(val == fieldLst[i].getValue()){
                  fieldLst.remove(i);
                  sortFieldValues.add(new SelectOption(val, val));
               }
            }
         }        
       sortFieldValues = sortSelectOptionList(sortFieldValues);  
      if(fieldLst.size() == 0){
         removeBtnDisable = true;
      } 
      else{
         removeBtnDisable = false;
      }
       addBtnDisable = false;
       processBtnDisable = false;
      }  
   } 

   public void displayRecords(String selectedSobject,List<SelectOption> fieldLst){
      String queryRecords = 'SELECT' + fieldLst + 'FROM' + selectedSobject;
      List<sObject> fetchRecords = database.query(queryRecords);
      System.debug(fetchRecords);
   }

   public void processBtn(){
      displayRecords(selectedSobject,fieldLst);
   }
}

   

