@isTest
public class EmailTemplateTaskWhoDataControllerTest {
    static testmethod void testGetDataDisplayInHtml()
    {
        TestUtil.disableCallouts();
        Test.startTest();
                
        Account acc = new Account(Name = 'APEX Test Account',  Billing_Country__c = 'USA', Billing_State_Province__c = 'CA', 
            Billing_St__c = 'Street 1', Billing_St_Line_2__c = 'Street 2');
        insert acc;
        
        Contact cont = new Contact(LastName = 'Test Contact', AccountId = acc.Id, Billing_Country__c = 'USA', Billing_State_Province__c = 'CA', 
            Billing_St__c = 'Street 1', Billing_St_Line_2__c = 'Street 2');
        insert cont;
        
        Task t = new Task(WhoId = cont.Id, Type = 'Email Sent', Status = 'Test', 
                          Subject = 'Concur Test', WhatId = acc.Id);

        insert t;
        
        String listOfFieldApiNames = 'Account.Name,FirstName,LastName';
		String listOfFieldLabels = 'Account Name,First Name,Last Name';
        
        Test.stopTest();
        
        EmailTemplateTaskWhoDataController ettwdc = new EmailTemplateTaskWhoDataController();
        ettwdc.getDataDisplayInHtml();
        ettwdc.attrTaskWhoId = cont.Id;
    	ettwdc.attrListOfFieldApiNames = listOfFieldApiNames;
    	ettwdc.attrListOfFieldLabels = listOfFieldLabels;
        ettwdc.getDataDisplayInHtml();
        
        listOfFieldApiNames = 'Account.Name,FirstName,NoSuchField';
        ettwdc.attrListOfFieldApiNames = listOfFieldApiNames;
        ettwdc.getDataDisplayInHtml();
    }
}