public with sharing class OpportunityCreator {

    // Method to create an Opportunity for a given Account Id
    public static void createOpportunitiesFromAccounts(List<Id> accountIds) {
        // Validate input
        if (accountIds == null || accountIds.isEmpty()) {
            throw new IllegalArgumentException('Account Ids must not be null or empty.');
        }

        // Check CRUD permissions
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new CustomException('Insufficient permissions to access Accounts.');
        }

        if (!Schema.sObjectType.Opportunity.isCreateable()) {
            throw new CustomException('Insufficient permissions to create Opportunities.');
        }

        List<Opportunity> opportunities = new List<Opportunity>();
        try {
            // Query Accounts to ensure they exist
            List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];

            // Create an Opportunity for each Account
            for (Account account : accounts) {
                Opportunity opp = new Opportunity(
                    Name = account.Name + ' Opportunity',
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    AccountId = account.Id
                );
                opportunities.add(opp);
            }

            // Insert Opportunities in bulk
            if (!opportunities.isEmpty()) {
                insert opportunities;
                System.debug('Opportunities created: ' + opportunities);
            }
        } catch (Exception e) {
            // Log exception details
            System.debug('Exception when creating opportunities: ' + e.getMessage());
            // Optionally, throw a custom exception or handle it according to your application's needs
            throw new CustomException('Error occurred while creating opportunities: ' + e.getMessage());
        }
    }

    // Custom exception class
    public class CustomException extends Exception {}
}