public class Refresh {
    public static void accountRatingHot(list<Account> newlst){
        for(Account acc:newlst ){
            IF(acc.annualrevenue==null && acc.Rating.equals('Hot'))
                acc.annualrevenue=200;
        }
    }
}
