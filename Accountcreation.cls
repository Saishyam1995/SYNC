public with sharing class QuoteCreator {

    // Method to create a Quote for a given Opportunity Id
    public static void createQuotesFromOpportunities(List<Id> opportunityIds) {
        // Validate input
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            throw new IllegalArgumentException('Opportunity Ids must not be null or empty.');
        }

        // Check CRUD permissions
        if (!Schema.sObjectType.Opportunity.isAccessible()) {
            throw new CustomException('Insufficient permissions to access Opportunities.');
        }

        if (!Schema.sObjectType.Quote.isCreateable()) {
            throw new CustomException('Insufficient permissions to create Quotes.');
        }

        List<Quote> quotes = new List<Quote>();
        try {
            // Query Opportunities to ensure they exist
            List<Opportunity> opportunities = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id IN :opportunityIds];

            // Create a Quote for each Opportunity
            for (Opportunity opp : opportunities) {
                Quote quote = new Quote(
                    Name = opp.Name + ' Quote',
                    OpportunityId = opp.Id,
                    AccountId = opp.AccountId,
                    ExpirationDate = Date.today().addDays(30) // Set an expiration date 30 days from today
                );
                quotes.add(quote);
            }

            // Insert Quotes in bulk
            if (!quotes.isEmpty()) {
                insert quotes;
                System.debug('Quotes created: ' + quotes);
            }
        } catch (DmlException e) {
            // Log exception details
            System.debug('DML Exception when creating quotes: ' + e.getMessage());
            // Optionally, handle the exception more thoroughly depending on your needs
            throw new CustomException('Error occurred while creating quotes: ' + e.getMessage());
        } catch (Exception e) {
            // Handle any other exceptions
            System.debug('General Exception: ' + e.getMessage());
            throw new CustomException('An unexpected error occurred: ' + e.getMessage());
        }
    }

    // Custom exception class
    public class CustomException extends Exception {}
}