import { LightningElement, track } from 'lwc';
import boxIconResource from '@salesforce/resourceUrl/boxIconResource';

export default class BoxIntegration extends LightningElement {
    myCustomIconUrl = boxIconResource;
    lastClickedDiv = null;  
    @track path = [{ label: 'Home', value: 'root' }];

    handleDivClick(event) {
        const div = event.currentTarget;
        if (this.lastClickedDiv && this.lastClickedDiv !== div) {
            this.lastClickedDiv.classList.remove('highlighted');
        }
        div.classList.toggle('highlighted');
        this.lastClickedDiv = div;
        console.log("Div clicked, performing action...");
    }
}