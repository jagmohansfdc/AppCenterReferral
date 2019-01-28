Public class AppCenterController {
    
    Private string recordId;    
    Public Task tsk{ get; set;}
    public String accId;
    Public String phone{get;set;}
    Public String email{get;set;}
    Public String selectedCategory{get;set;}
    Public Boolean partnerCategoryErrorMsg{get;set;}
    Public List<Selectoption> partners = new List<Selectoption>();
    //Public Boolean partnerDisabled{get;set;}
    Public String selectedPartner{get;set;}
    
    //Private Map<String,List<Partners_Configuration__c>> categoryToPartnerMap = new Map<String,List<Partners_Configuration__c>>();
    Public AppCenterController() {
        
        recordId = ApexPages.currentPage().getParameters().get('recId');
        init();
        /*
        for(Partners_Configuration__c pConfig :[Select id,name,Partner_Email__c,Partner_Category__c from Partners_Configuration__c])
        {
            if(!categoryToPartnerMap.containskey(pConfig.Partner_Category__c))
            {
                List<Partners_Configuration__c> partners = new List<Partners_Configuration__c>();
                partners.add(pConfig);
                categoryToPartnerMap.put(pConfig.Partner_Category__c,partners);
            }
            else
            categoryToPartnerMap.get(pConfig.Partner_Category__c).add(pConfig);
        }
        */
      
    }
    
    Private void init()
    {
        
        partnerCategoryErrorMsg = false;        
        Contact con;
        tsk = new Task();
        if(recordId != null && recordId.startsWith('001'))
        {         
          tsk.whatId = recordId;
          accId = recordId;
        }
        else if(recordId != null && recordId.startsWith('003'))
        {
            con = [Select id,phone,email,accountid from Contact where id =:recordId];
            tsk.whoId = con.id;
            tsk.whatId = con.accountid;
            phone = con.phone;
            email = con.email;
            accId =  con.accountid;
        }
        
        tsk.ActivityDate = System.today();
        tsk.Subject = 'Lead to Partner';
        tsk.OwnerId = UserInfo.getUserId();
        tsk.status ='Completed';
        tsk.Priority ='Normal';
        tsk.recordTypeId= Schema.SObjectType.Task.getRecordTypeInfosByName().get('App Center Referral').getRecordTypeId();
   
    }
    /*
    public List<Selectoption> getCategories()
    {
            List<Selectoption> Categories = new List<selectoption>();
            Schema.DescribeFieldResult fieldResult = Partners_Configuration__c.Partner_Category__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Categories.add(new selectOption('', '-- None --'));
            for( Schema.PicklistEntry f : ple)
            {
              Categories.add(new SelectOption(f.getLabel(), f.getValue()));
            } 
            return Categories;          
    }
    */
    public void ContactUpdated()
    {       
        if(tsk.whoId != null )
        {
            String whoIdString = tsk.whoId;
            if(whoIdString.startsWith('003'))
            {
                Contact  con = [Select id,phone,email,accountid from Contact where id =:whoIdString];
                tsk.whoId = con.id;          
                phone = con.phone;
                email = con.email;
            } 
        }
    }
    /*
    public void CategoryChanged(){
        if(selectedCategory != null && selectedCategory != '')
        partnerDisabled = true;
        else
        partnerDisabled = false;
    }
    */
    public List<SelectOption> getPartners()
    {    
    system.debug('****Jaggi 1**'+Partners);
        //List<Selectoption> Partners = new List<selectoption>();
        if(Partners != null && Partners.size() < 1)
        {
        system.debug('****Jaggi 2**'+Partners);
            Partners.add(new selectOption('', '-- None --'));   
            for(Partners_Configuration__c pConfig :[Select id,name,Partner_Email__c,Partner_Category__c from Partners_Configuration__c Order By Name ASC])
            {            
               // for(Partners_Configuration__c p :categoryToPartnerMap.get(selectedCategory)){        
                Partners.add(new selectoption(pConfig.Name,pConfig.Name));
                //}                       
            }  
        }
        return Partners; 
    }
    Public PageReference cancelTask()
    {
        pageReference pg = new pageReference('/'+recordId);
        return pg;
       
    }
    public PageReference saveTask()
    {
        if(tsk.whatId == null)
        tsk.whatId.adderror('No matches found.');
        if(tsk.ActivityDate == null)
        tsk.ActivityDate.adderror('You must enter a value');
        if(tsk.Subject == null)
        tsk.Subject.adderror('You must enter a value');        
        if(tsk.OwnerId == null)
        tsk.OwnerId.adderror('You must enter a value');
        if(tsk.WhoId == null)
        tsk.WhoId.adderror('You must enter a value');
        
        if(tsk.whatId == null || tsk.Subject == null || tsk.OwnerId == null || tsk.ActivityDate == null || tsk.WhoId == null)
        return null;
       
        if(selectedPartner == null)
        {
            partnerCategoryErrorMsg = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'App Center Partner: You must enter a value'));
            return null;
        }
       try
       {        
       system.debug('****JN***'+selectedPartner);
          // if(selectedCategory != null)
          // tsk.App_Center_Category__c = selectedCategory;
           if(selectedPartner != null)
           tsk.App_Center_Partner__c = selectedPartner;
           upsert tsk;
           EmailToPartner ep = new EmailToPartner();
           ep.sendEmail(tsk.Id,selectedPartner,accId);
       }
       catch(Exception e)
       {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is some issue while submiting this request. '));
            return null;
       }
      
        PageReference pRef = new pageReference('/'+recordId);
        return pRef;
        
    }
   
    
}