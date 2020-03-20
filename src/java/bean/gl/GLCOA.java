
package bean.gl;

import bean.conn.ConnectionProvider;
import bean.sys.Sys;
import java.sql.Connection;
import java.sql.Statement;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 *
 * @author nicholas
 */
public class GLCOA {
    public String schema;
    
    public GLCOA(String schema){
        this.schema = schema;
    }
    
    public Integer createBdg(Integer pYear, Integer pMonth, String accountCode, Double amount, HttpSession session, HttpServletRequest request){
        Integer bdgCreated = 0;
        Sys system = new Sys();
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query;
            
            if(! system.recordExists(schema+".GLBDG", "PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ " AND ACCOUNTCODE = '"+ accountCode+ "' ")){
                Integer id = system.generateId(schema+".GLDTLS", "ID");
                query = "INSERT INTO "+schema+".GLBDG "
                        + "("
                        + "ID, PYEAR, PMONTH, ACCOUNTCODE, AMOUNT, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + pYear+ ", "
                        + pMonth+ ", "
                        + "'"+ accountCode+ "', "
                        + amount+ ","
                        + "'"+ system.getLogUser(session)+ "', "
                        + "'"+ system.getLogDate()+ "', "
                        + system.getLogTime()+ ", "
                        + "'"+ system.getClientIpAdr(request)+ "'"
                        + ")";
            }else{
                query = "UPDATE "+schema+".GLBDG SET "
                            + "PYEAR        = "+ pYear+ ", "
                            + "PMONTH       = "+ pMonth+ ", "
                            + "ACCOUNTCODE  = '"+ accountCode+ "',"
                            + "AMOUNT       = "+ amount+ ", "
                            + "AUDITUSER    = '"+ system.getLogUser(session)+ "', "
                            + "AUDITDATE    = '"+ system.getLogDate()+ "', "
                            + "AUDITTIME    = "+ system.getLogTime()+ ", "
                            + "AUDITIPADR   = '"+ system.getClientIpAdr(request)+ "' "
                        
                            + "WHERE PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ " AND ACCOUNTCODE = '"+ accountCode+ "'";
            }
            
            bdgCreated = stmt.executeUpdate(query);
            
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        
        return bdgCreated;
    }
    
    public Double getAccountBal(Integer pYear, Integer pMonth, String accountCode){
        Double accBal = 0.0;
        
        GLAccount gLAccount = new GLAccount(accountCode, schema);
        
        switch (gLAccount.accTypeCode) {
            case "BS":
                accBal = this.getBSBal(pYear, pMonth, accountCode, gLAccount.accGrpCode, gLAccount.normalBal);
                break;
            case "IS":
                accBal = this.getPLBal(pYear, pMonth, accountCode, gLAccount.accGrpCode, gLAccount.normalBal);
                break;
            case "RE":
                break;
        }
        
        return accBal;
    }
    
    public Double getBSBal(Integer pYear, Integer pMonth, String accountCode, String accGrpCode, String normalBal){
        Double accBSBal = 0.0;
        
        Sys system = new Sys();
        
//        String drAccBSBal_ = system.getOne("VIEWGLTBSM", "SUM(SMDRAMOUNT)", "ACCOUNTCODE = '"+ accountCode+ "' AND ACCGRPCODE = '"+ accGrpCode+ "' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String drAccBSBal_ = system.getOneAgt(schema+".VIEWGLTBSM", "SUM", "SMDRAMOUNT", "SM", "ACCOUNTCODE = '"+ accountCode+ "' AND ACCGRPCODE = '"+ accGrpCode+ "' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        drAccBSBal_ = drAccBSBal_ != null? drAccBSBal_: "0";
        Double drAccBSBal = Double.parseDouble(drAccBSBal_);
        
//        String crAccBSBal_ = system.getOne("VIEWGLTBSM", "SUM(SMCRAMOUNT)", "ACCOUNTCODE = '"+ accountCode+ "' AND ACCGRPCODE = '"+ accGrpCode+ "' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String crAccBSBal_ = system.getOneAgt(schema+".VIEWGLTBSM", "SUM", "SMCRAMOUNT", "SM", "ACCOUNTCODE = '"+ accountCode+ "' AND ACCGRPCODE = '"+ accGrpCode+ "' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        crAccBSBal_ = crAccBSBal_ != null? crAccBSBal_: "0";
        Double crAccBSBal = Double.parseDouble(crAccBSBal_);
        
        switch (normalBal) {
            case "DR":
                accBSBal = drAccBSBal - crAccBSBal;
                break;
            case "CR":
                accBSBal = crAccBSBal - drAccBSBal;
                break;
        }
        
        return accBSBal;
    }
    
    public Double getPLBal(Integer pYear, Integer pMonth, String accountCode, String accGrpCode, String normalBal){
        Double accPLBal;
        
        Sys system = new Sys();
        
        String col = "";
        
        switch (normalBal) {
            case "DR":
                col = "SMDRAMOUNT";
                break;
            case "CR":
                col = "SMCRAMOUNT";
                break;
        }
        
//        String accPLBal_ = system.getOne("VIEWGLTBSM", "SUM("+ col+ ")", "ACCOUNTCODE = '"+ accountCode+ "' AND ACCGRPCODE = '"+ accGrpCode+ "' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        String accPLBal_ = system.getOneAgt(schema+".VIEWGLTBSM", "SUM", col, "SM", "ACCOUNTCODE = '"+ accountCode+ "' AND ACCGRPCODE = '"+ accGrpCode+ "' AND PYEAR = "+ pYear+ " AND PMONTH = "+ pMonth+ "");
        accPLBal_ = accPLBal_ != null? accPLBal_: "0";
        accPLBal = Double.parseDouble(accPLBal_);
        
        return accPLBal;
    }
    
}
