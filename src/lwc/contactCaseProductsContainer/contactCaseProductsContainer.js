import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT from "@salesforce/schema/Case.ContactId";
import CONTACT_NAME from "@salesforce/schema/Case.Contact.Name";
import CONTACT_HOME_LOCATION_NAME from "@salesforce/schema/Case.Contact.Home_Location__r.Name";
import CONTACT_PRODUCT_NAME from "@salesforce/schema/Case.Contact.Product__r.Name";
import CONTACT_PRODUCT from "@salesforce/schema/Case.Contact.Product__c";
import CONTACT_SAME_PLAN_PRODUCT from "@salesforce/schema/Case.Contact.Allow_Multiple_Product_With_Same_Plan__c";
import CONTACT_HOME_LOCATION from "@salesforce/schema/Case.Contact.Home_Location__c";
import CONTACT_DISCOUNT_APPLIED from "@salesforce/schema/Case.Contact.Discount_Applied__c";

const fields = [CONTACT_PRODUCT_NAME, CONTACT_HOME_LOCATION, CONTACT_HOME_LOCATION_NAME, CONTACT_NAME,
                CONTACT, CONTACT_SAME_PLAN_PRODUCT, CONTACT_PRODUCT, CONTACT_DISCOUNT_APPLIED];

export default class ContactCaseProductsContainer extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track areActionsAvailable = false;

    @wire(getRecord, {recordId: "$recordId", fields})
    case;

    connectedCallback(){}

    get contactHomeLocationName(){
        return getFieldValue(this.case.data, CONTACT_HOME_LOCATION_NAME);
    }

    get contactProduct(){
        return getFieldValue(this.case.data, CONTACT_PRODUCT_NAME);
    }

    get contactName(){
        return getFieldValue(this.case.data, CONTACT_NAME);
    }

    get contactId(){
        return getFieldValue(this.case.data, CONTACT);
    }

    get contactAllowMultipleProduct(){
        return getFieldValue(this.case.data, CONTACT_SAME_PLAN_PRODUCT);
    }

    get contactProductId(){
        return getFieldValue(this.case.data, CONTACT_PRODUCT);
    }

    get contactHomeLocation(){
        return getFieldValue(this.case.data, CONTACT_HOME_LOCATION);
    }

    get contactDiscountApplied(){
        return getFieldValue(this.case.data, CONTACT_DISCOUNT_APPLIED);
    }

    setSpinnerStatus(event){
        this.isLoading = event.detail.status;
    }

    setActionAvailableBtnStatus(event){
        this.areActionsAvailable = event.detail.status;
    }

    saveRecords(){
        this.isLoading = true;
        let contactCaseProductRows = this.template.querySelector('c-contact-case-products-rows');
        contactCaseProductRows.saveRecords();
    }

    cancelChanges(){
        this.isLoading = true;
        let contactCaseProductRows = this.template.querySelector('c-contact-case-products-rows');
        contactCaseProductRows.cancelChanges();
    }
}