import { LightningElement, track, wire } from 'lwc';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class MultiSelectComboBoxParent extends LightningElement {
 
    @track options = [];
    toggleEnabled ='false';
    accountRecordTypeId;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    results({ error, data }) {
        if (data) {
            this.accountRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$accountRecordTypeId", fieldApiName: TYPE_FIELD})
    picklistResults({ error, data }) {
        if (data) {
            this.options = data.values;
            console.log(this.options);
        } else if (error) {
            this.error = error;
        }
    }
    
    toggleSelectionType(event) {
        let toggleValue = event.target.checked;
        this.toggleEnabled = toggleValue;
    }
     
}
