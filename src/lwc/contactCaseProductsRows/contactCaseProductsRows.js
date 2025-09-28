import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getContactProductByContactId from '@salesforce/apex/CTRL_ContactCase.getContactProductByContactId';
import getProductPlans from '@salesforce/apex/CTRL_ProductPlan.getProductPlans';
import upsertContactProducts from '@salesforce/apex/CTRL_ContactCase.upsertContactProducts';
import deleteContactProducts from '@salesforce/apex/CTRL_ContactCase.deleteContactProducts';

export default class ContactCaseProductsRows extends NavigationMixin(LightningElement) {
    @api contactId;
    @api contactAllowMultipleProduct;
    @api contactProductId;
    @api contactHomeLocation;
    @api contactDiscountApplied;
    @track error;
    areActionsAvailable = false;
    contactProducts = [];
    wiredContactProducts = [];
    productPlans = [];
    deletedRecords = [];
    _planTypeOptions = [];
    _planTypeCloned = [];

    @wire(getContactProductByContactId, {contactId: '$contactId'})
    wiredContactProduct(value){
        this.wiredContactProducts = value;
        const { data, error } = value;
        if(data){
            this.contactProducts = data;
            this.setLoadSpinnerStatus();
        }else if(error){
            this.error = error;
            this.contactProducts = undefined;
            console.log(error);
        }
    }

    @wire(getProductPlans, {productId: '$contactProductId', countryId: '$contactHomeLocation'})
    wiredProductPlans({ data, error }){
        if(data){
            this.productPlans = data;
            let result = this.productPlans.map(prodPlan => prodPlan.Plan_Types__c);
            this.planTypeOptions = result;
        }else if(error){
            this.error = error;
            this.productPlans = undefined;
            console.log(error);
        }
    }

    checkSelectedPlan(event){
        let selectedPlan = event.target.value;
        let index = event.target.dataset.index;
        const records = this.productPlans;
        const prodPlanType = records.filter(plan => plan.Plan_Types__c === selectedPlan)[0];
        if(typeof prodPlanType !== 'undefined'){
            let items = Object.assign([], this.contactProducts);
            let item = Object.assign({}, items[index]);
            if(item.Plan_Type__c == null || item.Plan_Type__c !== selectedPlan){
                item.Price__c = prodPlanType.Standard_Price__c;
                item.Plan_Type__c = selectedPlan;
                items[index] = item;
                this.contactProducts = items;
                this.checkActionsAvailableStatus();
            }
        }
    }

    checkIfContactAllowsSelectedPlan(records, selectedPlan){
        const contactProdsSelectedPlan = records.filter(contactProduct => contactProduct.Plan_Type__c === selectedPlan);
        return (!contactAllowMultipleProduct && contactProdsSelectedPlan.length > 0);
    }

    setPriceChangesInRecord(event){
        const newPrice = event.target.value;
        const index = event.target.dataset.index;
        let items = Object.assign([], this.contactProducts);
        let item = Object.assign({}, items[index]);
        if(item.Price__c == null || item.Price__c != newPrice){
            item.Price__c = newPrice;
            items[index] = item;
            this.contactProducts = items;
            this.checkActionsAvailableStatus();
        }
    }

    @api saveRecords(){
        upsertContactProducts({contactProducts: this.contactProducts}).then(result => {
            return deleteContactProducts({contactProducts: this.deletedRecords})
        }).then((result) => {
            this.deletedRecords = [];
            this.retrieveContactProducts();
            this.areActionsAvailable = false;
            this.setActionAvailableBtnStatus(this.areActionsAvailable);
            this.setLoadSpinnerStatus();
        }).catch((error => {
            this.error = error;
            console.log(error);
        }))
    }

    async retrieveContactProducts(){
        try{
            await refreshApex(this.wiredContactProducts);
        }catch(error){
            this.error = error;
            console.error('Error fetching Contact Products:', error);
        }
    }

    @api cancelChanges(){
        this.contactId = this.contactId;
        this.setLoadSpinnerStatus();
        this.areActionsAvailable = false;
        this.setActionAvailableBtnStatus(this.areActionsAvailable);
    }

    redirectToProductPlan(event){
        const prodPlanName = event.target.value;
        const records = this.productPlans;
        const prodPlanType = records.filter(plan => plan.Plan_Types__c === prodPlanName)[0];
        this.navigateToRecordPage(prodPlanType.Id);
    }

    redirectToRecord(event){
        const recordId = event.target.value;
        this.navigateToRecordPage(recordId);
    }

    navigateToRecordPage(recordId){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        }).then(url => {
             window.open(url, "_blank");
        });
    }

    removeRecord(event){
        const index = event.target.value;
        let records = [...this.contactProducts];
        let recordToDelete = records[index];
        if(typeof recordToDelete.Id !== 'undefined'){
            this.deletedRecords.push(records[index]);
            this.checkActionsAvailableStatus();
        }
        records.splice(index, 1);
        this.contactProducts = records;
    }

    addNewRecord(){
        var records = [...this.contactProducts];
        records.push({Contact__c: this.contactId, Product__c: this.contactProductId, Plan_Type__c: null, Price__c: null, Discount__c: this.contactDiscountApplied});
        this.contactProducts = records;
        this.checkActionsAvailableStatus();
    }

    checkActionsAvailableStatus(){
       if(!this.areActionsAvailable){
           this.areActionsAvailable = true;
           this.setActionAvailableBtnStatus(this.areActionsAvailable);
       }
    }

    setLoadSpinnerStatus(){
        var selectedEvent = new CustomEvent('setspinnerstatus', {detail: {status: false}});
        this.dispatchEvent(selectedEvent);
    }

    setActionAvailableBtnStatus(eventStatus){
        var selectedEvent = new CustomEvent('setactionavailablebtnstatus', {detail: {status: eventStatus}});
        this.dispatchEvent(selectedEvent);
    }

    @api
    get planTypeOptions(){
        return this._planTypeOptions;
    }

    set planTypeOptions(value){
        this._planTypeOptions = this.setPlayTypeValues(value);
    }

    setPlayTypeValues(values){
        var planTypeOptions = [];
        planTypeOptions.push({label: '--None--', value: null});
        for(var index in values){
            planTypeOptions.push({label: values[index], value: values[index]});
        }
        return planTypeOptions;
    }

    setDiscountChangesInRecord(event){
        const newDiscount = event.target.value;
        const index = event.target.dataset.index;
        let items = Object.assign([], this.contactProducts);
        let item = Object.assign({}, items[index]);
        if(item.Discount__c == null || item.Price__c != newDiscount){
            item.Discount__c = (newDiscount !== '' || newDiscount)? newDiscount: null;
            item.Price__c = (newDiscount !== '' || newDiscount)?
                item.Price__c - (item.Price__c * newDiscount) / 100: item.Price__c;
            items[index] = item;
            this.contactProducts = items;
            this.checkActionsAvailableStatus();
        }
    }
}