@IsTest
private class WarehouseCalloutServiceTest {
    
    @isTest static void testCalloutSuccess() {

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            WarehouseCalloutService.runWarehouseSync();
        Test.stopTest();

        List<Product2> products = [SELECT Name, Warehouse_SKU__c, Cost__c, Replacement_Part__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c FROM Product2];

        System.assert(products.size() > 0);
        for (Product2 p : products) {
            System.assertEquals(true, p.Replacement_Part__c);
            System.assertNotEquals(null, p.Warehouse_SKU__c);
            System.assert(p.Cost__c == 5000);
        }
    }

}