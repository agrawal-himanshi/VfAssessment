import { LightningElement } from 'lwc';
import boxIconResource from '@salesforce/resourceUrl/boxIconResource';

export default class BoxIntegration extends LightningElement {
    myCustomIconUrl = boxIconResource;
}