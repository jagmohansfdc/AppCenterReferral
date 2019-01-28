@isTest
public class AppCenterControllerTest {

    public static testMethod void testMyController() {
    Partners_Configuration__c pconfig = new Partners_Configuration__c();
    List<Selectoption> testSelectOption;
    PageReference pRefTest; 
    pconfig.Name='AppCenterTest';
   // pconfig.Partner_Category__c = 'IT Solutions';
    pconfig.Partner_Email__c = 'test@concur.com';
    insert pconfig;
    //Test Account
    Account acc = new Account(Name='Test Account');
    insert acc;
    Contact con = new Contact(LastName='lastname',accountid=acc.id, Billing_Country__c = 'USA');
    insert con;
    Task t = new Task(status='Completed',subject='Test subject',ActivityDate=System.today(),whatId = acc.id,whoid=con.id,ownerId=UserInfo.getUserId(),Priority='Normal');
    //insert t;
    
    
        PageReference pageRef = Page.AppCenterReferral;
        Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('recId', acc.id);

        AppCenterController controller = new AppCenterController();
        controller.tsk = t;
     //   controller.selectedCategory ='IT Solutions';
        controller.selectedPartner =pconfig.Name;
      //  testSelectOption = controller.getCategories();
      //  controller.CategoryChanged();
        testSelectOption = controller.getPartners();
        pRefTest = controller.saveTask();
        pRefTest = controller.cancelTask();
        controller.ContactUpdated();
        
        controller.selectedCategory = null;
        pRefTest = controller.saveTask();
        controller.selectedCategory ='IT Solutions';
        controller.selectedPartner = null;
        pRefTest = controller.saveTask();
        
         ApexPages.currentPage().getParameters().put('recId', con.id);
         controller = new AppCenterController();
      
         
        
    }
}