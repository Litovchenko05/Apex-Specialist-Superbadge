public with sharing class WarehouseCalloutService implements Queueable{
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future(callout=true)
    public static void runWarehouseSync(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {
            List<Product2> equipmentToUpsert = new List<Product2>();
            List<Object> jsonResponse = (List<Object>)JSON.deserializeUntyped(response.getBody());
			
            //The json it's a List of Maps, so each element of the List it's a Map, but to be sure I cast the type. 
            for(Object record : jsonResponse){
                Map<String,Object> fields = (Map<String,Object>)record;
                Product2 equipment = new Product2();
                equipment.Replacement_Part__c = true;
                equipment.Cost__c = (Double) fields.get('cost');
                equipment.Current_Inventory__c = (Integer) fields.get('quantity');
                equipment.Lifespan_Months__c = (Integer) fields.get('lifespan');
                equipment.Maintenance_Cycle__c = (Double) fields.get('maintenanceperiod');
                equipment.Warehouse_SKU__c = (String) fields.get('sku');
                equipment.Name = (String) fields.get('name');
                
                equipmentToUpsert.add(equipment);
            }
            if(equipmentToUpsert.size() > 0){
            	upsert equipmentToUpsert Warehouse_SKU__c;
            }
        }
    }
    
    public void execute(QueueableContext context){
        runWarehouseSync();
    }
}