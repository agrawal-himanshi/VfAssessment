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
    @track displayRecords=[];
    @track records;
    @track totalRecords;
    @track totalPages;
    @track columns;
    @track values;
    @track showSpinner;
    @track sortBy;
    @track sortingDirection;
    @track paginationButtons = [];
    searchName = '';
    searchItem = false;
    @track selectedRows = [];

    
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
        recordSizeList.push({'label':'15', 'value':'15'});
        recordSizeList.push({'label':'20', 'value':'20'});
        recordSizeList.push({'label':'50', 'value':'50'});
        return recordSizeList;
    }

    handleNavigation(event){
        let buttonName = event.target.label;
        if(buttonName == 'First') {
            this.pageNumber = 1;
        }else if(buttonName == 'Last') {
            this.pageNumber = this.totalPages;
        }
        this.processRecords();
    }

    handlePageChange(event) {
        let selectedPage = parseInt(event.target.label);
        if (!isNaN(selectedPage)) {
            this.pageNumber = selectedPage;
            this.startIndex = (selectedPage - 1) * parseInt(this.pageNumber);
            this.endIndex = this.startIndex + parseInt(this.pageNumber);
            this.processRecords();
        }   
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
        return 'Total Records - ' + this.totalRecords + ' | Page No. - ' + this.pageNumber + '/' + this.totalPages;
    }

    processRecords() {
        var uiRecords = [];
        var startLoop = ((this.pageNumber - 1) * Number(this.recordSize));
        var endLoop =  (this.pageNumber * Number(this.recordSize) >= this.totalRecords) ? this.totalRecords : this.pageNumber * Number(this.recordSize);
        for(var i = startLoop; i < endLoop; i++) {
            uiRecords.push(JSON.parse(JSON.stringify(filteredRecords[i])));
        }
        this.displayRecords = JSON.parse(JSON.stringify(uiRecords));
        this.generatePaginationButtons();
    }

    fetchRecords(event) {
        this.showSpinner = true;
        fetchRecords({
            objectName : this.selectedObject,
            fieldsList : this.selectedFields
        })
        .then(result => {
            if(result != null && result != undefined) {
                console.log(result);
                this.records = JSON.parse(JSON.stringify(result));
                console.log(this.records);
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
                    columnList.push({'label': fieldsColumn[j].label, 'fieldName': fieldsColumn[j].value, 'type': fieldsColumn[j].datatype, 'sortable': true});
                }
                this.columns = columnList;
                this.isNameField = result.nameField;
                    if (this.isNameField) {
                        this.searchItem = false;
                    } else {
                        this.searchItem = true;
                    }
            }
            const accordion = this.template.querySelector('.pagination-accordion');
            accordion.activeSectionName = 'B';
            this.generatePaginationButtons();
            this.showSpinner = false;
        }).catch(error => {
            console.log(error);
            if(error && error.body && error.body.message)
                this.showNotification(error.body.message, 'error');
            this.showSpinner = false;
        })
    }

    generatePaginationButtons() {
        this.paginationButtons = [];
        let startPage = this.pageNumber - 2;
        let endPage = this.pageNumber + 2;

        for (let i = startPage; i <= endPage; i++) {
            if (i >= 1 && i <= this.totalPages) {
                let button = {
                    page: '' + i,
                    isDisabled: false,  
                    variant: 'brand-outline'
                };
                this.paginationButtons.push(button);
            } else {
                let button = {
                    page: '-',
                    isDisabled: true,
                    variant: 'brand-outline'
                };
                this.paginationButtons.push(button);
            }
        }
        this.paginationButtons[2].variant = 'brand';
        if (!(this.data.length > 0)) {
            this.paginationButtons[2].page = 1;
            this.paginationButtons[2].isDisabled = true;
        }
        console.log(this.paginationButtons);
        
    }

    handleKeyUp(event) {
        const searchTerm = event.target.value.toLowerCase();
        if (searchTerm) {
            this.filteredRecords = this.records.filter(record => 
                record[this.isNameField] && 
                record[this.isNameField].toLowerCase().includes(searchTerm)
            );
        } else {
            this.filteredRecords = this.records;
        }
        this.totalRecords = this.filteredRecords.length;
        this.totalPages = Math.ceil(this.totalRecords / Number(this.recordSize));
        this.pageNumber = 1; // Reset to first page
        this.processRecords();
    }
    

    handleRowSelection(event) {
        const selectedRowss = event.detail.selectedRows;
        this.selectedRows = selectedRowss;
        console.log('Selected rows:', this.selectedRows);
    }

    doSorting(event) {
        console.log(event.detail);
        this.sortBy = event.detail.fieldName;
        this.sortingDirection = event.detail.sortDirection;
        console.log(this.sortBy);
        console.log(this.sortingDirection);        
        this.sortData(this.sortBy, this.sortingDirection);
        this.processRecords(); 
    }
    
    sortData(fieldname, direction) {
        console.log('in sort data');
        console.log('fieldname: ' + fieldname);
        console.log('direction: ' + direction);
        console.log('this.displayRecords before sorting: ' + JSON.stringify(this.records));
        let isReverse = direction === 'asc' ? 1 : -1; 
        
        this.records.sort((x, y) => {
            let xValue = x[fieldname] || ''; 
            let yValue = y[fieldname] || '';
            xValue = xValue.toLowerCase();
            yValue = yValue.toLowerCase();
            if (xValue < yValue) return -isReverse;
            if (xValue > yValue) return isReverse;
            return 0; 
        });
        
        console.log('this.displayRecords after sorting: ' + JSON.stringify(this.displayRecords));
    }
    
    showNotification(message, variant) {
        const evt = new ShowToastEvent({
            'message': message,
            'variant': variant
        });
        this.dispatchEvent(evt);
    }
}
