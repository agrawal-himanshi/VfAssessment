import { LightningElement } from 'lwc';
import paymentAuthorize from '@salesforce/resourceUrl/paymentAuthorize';

export default class PaymentGatewayIntegration extends LightningElement {
    myCustomIconUrl = paymentAuthorize;

    show = true;
    lastClickedDiv = null;  

    monthOptions = [
        { label: 'January', value: '01' },
        { label: 'February', value: '02' },
        { label: 'March', value: '03' },
        { label: 'April', value: '04' },
        { label: 'May', value: '05' },
        { label: 'June', value: '06' },
        { label: 'July', value: '07' },
        { label: 'August', value: '08' },
        { label: 'September', value: '09' },
        { label: 'October', value: '10' },
        { label: 'November', value: '11' },
        { label: 'December', value: '12' }
    ]; 

    yearOptions = [
        { label: '2024', value: '2024' },
        { label: '2025', value: '2025' },
        { label: '2026', value: '2026' },
        { label: '2027', value: '2027' },
        { label: '2028', value: '2028' },
        { label: '2029', value: '2029' },
        { label: '2030', value: '2030' }
    ]; 

    checkMe(event) {
        const div = event.currentTarget;
        if (this.lastClickedDiv && this.lastClickedDiv !== div) {
            this.lastClickedDiv.classList.remove('highlighted');
        }
        div.classList.toggle('highlighted');
        this.lastClickedDiv = div;
        console.log("Div clicked, performing action...");
        this.show = ! this.show;
    }



}