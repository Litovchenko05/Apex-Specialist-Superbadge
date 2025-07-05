@isTest
private with sharing class WarehouseSyncScheduleTest {
    @isTest static void WarehousescheduleTest(){
        String timeOfSchedule = '00 00 01 * * ?';
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            String jobId = System.schedule('Warehouse Schedule Test', timeOfSchedule, new WarehouseSyncSchedule());
        Test.stopTest();
        
        CronTrigger test = [SELECT Id FROM CronTrigger where NextFireTime > today];
        System.assertEquals(jobId, test.Id,'Schedule');  
    }
}