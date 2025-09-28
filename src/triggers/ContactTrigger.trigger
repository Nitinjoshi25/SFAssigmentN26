trigger ContactTrigger on Contact (before update, after update){
    if(Trigger.isBefore){
        TH_Contact.checkIfTheContactHasMoreThanOneOfTheSamePlans(Trigger.new, Trigger.oldMap);
    }else{
        TH_Contact.setIfDiscountAppliedChange(Trigger.newMap, Trigger.oldMap);
    }
}