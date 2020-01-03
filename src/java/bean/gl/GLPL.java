
package bean.gl;

import bean.sys.Sys;

/**
 *
 * @author nicholas
 */
public class GLPL {
    
    public Double getRevenue(Integer pYear, Integer pMonth){
        Double revAmount;
        
        Sys system = new Sys();
        
//        String revAmount_ = system.getOne("VIEWGLTBSM", "SUM(SMCRAMOUNT)", "ACCGRPCATCODE = 'REV' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String revAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'REV' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        revAmount_ = revAmount_ != null? revAmount_: "0";
        revAmount = Double.parseDouble(revAmount_);
        
        return revAmount;
    }
    
    public Double getCOS(Integer pYear, Integer pMonth){
        Double COSAmount;
        
        Sys system = new Sys();
        
//        String COSAmount_ = system.getOne("VIEWGLTBSM", "SUM(SMDRAMOUNT)", "ACCGRPCODE = '19' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String COSAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '19' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        COSAmount_ = COSAmount_ != null? COSAmount_: "0";
        COSAmount = Double.parseDouble(COSAmount_);
        
        return COSAmount;
    }
    
    public Double getOtherRev(Integer pYear, Integer pMonth){
        Double otherRevAmount;
        
        Sys system = new Sys();
        
//        String otherRevAmount_ = system.getOne("VIEWGLTBSM", "SUM(SMCRAMOUNT)", "ACCGRPCATCODE = 'OR' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String otherRevAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'OR' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        otherRevAmount_ = otherRevAmount_ != null? otherRevAmount_: "0";
        otherRevAmount = Double.parseDouble(otherRevAmount_);
        
        return otherRevAmount;
    }
    
    public Double getFixedCharges(Integer pYear, Integer pMonth){
        Double FCAmount;
        
        Sys system = new Sys();
        
//        String FCAmount_ = system.getOne("VIEWGLTBSM", "SUM(SMDRAMOUNT)", "ACCGRPCODE = '21' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String FCAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '21' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        FCAmount_ = FCAmount_ != null? FCAmount_: "0";
        FCAmount = Double.parseDouble(FCAmount_);
        
        return FCAmount;
    }
    
    public Double getOtherExpenses(Integer pYear, Integer pMonth){
        Double OEAmount;
        
        Sys system = new Sys();
        
//        String OEAmount_ = system.getOne("VIEWGLTBSM", "SUM(SMDRAMOUNT)", "ACCGRPCODE = '22' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String OEAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '22' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        OEAmount_ = OEAmount_ != null? OEAmount_: "0";
        OEAmount = Double.parseDouble(OEAmount_);
        
        return OEAmount;
    }
    
    public Double getDepExpense(Integer pYear, Integer pMonth){
        Double depExpAmount;
        
        Sys system = new Sys();
        
//        String depExpAmount_ = system.getOne("VIEWGLTBSM", "SUM(SMDRAMOUNT)", "ACCGRPCATCODE = 'DE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String depExpAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'DE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        depExpAmount_ = depExpAmount_ != null? depExpAmount_: "0";
        depExpAmount = Double.parseDouble(depExpAmount_);
        
        return depExpAmount;
    }
    
    public Double getIntExpense(Integer pYear, Integer pMonth){
        Double intExpAmount;
        
        Sys system = new Sys();
        
//        String intExpAmount_ = system.getOne("VIEWGLTBSM", "SUM(SMDRAMOUNT)", "ACCGRPCATCODE = 'IE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String intExpAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'IE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        intExpAmount_ = intExpAmount_ != null? intExpAmount_: "0";
        intExpAmount = Double.parseDouble(intExpAmount_);
        
        return intExpAmount;
    }
    
    public Double getIncomeTaxes(Integer pYear, Integer pMonth){
        Double taxAmount;
        
        Sys system = new Sys();
        
//        String taxAmount_ = system.getOne("VIEWGLTBSM", "SUM(SMDRAMOUNT)", "ACCGRPCATCODE = 'IT' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String taxAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'IT' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        taxAmount_ = taxAmount_ != null? taxAmount_: "0";
        taxAmount = Double.parseDouble(taxAmount_);
        
        return taxAmount;
    }
    
    public Double getPL(Integer pYear, Integer pMonth){
        Double plAmount;
        
        Double revenue          = this.getRevenue(pYear, pMonth);
        Double cos              = this.getCOS(pYear, pMonth);
        Double gp               = revenue - cos;
        Double otherRev         = this.getOtherRev(pYear, pMonth);
        Double fixedCharges     = this.getFixedCharges(pYear, pMonth);
        Double otherExpenses    = this.getOtherExpenses(pYear, pMonth);
        Double depExpense       = this.getDepExpense(pYear, pMonth);
        Double elfo             = gp + otherRev - fixedCharges - otherExpenses - depExpense;
        Double intExpense       = this.getIntExpense(pYear, pMonth);
        Double elbt             = elfo - intExpense;
        Double incTaxes         = this.getIncomeTaxes(pYear, pMonth);
        
        plAmount                = elbt - incTaxes;
        
        return plAmount;
    }
    
}
