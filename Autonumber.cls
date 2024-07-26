public class opportunityAutoNumberGeneratorHandler {
    
    public static List<string> alphabets = new List<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};   
        
        public static void opportunitySeparator(List<Opportunity> listOfOpp){
            List<Opportunity> listOfOriginalOpportunities = new List<Opportunity>();
            Map<Id,List<Opportunity>> mapOfOppwithOneTimeAmendmentOpp = new Map<Id,List<Opportunity>>();
            
            Map<Id,List<Opportunity>> mapOfOppwithMonthlyChildOpportunityOpp = new Map<Id,List<Opportunity>>();
            
            For(Opportunity opp : listOfOpp){
                If(opp.Orginal_Opportunity__c == null && opp.primaryOpportunity__c == null){
                    listOfOriginalOpportunities.add(opp);
                
                
                If(opp.Orginal_Opportunity__c !=null && opp.Project_Type__c == 'Event'){
                    If(mapOfOppwithMonthlyChildOpportunityOpp.containsKey(opp.Orginal_Opportunity__c)){
                        mapOfOppwithMonthlyChildOpportunityOpp.get(opp.Orginal_Opportunity__c).add(opp);
                    }else{
                        mapOfOppwithMonthlyChildOpportunityOpp.put(opp.Orginal_Opportunity__c,new List<Opportunity>{opp});
                    }
                }
                
                If(opp.Orginal_Opportunity__c !=null && opp.Project_Type__c == 'Monthly'){
                    opp.Orginal_Opportunity__c = opp.primaryOpportunity__c;
                    If(mapOfOppwithOneTimeAmendmentOpp.containsKey(opp.primaryOpportunity__c)){
                        mapOfOppwithOneTimeAmendmentOpp.get(opp.primaryOpportunity__c).add(opp);
                    }else{
                        mapOfOppwithOneTimeAmendmentOpp.put(opp.primaryOpportunity__c,new List<Opportunity>{opp});
                    }
                }
                
                
            }
            
            If(listOfOriginalOpportunities.size() > 0){
                originalOpportunityAutoNumberCreate(listOfOriginalOpportunities);            
            }
            If(mapOfOppwithOneTimeAmendmentOpp.size() > 0){
                amendmentOppAutoNumberCreate(mapOfOppwithOneTimeAmendmentOpp);
            }
            If(mapOfOppwithMonthlyChildOpportunityOpp.size() > 0){
                childOppAutoNumberCreate(mapOfOppwithMonthlyChildOpportunityOpp);
            }
            
        }
    
    public static void originalOpportunityAutoNumberCreate(List<Opportunity> listOfOriginalOpp){
        Integer sfOppCount = [SELECT Count() FROM Opportunity WHERE Orginal_Opportunity__c = null AND primaryOpportunity__c = null];
        Integer counter = 1;
        
        Map<Id,List<Opportunity>> mapOfOppwithAmendmentOpp = new Map<Id,List<Opportunity>>();
        For(Opportunity opp : listOfOriginalOpp){
            If(opp.Orginal_Opportunity__c == null){
                opp.Auto_Number_PK__c = String.valueOf(sfOppCount + counter).leftPad(6, '0') + '-00-0';
                counter ++;
            }
        }
    }
    
    public static void amendmentOppAutoNumberCreate(Map<Id,List<Opportunity>> mapOfOppwithAmendmentOpp){
        system.debug('AMENDMENT OPPORTUNITY METHOD INVOKED');
        system.debug('------> Monthly process is called');
        If(mapOfOppwithAmendmentOpp.size() > 0){
            List<AggregateResult> listOfaggRes = [SELECT Orginal_Opportunity__c,Orginal_Opportunity__r.Auto_Number_PK__c, COUNT(Id)co FROM Opportunity WHERE Orginal_Opportunity__c IN: mapOfOppwithAmendmentOpp.KeySet() GROUP BY Orginal_Opportunity__c,Orginal_Opportunity__r.Auto_Number_PK__c];
            Map<Id, Opportunity> initailOppMapAutoNum = new Map<Id, Opportunity>([SELECT Id,Auto_Number_PK__c,Project_Type__c  FROM Opportunity WHERE Id IN: mapOfOppwithAmendmentOpp.KeySet()]);
            map<Id,Integer> mapOfOriginalOppRelaCount = new map<Id, Integer>();
            map<Id,string> mapOfOriginalOppAutoNUM = new map<Id, string>();
            Integer counter = 0;
            
            For(AggregateResult currAggRes : listOfaggRes){
                mapOfOriginalOppRelaCount.put((Id)currAggRes.get('Orginal_Opportunity__c'), (Integer)currAggRes.get('co'));
                mapOfOriginalOppAutoNUM.put((Id)currAggRes.get('Orginal_Opportunity__c'), (string)currAggRes.get('Auto_Number_PK__c'));
            }
            
            For(Id OriginalOppID : mapOfOppwithAmendmentOpp.keySet()){
                For(Opportunity amendCurrentOpp : mapOfOppwithAmendmentOpp.get(OriginalOppID)){
                    system.debug('------> Monthly process is called');
                    If(amendCurrentOpp.Orginal_Opportunity__c !=null && amendCurrentOpp.Project_Type__c == 'Monthly'){
                        If(mapOfOriginalOppAutoNUM.get(OriginalOppID) != null){
                            amendCurrentOpp.Auto_Number_PK__c = mapOfOriginalOppAutoNUM.get(OriginalOppID).removeEnd('0')+alphabets[mapOfOriginalOppRelaCount.get(OriginalOppID)+counter];
                            counter ++;
                        }else{
                            amendCurrentOpp.Auto_Number_PK__c = initailOppMapAutoNum.get(OriginalOppID).Auto_Number_PK__c.removeEnd('0') +alphabets[counter];
                            counter ++;
                        }       
                    }
                    //else{
                        //amendCurrentOpp.addError('In Current Project Type, you can only create Amendment Opportunity.');
                    //} 
                }
            }
        }
    }
    
    public static void childOppAutoNumberCreate(Map<Id,List<Opportunity>> mapOfChildOpp){
        system.debug('CHILD OPPORTUNITY METHOD INVOKED');
        If(mapOfChildOpp.size() > 0){
            List<AggregateResult> listOfaggRes = [SELECT Orginal_Opportunity__c,Orginal_Opportunity__r.Auto_Number_PK__c, COUNT(Id)co FROM Opportunity WHERE Orginal_Opportunity__c IN: mapOfChildOpp.KeySet() GROUP BY Orginal_Opportunity__c,Orginal_Opportunity__r.Auto_Number_PK__c];
            Map<Id, Opportunity> initailOppMapAutoNum = new Map<Id, Opportunity>([SELECT Id,Auto_Number_PK__c,Project_Type__c  FROM Opportunity WHERE Id IN: mapOfChildOpp.KeySet()]);
            Integer counter = 1;
            map<Id,Integer> mapOfOriginalOppRelaCount = new map<Id, Integer>();
            map<Id,string> mapOfOriginalOppAutoNUM = new map<Id, string>();
            
            For(AggregateResult currAggRes : listOfaggRes){
                mapOfOriginalOppRelaCount.put((Id)currAggRes.get('Orginal_Opportunity__c'), (Integer)currAggRes.get('co'));
                mapOfOriginalOppAutoNUM.put((Id)currAggRes.get('Orginal_Opportunity__c'), (string)currAggRes.get('Auto_Number_PK__c'));
            }
            
            For(Id OriginalOppID : mapOfChildOpp.keySet()){
                For(Opportunity amendCurrentOpp : mapOfChildOpp.get(OriginalOppID)){
                    If(amendCurrentOpp.Orginal_Opportunity__c != null && amendCurrentOpp.Project_Type__c == 'Event'){
                        
                        If(mapOfOriginalOppAutoNUM.get(amendCurrentOpp.Orginal_Opportunity__c) != null){
                            amendCurrentOpp.Auto_Number_PK__c = mapOfOriginalOppAutoNUM.get(OriginalOppID).removeEnd('00-0')+String.valueOf(mapOfOriginalOppRelaCount.get(OriginalOppID) + counter).leftPad(2, '0')+'-0';
                            counter ++;
                        }else{
                            amendCurrentOpp.Auto_Number_PK__c = initailOppMapAutoNum.get(OriginalOppID).Auto_Number_PK__c.removeEnd('00-0')+String.valueOf(counter).leftPad(2, '0')+'-0';
                            counter ++;
                        }    
                    }
                    //else{
                        //amendCurrentOpp.addError('In Current Primary Opp Project Type, you can only create Amendment Opportunity.');
                    //} 
                    
                }
            }
        }
        
    }
    
    
}