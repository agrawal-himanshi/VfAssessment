import { LightningElement, track } from 'lwc';
import fetchObjectList from '@salesforce/apex/ClientSidePaginationController.fetchObjectList';
import fetchFieldsList from '@salesforce/apex/ClientSidePaginationController.fetchFieldsList';
import fetchRecords from '@salesforce/apex/ClientSidePaginationController.fetchRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ClientSidePagination extends LightningElement {

    @track objectList;
    @track selectedObject;
    @track fieldsList;
    @track selectedFields;
    @track pageNumber = 1;
    @track recordSize = '10';
    @track displayRecords;
    @track records;
    @track totalRecords;
    @track totalPages;
    @track columns;
    @track values;
    @track showSpinner;

    constructor() {
        super();
        this.showSpinner = true;
        fetchObjectList()
        .then(result => {
            this.objectList = result;
            this.showSpinner = false;
        }).catch(error => {
            console.log(error);
            this.showSpinner = false;
        })
    }

    handleObjectChange(event) {
        this.selectedFields = [];
        this.values = [];
        this.showSpinner = true;
        this.selectedObject = event.detail.value;
        fetchFieldsList({
            objectName : event.detail.value
        })
        .then(result => {
            this.fieldsList = result;
            this.showSpinner = false;
        }).catch(error => {
            console.log(error);
            this.showSpinner = false;
        })
    }

    handleFieldsChange(event) {
        this.selectedFields = event.detail.value;
    }

    get getRecordSizeList() {
        let recordSizeList = [];
        recordSizeList.push({'label':'10', 'value':'10'});
        recordSizeList.push({'label':'25', 'value':'25'});
        recordSizeList.push({'label':'50', 'value':'50'});
        recordSizeList.push({'label':'100', 'value':'100'});
        return recordSizeList;
    }

    handleNavigation(event){
        let buttonName = event.target.label;
        if(buttonName == 'First') {
            this.pageNumber = 1;
        } else if(buttonName == 'Next') {
            this.pageNumber = this.pageNumber >= this.totalPages ? this.totalPages : this.pageNumber + 1;
        } else if(buttonName == 'Previous') {
            this.pageNumber = this.pageNumber > 1 ? this.pageNumber - 1 : 1;
        } else if(buttonName == 'Last') {
            this.pageNumber = this.totalPages;
        }
        this.processRecords();
    }

    handleRecordSizeChange(event) {
        this.recordSize = event.detail.value;
        this.pageNumber = 1;
        this.totalPages = Math.ceil(this.totalRecords / Number(this.recordSize));
        this.processRecords();
    }

    get disablePreviousButtons() {
        if(this.selectedFields == undefined || this.selectedFields.length == 0 || this.pageNumber == 1)
            return true;
    }

    get disableNextButtons() {
        if(this.selectedFields == undefined || this.selectedFields.length == 0 || this.pageNumber == this.totalPages)
            return true;
    }

    get disableCombobox() {
        if(!this.records || this.records.length == 0)
            return true;
    }

    get recordViewMessage() {
        return 'Total Records - ' + this.totalRecords + ' | Current Page - ' + this.pageNumber + '/' + this.totalPages;
    }

    processRecords() {
        var uiRecords = [];
        var startLoop = ((this.pageNumber - 1) * Number(this.recordSize));
        var endLoop =  (this.pageNumber * Number(this.recordSize) >= this.totalRecords) ? this.totalRecords : this.pageNumber * Number(this.recordSize);
        for(var i = startLoop; i < endLoop; i++) {
            uiRecords.push(JSON.parse(JSON.stringify(this.records[i])));
        }
        this.displayRecords = JSON.parse(JSON.stringify(uiRecords));
    }

    fetchRecords(event) {
        this.showSpinner = true;
        fetchRecords({
            objectName : this.selectedObject,
            fieldsList : this.selectedFields
        })
        .then(result => {
            if(result != null && result != undefined) {
                this.records = JSON.parse(JSON.stringify(result));
                var uiRecords = [];
                for(var i = 0; i < Number(this.recordSize); i++) {
                    uiRecords.push(JSON.parse(JSON.stringify(result[i])));
                }
                this.displayRecords = JSON.parse(JSON.stringify(uiRecords));
                this.totalRecords = result.length;
                this.totalPages = Math.ceil(result.length / Number(this.recordSize));

                var fieldsColumn = [];
                for(var i = 0; i < this.fieldsList.length; i++) {
                    for(var j = 0; j < this.selectedFields.length; j++) {
                        if(this.fieldsList[i].value == this.selectedFields[j]) {
                            fieldsColumn.push(this.fieldsList[i]);
                        }
                    }
                }

                var columnList = [];
                for(var j = 0; j < fieldsColumn.length; j++) {
                    columnList.push({'label': fieldsColumn[j].label, 'fieldName': fieldsColumn[j].value, 'type': fieldsColumn[j].datatype});
                }
                this.columns = columnList;
            }
            const accordion = this.template.querySelector('.pagination-accordion');
            accordion.activeSectionName = 'B';
            this.showSpinner = false;
        }).catch(error => {
            console.log(error);
            if(error && error.body && error.body.message)
                this.showNotification(error.body.message, 'error');
            this.showSpinner = false;
        })
    }

    showNotification(message, variant) {
        const evt = new ShowToastEvent({
            'message': message,
            'variant': variant
        });
        this.dispatchEvent(evt);
    }
}
