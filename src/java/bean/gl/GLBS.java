
package bean.gl;

import bean.sys.Sys;

/**
 *
 * @author nicholas
 */
public class GLBS {
    
    public Double getCE(Integer pYear, Integer pMonth){
        Double ceAmount;
        
        Sys system = new Sys();
        
        String ceDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'CCE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        ceDrAmount_ = ceDrAmount_ != null? ceDrAmount_: "0";
        Double ceDrAmount = Double.parseDouble(ceDrAmount_);
        
        String ceCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'CCE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        ceCrAmount_ = ceCrAmount_ != null? ceCrAmount_: "0";
        Double ceCrAmount = Double.parseDouble(ceCrAmount_);
        
        ceAmount = ceDrAmount - ceCrAmount;
        
        return ceAmount;
    }
    
    public Double getAR(Integer pYear, Integer pMonth){
        Double arAmount;
        
        Sys system = new Sys();
        
        String arDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'AR' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        arDrAmount_ = arDrAmount_ != null? arDrAmount_: "0";
        Double arDrAmount = Double.parseDouble(arDrAmount_);
        
        String arCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'AR' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        arCrAmount_ = arCrAmount_ != null? arCrAmount_: "0";
        Double arCrAmount = Double.parseDouble(arCrAmount_);
        
        arAmount = arDrAmount - arCrAmount;
        
        return arAmount;
    }
    
    public Double getInv(Integer pYear, Integer pMonth){
        Double invAmount;
        
        Sys system = new Sys();
        
        String invDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'INV' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        invDrAmount_ = invDrAmount_ != null? invDrAmount_: "0";
        Double invDrAmount = Double.parseDouble(invDrAmount_);
        
        String invCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'INV' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        invCrAmount_ = invCrAmount_ != null? invCrAmount_: "0";
        Double invCrAmount = Double.parseDouble(invCrAmount_);
        
        invAmount = invDrAmount - invCrAmount;
        
        return invAmount;
    }
    
    
    public Double getOCA(Integer pYear, Integer pMonth){
        Double ocaAmount;
        
        Sys system = new Sys();
        
        String ocaDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'OCA' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        ocaDrAmount_ = ocaDrAmount_ != null? ocaDrAmount_: "0";
        Double ocaDrAmount = Double.parseDouble(ocaDrAmount_);
        
        String ocaCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'OCA' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        ocaCrAmount_ = ocaCrAmount_ != null? ocaCrAmount_: "0";
        Double ocaCrAmount = Double.parseDouble(ocaCrAmount_);
        
        ocaAmount = ocaDrAmount - ocaCrAmount;
        
        return ocaAmount;
    }
    
    public Double getFA(Integer pYear, Integer pMonth){
        Double fAAmount;
        
        Sys system = new Sys();
        
        String fADrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'FA' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        fADrAmount_ = fADrAmount_ != null? fADrAmount_: "0";
        Double fADrAmount = Double.parseDouble(fADrAmount_);
        
        String fACrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'FA' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        fACrAmount_ = fACrAmount_ != null? fACrAmount_: "0";
        Double fACrAmount = Double.parseDouble(fACrAmount_);
        
        fAAmount = fADrAmount - fACrAmount;
        
        return fAAmount;
    }
    
    public Double getAcmDep(Integer pYear, Integer pMonth){
        Double acmDepAmount;
        
        Sys system = new Sys();
        
        String acmDepCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'AD' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        acmDepCrAmount_ = acmDepCrAmount_ != null? acmDepCrAmount_: "0";
        Double acmDepCrAmount = Double.parseDouble(acmDepCrAmount_);
        
        String acmDepDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'AD' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        acmDepDrAmount_ = acmDepDrAmount_ != null? acmDepDrAmount_: "0";
        Double acmDepDrAmount = Double.parseDouble(acmDepDrAmount_);
        
        acmDepAmount = acmDepCrAmount - acmDepDrAmount;
        
        return acmDepAmount;
    }
    
    public Double getOA(Integer pYear, Integer pMonth){
        Double oAAmount;
        
        Sys system = new Sys();
        
        String oADrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'OA' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        oADrAmount_ = oADrAmount_ != null? oADrAmount_: "0";
        Double fADrAmount = Double.parseDouble(oADrAmount_);
        
        String oACrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'OA' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        oACrAmount_ = oACrAmount_ != null? oACrAmount_: "0";
        Double fACrAmount = Double.parseDouble(oACrAmount_);
        
        oAAmount = fADrAmount - fACrAmount;
        
        return oAAmount;
    }
    
    public Double getAP(Integer pYear, Integer pMonth){
        Double aPAmount;
        
        Sys system = new Sys();
        
        String aPCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'AP' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        aPCrAmount_ = aPCrAmount_ != null? aPCrAmount_: "0";
        Double aPCrAmount = Double.parseDouble(aPCrAmount_);
        
        String aPDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'AP' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        aPDrAmount_ = aPDrAmount_ != null? aPDrAmount_: "0";
        Double aPDrAmount = Double.parseDouble(aPDrAmount_);
        
        aPAmount = aPCrAmount - aPDrAmount;
        
        return aPAmount;
    }
    
    public Double getPfIT(Integer pYear, Integer pMonth){
        Double pfITAmount;
        
        Sys system = new Sys();
        
        String pfITCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCODE = '09' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        pfITCrAmount_ = pfITCrAmount_ != null? pfITCrAmount_: "0";
        Double pfITCrAmount = Double.parseDouble(pfITCrAmount_);
        
        String pfITDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '09' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        pfITDrAmount_ = pfITDrAmount_ != null? pfITDrAmount_: "0";
        Double pfITDrAmount = Double.parseDouble(pfITDrAmount_);
        
        pfITAmount = pfITCrAmount - pfITDrAmount;
        
        return pfITAmount;
    }
    
    public Double getOCL(Integer pYear, Integer pMonth){
        Double oCLAmount;
        
        Sys system = new Sys();
        
        String oCLCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCODE = '10' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        oCLCrAmount_ = oCLCrAmount_ != null? oCLCrAmount_: "0";
        Double oCLCrAmount = Double.parseDouble(oCLCrAmount_);
        
        String oCLDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCODE = '10' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        oCLDrAmount_ = oCLDrAmount_ != null? oCLDrAmount_: "0";
        Double oCLDrAmount = Double.parseDouble(oCLDrAmount_);
        
        oCLAmount = oCLCrAmount - oCLDrAmount;
        
        return oCLAmount;
    }
    
    public Double getLTL(Integer pYear, Integer pMonth){
        Double lTLAmount;
        
        Sys system = new Sys();
        
        String lTLCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'LTL' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        lTLCrAmount_ = lTLCrAmount_ != null? lTLCrAmount_: "0";
        Double lTLCrAmount = Double.parseDouble(lTLCrAmount_);
        
        String lTLDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'LTL' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        lTLDrAmount_ = lTLDrAmount_ != null? lTLDrAmount_: "0";
        Double lTLDrAmount = Double.parseDouble(lTLDrAmount_);
        
        lTLAmount = lTLCrAmount - lTLDrAmount;
        
        return lTLAmount;
    }
    
    public Double getDividends(Integer pYear, Integer pMonth){
        Double dividendAmount;
        
        Sys system = new Sys();
        
        String dividendCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'OL' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        dividendCrAmount_ = dividendCrAmount_ != null? dividendCrAmount_: "0";
        Double dividendCrAmount = Double.parseDouble(dividendCrAmount_);
        
        String dividendDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'OL' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        dividendDrAmount_ = dividendDrAmount_ != null? dividendDrAmount_: "0";
        Double dividendDrAmount = Double.parseDouble(dividendDrAmount_);
        
        dividendAmount = dividendCrAmount - dividendDrAmount;
        
        return dividendAmount;
    }
    
    public Double getSC(Integer pYear, Integer pMonth){
        Double sCAmount;
        
        Sys system = new Sys();
        
        String sCCrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'SC' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        sCCrAmount_ = sCCrAmount_ != null? sCCrAmount_: "0";
        Double sCCrAmount = Double.parseDouble(sCCrAmount_);
        
        String sCDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'SC' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        sCDrAmount_ = sCDrAmount_ != null? sCDrAmount_: "0";
        Double sCDrAmount = Double.parseDouble(sCDrAmount_);
        
        sCAmount = sCCrAmount - sCDrAmount;
        
        return sCAmount;
    }
    
    
    public Double getSE(Integer pYear, Integer pMonth){
        Double sEAmount;
        
        Sys system = new Sys();
        
        String sECrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCGRPCATCODE = 'SE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        sECrAmount_ = sECrAmount_ != null? sECrAmount_: "0";
        Double sECrAmount = Double.parseDouble(sECrAmount_);
        
        String sEDrAmount_ = system.getOneAgt("VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCGRPCATCODE = 'SE' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        sEDrAmount_ = sEDrAmount_ != null? sEDrAmount_: "0";
        Double sEDrAmount = Double.parseDouble(sEDrAmount_);
        
        sEAmount = sECrAmount - sEDrAmount;
        
        return sEAmount;
    }
    
}
