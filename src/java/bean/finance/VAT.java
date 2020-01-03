
package bean.finance;

/**
 *
 * @author nicholas
 */
public class VAT {
    public Double vatRate = 0.0;
    public Double vatAmount = 0.0;
    public Double netAmount = 0.0;
    public Double total = 0.0;
    
    
    public VAT(Double amount, Boolean taxInclusive){
        try{
            FinConfig finConfig = new FinConfig();
            this.vatRate        = finConfig.vatRate;

            if(taxInclusive){
                this.netAmount  = amount * (100 / (100 + this.vatRate));
                this.vatAmount  = amount - this.netAmount;
                this.total      = amount;
            }else{
                this.vatAmount  = this.vatRate / 100 * amount;
                this.netAmount  = amount;
                this.total      = this.vatAmount + amount;
            }
        }catch(Exception e){
            e.getMessage();
        }
        
    }
}
