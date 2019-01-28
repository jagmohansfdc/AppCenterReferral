/*
Helper class for AppCenterController
Code coverage included in AppCenterControllerTest class
*/
public class EmailToPartner{
    
    public void sendEmail(String taskId,String partnerName,string accId)
    {   
        List<String> toAddressList = new List<String>();  
        List<String> ccAddressList = new List<String>();
        Account acc;  
        for(Partners_Configuration__c p: [Select  Partner_Email__c from Partners_Configuration__c where Name =:partnerName])
        {
            if(p.Partner_Email__c != null)
            {
                toAddressList = p.Partner_Email__c.split(';');
            }    
        }
        //Get account details
        if(accId != null)
        {
            for(Account accObj : [Select id,Owner.Email, SOSAO__SecondAccountOwner__c,SOSAO__SecondAccountOwner__r.Email from Account where id =:accId])
            {
                if(accObj.Owner.Email != null)
                ccAddressList.add(accObj.Owner.Email);
                if(accObj.SOSAO__SecondAccountOwner__c  != null && accObj.SOSAO__SecondAccountOwner__r.Email != null)
                ccAddressList.add(accObj.SOSAO__SecondAccountOwner__r.Email);
                
                system.debug('***JN***'+ccAddressList);
            }    
        }
        system.debug('***JN 1***'+ccAddressList);
        ccAddressList.add(UserInfo.getUserEmail());
        // Create Contact
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Billing_Country__c = 'USA';
        if(toAddressList != null && toAddressList.size()> 0)
        con.Email = toAddressList[0];
        else
        con.Email = 'jagmohan.negi85@gmail.com';
        con.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GlobalExpense Service Profile').getRecordTypeId();
       
        insert con;
        // Create Email and Send
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId([select id,name from EmailTemplate where DeveloperName='App_Center_Referral_Task_Email_VF'].id);
        msg.setToAddresses(toAddressList);
        if(ccAddressList != null)
        msg.setCcAddresses(ccAddressList);
        msg.setTargetObjectId(con.Id);
        msg.setWhatId(taskId);
        msg.setSaveAsActivity(false);
        if(!Test.isRunningTest())
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
        delete con;

    }
 }