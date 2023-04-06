package com.qset.cb;

import com.qset.conn.ConnectionProvider;
import com.qset.finance.CoBank;
import com.qset.gl.GeneralLedger;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import com.qset.sys.Sys;

/**
 *
 * @author nicholas
 */
public class CB {
    public String schema;
    
    public CB(String schema){
        this.schema = schema;
    }
    
    public String postCbBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
        String html = "";
        
        Integer entryCreated = 0;
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM VIEWCBDTLS WHERE BATCHNO = "+ batchNo;
                
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                String  bkBranchCode    = rs.getString("BKBRANCHCODE");
                Integer entryNo         = rs.getInt("ENTRYNO");
                String entryDesc        = rs.getString("ENTRYDESC");
                Integer pYear           = rs.getInt("PYEAR");
                Integer pMonth          = rs.getInt("PMONTH");
                String refNo            = rs.getString("REFNO");
                String refDesc          = rs.getString("REFDESC");
                String docType          = rs.getString("DOCTYPE");
                String accountCode      = rs.getString("ACCOUNTCODE");
                String normalBal        = rs.getString("NORMALBAL");
                Double drAmount         = rs.getDouble("DRAMOUNT");
                Double crAmount         = rs.getDouble("CRAMOUNT");
                
                String createCbEntry = this.createCbEntry(batchNo, entryNo, refNo, accountCode, normalBal, drAmount, crAmount, session, request);
                if(createCbEntry.equals("1")){
                    String postCb2Gl = this.postCb2Gl(batchNo, entryNo, entryDesc, refNo, refDesc, bkBranchCode, docType, accountCode, normalBal, drAmount, crAmount, pYear, pMonth, session, request);
                    entryCreated++;
                }
            }
            
        }catch(Exception e){
            html += e.getMessage();
        }
        
        html += entryCreated > 0? "1": "";
        
        return html;
    }
    
    private String createCbEntry(Integer batchNo, Integer entryNo, String refNo, String accountCode, String normalBal, Double drAmount, Double crAmount, HttpSession session, HttpServletRequest request){
        String html = "";
        
        Sys system = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query;
            if(! system.recordExists("CBCB", "BATCHNO = "+ batchNo+ " AND ENTRYNO = "+ entryNo+ " AND REFNO = '"+ refNo+ "'")){
                Integer id = system.generateId("CBCB", "ID");
                query = "INSERT INTO CBCB "
                        + ""
                        + "("
                        + "ID, BATCHNO, ENTRYNO, "
                        + "REFNO, ACCOUNTCODE, "
                        + "NORMALBAL, DRAMOUNT, CRAMOUNT, "
                        + "RCNAMOUNT, RCNVAR, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ")"
                        + "VALUES"
                        + "("
                        + id + ", "
                        + batchNo+ ", "
                        + entryNo+ ", "
                        + "'"+ refNo+ "', "
                        + "'"+ accountCode+ "', "
                        + "'"+ normalBal+ "', "
                        + drAmount+ ", "
                        + crAmount+ ", "
                        + 0+ ", "
                        + 0+ ", "
                        + "'"+ system.getLogUser(session)+ "', "
                        + "'"+ system.getLogDate()+ "', "
                        + system.getLogTime()+ ", "
                        + "'"+ system.getClientIpAdr(request)+ "'"
                        + ")";
            }else{
                query = "UPDATE CBCB SET "
                        + "ACCOUNTCODE  = '"+ accountCode+ "', "
                        + "NORMALBAL    = '"+ normalBal+ "', "
                        + "DRAMOUNT     = "+ drAmount+ ", "
                        + "CRAMOUNT     = "+ crAmount+ ", "
                        + "AUDITUSER    = '"+ system.getLogUser(session)+ "', "
                        + "AUDITDATE    = '"+ system.getLogDate()+ "', "
                        + "AUDITTIME    = "+ system.getLogTime()+ ", "
                        + "AUDITIPADR   = '"+ system.getClientIpAdr(request)+ "' "

                        + "WHERE BATCHNO = "+ batchNo+ " AND ENTRYNO = "+ entryNo+ " AND REFNO = '"+ refNo+ "'";
            }
            
            Integer saved = stmt.executeUpdate(query);
            if(saved == 1){
                html += "1";
            }
        }catch(Exception e){
            html += e.getMessage();
        }
        
        return html;
    }
    
    private String postCb2Gl(Integer batchNo, Integer entryNo, String entryDesc, String refNo, String refDesc, String bkBranchCode, String docType, String accountCode, String normalBal, Double drAmount, Double crAmount, Integer pYear, Integer pMonth, HttpSession session, HttpServletRequest request){
        String html = "";
        
        GeneralLedger generalLedger = new GeneralLedger(schema);
        
        CoBank coBank = new CoBank(bkBranchCode);
        
        Double amount = normalBal.equals("CR")? crAmount: drAmount;
        
        switch(docType){
            case "AD":
            case "SD":
                for(int i = 1; i <= 2; i++){
                    if(i == 1){
                        generalLedger.createBatchDtls(batchNo, "CB Generated Batch", "CB-CB", entryNo+ "", entryDesc, refNo, accountCode, "CR", 0.0, amount, pYear, pMonth, session, request);
                    }else if(i == 2){
                        generalLedger.createBatchDtls(batchNo, "CB Generated Batch", "CB-CB", entryNo+ "", entryDesc, refNo, coBank.bkAcc, "DR", amount, 0.0, pYear, pMonth, session, request);
                    }
                }
                break;
            case "SP":
                for(int i = 1; i <= 2; i++){
                    if(i == 1){
                        generalLedger.createBatchDtls(batchNo, "CB Generated Batch", "CB-CB", entryNo+ "", entryDesc, refNo, accountCode, "DR", amount, 0.0, pYear, pMonth, session, request);
                    }else if(i == 2){
                        generalLedger.createBatchDtls(batchNo, "CB Generated Batch", "CB-CB", entryNo+ "", entryDesc, refNo, coBank.bkAcc, "CR", 0.0, amount, pYear, pMonth, session, request);
                    }
                }
                break;
        }
        
        return html;
    }
    
}
