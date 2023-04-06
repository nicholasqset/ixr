
package com.qset.gl;

import com.qset.sys.Sys;

/**
 *
 * @author nicholas
 */
public class GLPL {
    String comCode;
    String fiscalYear;
    Integer pYear;
    Integer pMonth;
    Integer cuml;
    
    public GLPL(String comCode, Integer pYear, Integer pMonth, Integer cuml){
        this.comCode    = comCode;
        this.pYear      = pYear;
        this.pMonth     = pMonth;
        this.cuml       = cuml;
        
        Sys sys = new Sys();
        this.fiscalYear = sys.getOne(comCode+".fnfiscalprd", "FISCALYEAR", "PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ "");
    }
    
    public Double getRevenue(){
        Double revAmount;
        
        Sys system = new Sys();
        
        String revAmount_;
        if(cuml == 1){
            revAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'REV' AND FISCALYEAR = '"+fiscalYear+"'");
        }else{
            revAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'REV' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        }
        
        revAmount_ = revAmount_ != null? revAmount_: "0";
        revAmount = Double.parseDouble(revAmount_);
        
        return revAmount;
    }
    
    public Double getCOS(){
        Double COSAmount;
        
        Sys system = new Sys();
        
        String COSAmount_;
        if(cuml == 1){
            COSAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '19' AND FISCALYEAR = '"+fiscalYear+"'");
        }else{
            COSAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '19' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        }
        COSAmount_ = COSAmount_ != null? COSAmount_: "0";
        COSAmount = Double.parseDouble(COSAmount_);
        
        return COSAmount;
    }
    
    public Double getOtherRev(){
        Double otherRevAmount;
        
        Sys system = new Sys();
        
        String otherRevAmount_;
        if(cuml == 1){
            otherRevAmount_= system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'OR' AND FISCALYEAR = '"+fiscalYear+"'");
        }else{
            otherRevAmount_= system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'OR' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");            
        }
         
        otherRevAmount_ = otherRevAmount_ != null? otherRevAmount_: "0";
        otherRevAmount = Double.parseDouble(otherRevAmount_);
        
        return otherRevAmount;
    }
    
    public Double getFixedCharges(){
        Double FCAmount;
        
        Sys system = new Sys();
        
        String FCAmount_;
        if(cuml == 1){
            FCAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '21' AND FISCALYEAR = '"+fiscalYear+"'");
        }else{
            FCAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '21' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        }
        
        FCAmount_ = FCAmount_ != null? FCAmount_: "0";
        FCAmount = Double.parseDouble(FCAmount_);
        
        return FCAmount;
    }
    
    public Double getOtherExpenses(){
        Double OEAmount;
        
        Sys system = new Sys();
        
        String OEAmount_;
        
        if(cuml == 1){
            OEAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '22' AND FISCALYEAR = '"+fiscalYear+"'");
        }else{
            OEAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '22' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        }
        
        OEAmount_ = OEAmount_ != null? OEAmount_: "0";
        OEAmount = Double.parseDouble(OEAmount_);
        
        return OEAmount;
    }
    
    public Double getDepExpense(){
        Double depExpAmount;
        
        Sys system = new Sys();
        
        String depExpAmount_;
        
        if(cuml == 1){
            depExpAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'DE' AND FISCALYEAR = '"+fiscalYear+"'");
        }else{
            depExpAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'DE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        }
        
        depExpAmount_ = depExpAmount_ != null? depExpAmount_: "0";
        depExpAmount = Double.parseDouble(depExpAmount_);
        
        return depExpAmount;
    }
    
    public Double getIntExpense(){
        Double intExpAmount;
        
        Sys system = new Sys();
        
        String intExpAmount_;
        
        if(cuml == 1){
            intExpAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'IE' AND FISCALYEAR = '"+fiscalYear+"'");
        }else{
            intExpAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'IE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        }
        
        intExpAmount_ = intExpAmount_ != null? intExpAmount_: "0";
        intExpAmount = Double.parseDouble(intExpAmount_);
        
        return intExpAmount;
    }
    
    public Double getIncomeTaxes(){
        Double taxAmount;
        
        Sys system = new Sys();
        
        String taxAmount_;
        
        if(cuml == 1){
            taxAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'IT' AND FISCALYEAR = '"+fiscalYear+"'");
        }else{
            taxAmount_ = system.getOneAgt(comCode+ ".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'IT' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        }
        
        taxAmount_ = taxAmount_ != null? taxAmount_: "0";
        taxAmount = Double.parseDouble(taxAmount_);
        
        return taxAmount;
    }
    
    public Double getPL(){
        Double plAmount;
        
        Double revenue          = this.getRevenue();
        Double cos              = this.getCOS();
        Double gp               = revenue - cos;
        Double otherRev         = this.getOtherRev();
        Double fixedCharges     = this.getFixedCharges();
        Double otherExpenses    = this.getOtherExpenses();
        Double depExpense       = this.getDepExpense();
        Double elfo             = gp + otherRev - fixedCharges - otherExpenses - depExpense;
        Double intExpense       = this.getIntExpense();
        Double elbt             = elfo - intExpense;
        Double incTaxes         = this.getIncomeTaxes();
        
        plAmount                = elbt - incTaxes;
        
        return plAmount;
    }
    
}
