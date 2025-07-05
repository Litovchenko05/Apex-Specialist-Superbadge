public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> updatedCases, Map<Id,Case> oldCases) {
        List<Case> newRequests = new List<Case>();
        Set<Id> closedRequestsId = new Set<Id>();
        Map<Id, List<Equipment_Maintenance_Item__c>> equipmentsGroupById = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        
        //Filter the requests that changed his Status to Closed and that they have Type relevant
        for(Case c : updatedCases){	
            Case oldCase = oldCases.get(c.Id);
            Boolean isNowClosed = c.Status == 'Closed' && oldCase.Status != 'Closed';
            Boolean isTypeRelevant = c.Type == 'Repair' || c.Type == 'Routine Maintenance';
            
            if(isNowClosed && isTypeRelevant){
            	closedRequestsId.add(c.Id);
            }
        }
        
        // Find the Equipment Maintenance Item for every closed request
        List<Equipment_Maintenance_Item__c> itemsToClone = [SELECT Name, Equipment__c, Maintenance_Request__c
                                                            FROM Equipment_Maintenance_Item__c
                                                            WHERE Maintenance_Request__c IN :closedRequestsId];
        
        // Group the Equipment Items by Maintenance Request
        for(Equipment_Maintenance_Item__c item : itemsToClone){
            if(!equipmentsGroupById.containsKey(item.Maintenance_Request__c)){
                equipmentsGroupById.put(item.Maintenance_Request__c, new List<Equipment_Maintenance_Item__c>());
            }
            equipmentsGroupById.get(item.Maintenance_Request__c).add(item);
        }
        
        // Find the cycles for every Equipment
        Set<Id> equipmentIds = new Set<Id>();
        for (Equipment_Maintenance_Item__c item : itemsToClone) {
            equipmentIds.add(item.Equipment__c);
        }
        
        Map<Id, Integer> cyclesByEquipment = new Map<Id, Integer>();
        for (Product2 eq : [SELECT Id, Maintenance_Cycle__c FROM Product2 WHERE Id IN :equipmentIds]) {
        	cyclesByEquipment.put(eq.Id, (Integer)eq.Maintenance_Cycle__c);
        }
        
        // Find the shortest cycle Equipment for each Request and then create a new one with the Due Date updated
        Map<Id, Case> oldToNew = new Map<Id, Case>();
        for(Id oldRequestId : closedRequestsId){
        	Integer shortestCycle = NULL;

			for (Equipment_Maintenance_Item__c item : equipmentsGroupById.get(oldRequestId)) {
                Integer cycle = cyclesByEquipment.get(item.Equipment__c);
    			if (shortestCycle == NULL || cycle < shortestCycle) {
        			shortestCycle = cycle;
    			}
			}
            Date DueDate = Date.today() + shortestCycle;
            
        		Case newRequest = new Case();
            	newRequest.Vehicle__c = oldCases.get(oldRequestId).Vehicle__C;
                newRequest.Type = 'Routine Maintenance';
                newRequest.Subject = 'Follow-up Maintenance';
                newRequest.Date_Reported__c = Date.today();
            	newRequest.Date_Due__c = DueDate;
                newRequest.Status = 'New';             
                                    
                newRequests.add(newRequest);
            	oldToNew.put(oldRequestId, newRequest);
        }
        insert newRequests;
        
        List<Equipment_Maintenance_Item__c> itemsToInsert = new List<Equipment_Maintenance_Item__c>();
        
        for(Equipment_Maintenance_Item__c item : itemsToClone){
            Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c();
            newItem.Equipment__c = item.Equipment__c;
            newItem.Maintenance_Request__c = oldToNew.get(item.Maintenance_Request__c).Id;
            itemsToInsert.add(newItem);
        }
		insert itemsToInsert;        
    }         
}