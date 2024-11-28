import { LightningElement } from 'lwc';
import paymentAuthorize from '@salesforce/resourceUrl/paymentAuthorize';

export default class PaymentGatewayIntegration extends LightningElement {
    myCustomIconUrl = paymentAuthorize;

    show = true;
    lastClickedDiv = null;  
    routingNumber = ''; 
    accountNumber = ''; 
    nameOnAccount = ''; 
    errorMessage = ''; 
    cardNumber = '';
    cardMonth = ''; 
    cardYear = '';
    cvv = '';


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
        console.log(this.lastClickedDiv);
        console.log("Div clicked, performing action...");
        this.show = ! this.show;
    }

    handleChange(event){
        if (event.target.name == 'routing') {
            this.routingNumber = event.detail.value;
            console.log(this.routingNumber);
        } else if (event.target.name == 'account') {
            this.accountNumber = event.detail.value;
            console.log(this.accountNumber);
        } else if (event.target.name == 'name') {
            this.nameOnAccount = event.detail.value;
            console.log(this.nameOnAccount);
        } else if(event.target.name == 'card') {
            this.cardNumber = event.detail.value;
            console.log(this.cardNumber);
        } else if(event.target.name == 'month') {
            this.cardMonth = event.detail.value;
            console.log(this.cardMonth);
        } else if(event.target.name == 'year') {
            this.cardYear = event.detail.value;
            console.log(this.cardYear);
        } else if(event.target.name == 'cvv') {
            this.cvv = event.detail.value;
            console.log(this.cvv);
        }
    }

    handleBtnClick(){
        console.log('Button Clicked');
        if(this.show){
            console.log(this.show);
            this.authCardPayment();           
        }
        else{
            console.log(this.show); 
            this.authECheckPayment();
        }
    }

    authECheckPayment(){
        console.log('in echeck');
        const requiredFields = this.template.querySelectorAll('[data-required]');
        console.log(requiredFields);
        let allValid = true;
        let missingFields = [];

        requiredFields.forEach(field => {
            if (!field.value) {
                missingFields.push(field.label);
                allValid = false;
                console.log(missingFields);
                console.log('Fields Value are not valid')
            }
        });
        if(allValid){
            alert('successfull');
            // ECheckPayment({
            //             routingNumber: this.routingNumber,          
            //             accountNumber: this.accountNumber,
            //             nameOnAccount: this.nameOnAccount
            //     })
            //     .then( result => {     
            //         let title = result;               
            //         this.showToast('Success', title, 'success');
            //     })
            //     .catch( error => { 
            //         this.showToast('Error', error.body.message, 'error');
            //     });
        }
        else{
            alert('All Fields are Required (Missing fileds are :' + missingFields + ')');
        }
    }

    authCardPayment(){
        console.log('in card');
        const requiredFields = this.template.querySelectorAll('[data-required]');
        console.log(requiredFields);
        let allValid = true;
        let missingFields = [];

        requiredFields.forEach(field => {
            if (!field.value) {
                missingFields.push(field.label);
                allValid = false;
                console.log('Fields Value are not valid')
            }
        });
        if(allValid){
            alert('successfull');
            // cardPayment({

            // });
        }
        else{
            alert('All Fields are Required');
        }
    }



}