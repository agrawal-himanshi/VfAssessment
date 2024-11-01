public class ClassForAssessment {
   Map<String, Schema.SObjectType> globaldesc = Schema.getGlobalDescribe();
   //global variable to get schema and use it again and again(getGlobalDescribe() -- return type is map which has key and value where key's return type is string and Schema.SObjecType's return type is list of objects)
   public Boolean show{get;set;}
   // Boolean variable for reset button to enable and disable
   public String selectedSobject{get; set;}
   // String type variable to get and set value for Sobject which is selected from the list
   public Boolean fieldPage{get;set;}
   // Boolean variable to render on fields page
   public String objectLabel{get;set;}
   // String type variable to get the field name as API name and set it to label name
   public List<SelectOption> objectOptions{get;set;}
   // List of objects
   public List<SelectOption> sortFieldValues{get;set;}
   // list of sorted fields
   public List<String> selectedFieldsForAdd{get; set;}
   //list which is selected to add
   public List<String> selectedFieldsForRemove{get; set;}
   // list which is selected to remove
   public List<SelectOption> fieldLst{get;set;}
   // an list in which list of string is added
   public Boolean addBtnDisable{get;set;}
   // Boolean variable for add button to enable and disable
   public Boolean removeBtnDisable{get;set;}
   // Boolean variable for remove button to enable and disable
   public Boolean processBtnDisable{get;set;}
   // Boolean variable for process button to enable and disable
   public List<String> fieldOption{get;set;}
   // list of string which is used to convert list of selectoption to list of string
   public Boolean recordPage{get;set;}


   //constructor
   public ClassForAssessment(){
      fieldPage = false;
      show = true;
      objectOption();
        
   }

   //method for getting objects
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
            objectOptions.add(new SelectOption(val, val));
         }
         objectOptions.sort();
   }

   // reset button
   public void resetBtn() {
      if(selectedSobject != '----None----'){
         objectLabel = globaldesc.get(selectedSobject).getDescribe().getLabel();
         show = False; 
         fieldPage = true;
         recordPage = false;
         fieldValues();
      }
      else{
        show = true; 
        fieldPage = false;
        recordPage = false;
      }
   }

   //method to set none by click on reset button
   public void defaultNone(){
      selectedSobject = '----None----';
      show = true;
      fieldPage = false;
      recordPage = false;
   }
   
  //method to get fieldvalues
   public void fieldValues(){
      List<SelectOption> fieldValue = new List<SelectOption>();
         Map<String, Schema.sObjectField> fieldmap = globaldesc.get(selectedSobject).getDescribe().fields.getMap();
           //fields:- Access the fields member variable of an sObject token with a field member variable
            Set<String> fieldSet = fieldmap.keySet();
            for(String field : fieldSet){
               SObjectField sObjFields = fieldmap.get(field);
               DescribeFieldResult selectedField = sObjFields.getDescribe(); 
               fieldValue.add(new SelectOption(selectedField.getName(), selectedField.getLabel()));
            }      
            sortFieldValues = sortSelectOptionList(fieldValue);  
            addBtnDisable = false;
            removeBtnDisable = true;
            processBtnDisable = true;
            fieldLst = new List<selectoption>();
   }

   // method to sort fieldvalues
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

      //method to add fields
   public void addFields(){
      if(selectedFieldsForAdd.size() != 0){
         Map<String, Schema.sObjectField> fieldmap = globaldesc.get(selectedSobject).getDescribe().fields.getMap();
            for(String val : selectedFieldsForAdd){
               for(Integer i=0; i< sortFieldValues.size(); i++){
                  if(val == sortFieldValues[i].getValue()){
                     sortFieldValues.remove(i);
                     fieldLst.add(new SelectOption(val, fieldmap.get(val).getDescribe().getLabel()));
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

   //method to remove fields 
   public void removeFields(){
      if(selectedFieldsForRemove.size() > 0){
         Map<String, Schema.sObjectField> fieldmap = globaldesc.get(selectedSobject).getDescribe().fields.getMap();
         for(String val : selectedFieldsForRemove){
            for(Integer i=0; i< fieldLst.size(); i++){
               if(val == fieldLst[i].getValue()){
                  fieldLst.remove(i);
                  sortFieldValues.add(new SelectOption(val, fieldmap.get(val).getDescribe().getLabel()));
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

   //method to call when process button is clicked
   public void processBtn(){
      fieldOption = new List<String>();
      for(selectoption value : fieldLst){
         fieldOption.add(value.getValue());
      } 
      recordPage = true;
   }

}