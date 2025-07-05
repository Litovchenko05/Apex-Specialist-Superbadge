@isTest
public with sharing class MaintenanceRequestHelperTest {
    
   private static final string STATUS_NEW = 'New';
   private static final string WORKING = 'Working';
   private static final string CLOSED = 'Closed';
   private static final string REPAIR = 'Repair';
   private static final string REQUEST_ORIGIN = 'Web';
   private static final string REQUEST_TYPE = 'Routine Maintenance';
   private static final string REQUEST_SUBJECT = 'Testing subject';    
    
   private static Equipment_Maintenance_Item__c createWorkPart(id equipmentId,id requestId){
       Equipment_Maintenance_Item__c workPart = new Equipment_Maintenance_Item__c(Equipment__c = equipmentId,
                                                                           Maintenance_Request__c = requestId);
       return workPart;
   } 
    
   private static Case createMaintenanceRequest(id vehicleId, id equipmentId){
       case maintenanceRequest = new case(Type=REPAIR,
                         Status=STATUS_NEW,
                         Origin=REQUEST_ORIGIN,
                         Subject=REQUEST_SUBJECT,
                         Equipment__c=equipmentId,
                         Vehicle__c=vehicleId);
       return maintenanceRequest;
   }
    
    @isTest private static void testPositive(){
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test Vehicle');
            insert vehicle;
    
            // Equipment with diferent cycles
            List<Product2> equipmentList = new List<Product2>{
                new Product2(Name = 'Equipment A', Maintenance_Cycle__c = 90, Replacement_Part__c = true),
                new Product2(Name = 'Equipment B', Maintenance_Cycle__c = 60, Replacement_Part__c = true),
            new Product2(Name = 'Equipment C', Maintenance_Cycle__c = 120, Replacement_Part__c = true)
        };
        insert equipmentList;

        // Create an open Maintenance Request
        Case req = new Case(
            Status = 'Open',
            Subject = 'Test Maintenance',
            Type = 'Repair',
            Vehicle__c = vehicle.Id
        );
        insert req;
        
        //Link items
        List<Equipment_Maintenance_Item__c> items = new List<Equipment_Maintenance_Item__c>();
        for (Product2 eq : equipmentList) {
            items.add(new Equipment_Maintenance_Item__c(
                Equipment__c = eq.Id,
                Maintenance_Request__c = req.Id
            ));
        }
        insert items;
        
        
        Case request = [SELECT Id, Status, Vehicle__c, Type FROM Case LIMIT 1];
        
        Test.startTest();
        request.Status = 'Closed';
        update request;
        Test.stopTest();

        List<Case> followUps = [SELECT Id, Type, Subject, Vehicle__c, Date_Reported__c FROM Case WHERE Type = 'Routine Maintenance'];
        System.assertEquals(1, followUps.size());
        System.assertNotEquals(null, followUps[0].Subject);
        System.assertEquals(request.Vehicle__c, followUps[0].Vehicle__c);
        System.assertEquals(Date.today(), followUps[0].Date_Reported__c);
    }
    
	@isTest
    static void testNegative() {
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test Vehicle');
        insert vehicle;
    
        // Equipment with diferent cycles
        List<Product2> equipmentList = new List<Product2>{
            new Product2(Name = 'Equipment A', Maintenance_Cycle__c = 90, Replacement_Part__c = true),
            new Product2(Name = 'Equipment B', Maintenance_Cycle__c = 60, Replacement_Part__c = true),
            new Product2(Name = 'Equipment C', Maintenance_Cycle__c = 120, Replacement_Part__c = true)
        };
        insert equipmentList;

        // Create an open Maintenance Request
        Case req = new Case(
            Status = 'Open',
            Subject = 'Testing Testing',
            Type = 'Electronic',
            Vehicle__c = vehicle.Id
        );
        insert req;
        
        //Link items
        List<Equipment_Maintenance_Item__c> items = new List<Equipment_Maintenance_Item__c>();
        for (Product2 eq : equipmentList) {
            items.add(new Equipment_Maintenance_Item__c(
                Equipment__c = eq.Id,
                Maintenance_Request__c = req.Id
            ));
        }
        insert items;

        Test.startTest();
        req.Status = 'Closed';
        update req;
        Test.stopTest();

        List<Case> followUps = [SELECT Id FROM Case WHERE Id != :req.Id AND Type = 'Routine Maintenance'];
        System.assertEquals(0, followUps.size());
    }
    
    @isTest
    static void testBulkCase() {
       list<Vehicle__C> vehicleList = new list<Vehicle__C>();
       list<Product2> equipmentList = new list<Product2>();
       list<Equipment_Maintenance_Item__c> workPartList = new list<Equipment_Maintenance_Item__c>();
       list<case> requestList = new list<case>();
       list<id> oldRequestIds = new list<id>();
       
       for(integer i = 0; i < 300; i++){
          vehicleList.add(new Vehicle__C(name = 'Vehicle ' + i));
          equipmentList.add(new product2(name = 'SuperEquipment',
                                        lifespan_months__C = 10,
                                        maintenance_cycle__C = 10,
                                        replacement_part__c = true));
       }
       insert vehicleList;
       insert equipmentList;
       
       for(integer i = 0; i < 300; i++){
           requestList.add(createMaintenanceRequest(vehicleList.get(i).id, equipmentList.get(i).id));
       }
       insert requestList;
       
       for(integer i = 0; i < 300; i++){
           workPartList.add(createWorkPart(equipmentList.get(i).id, requestList.get(i).id));
       }
       insert workPartList;
       
       test.startTest();
       for(case req : requestList){
           req.Status = CLOSED;
           oldRequestIds.add(req.Id);
       }
       update requestList;
       test.stopTest();
       
       list<case> allRequests = [select id
                                from case
                                where status =: STATUS_NEW];
       
       list<Equipment_Maintenance_Item__c> workParts = [select id
                                                       from Equipment_Maintenance_Item__c
                                                       where Maintenance_Request__c in: oldRequestIds];
       
       system.assert(allRequests.size() == 300);        
    }
}    