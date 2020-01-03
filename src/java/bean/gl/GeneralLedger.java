
package bean.gl;

import bean.conn.ConnectionProvider;
import bean.sys.Sys;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 *
 * @author nicholas
 */
public class GeneralLedger {
    public String schema;
    
    public GeneralLedger (String schema){
        this.schema = schema;
    }
    
    public Double getBatchDrAmount(Integer batchNo){
        Double drAmount = 0.0;
        
//        Sys system = new Sys();
//        
//        String drAmount_ = system.getOne("VIEWGLDTLS", "SUM(DRAMOUNT)", "BATCHNO = "+ batchNo+ "");
//        drAmount_ = drAmount_ != null? drAmount_: "0";
//        drAmount = Double.parseDouble(drAmount_);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(DRAMOUNT)SM FROM "+ schema+".VIEWGLDTLS WHERE BATCHNO = "+ batchNo+ "";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                drAmount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        return drAmount;
    }
    
    public Double getBatchCrAmount(Integer batchNo){
        Double crAmount = 0.0;
        
//        Sys system = new Sys();
//        
//        String crAmount_ = system.getOne("VIEWGLDTLS", "SUM(CRAMOUNT)", "BATCHNO = "+ batchNo+ "");
//        crAmount_ = crAmount_ != null? crAmount_: "0";
//        crAmount = Double.parseDouble(crAmount_);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(CRAMOUNT)SM FROM "+ schema+".VIEWGLDTLS WHERE BATCHNO = "+ batchNo+ "";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                crAmount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        return crAmount;
    }
    
    public Double getEntryNoDrAmount(Integer batchNo, Integer entryNo){
        Double drAmount = 0.0;
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(DRAMOUNT)SM FROM "+ schema+".VIEWGLDTLS WHERE BATCHNO = "+ batchNo+ " AND ENTRYNO = "+ entryNo+ "";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                drAmount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        return drAmount;
    }
    
    public Double getEntryNoCrAmount(Integer batchNo, Integer entryNo){
        Double crAmount = 0.0;
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(CRAMOUNT)SM FROM "+ schema+".VIEWGLDTLS WHERE BATCHNO = "+ batchNo+ " AND ENTRYNO = "+ entryNo+ "";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                crAmount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        return crAmount;
    }
    
    public Integer postBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
        Integer batchPosted = 0;
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM "+ schema+".VIEWGLDTLS WHERE BATCHNO = "+ batchNo +" ";
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count           = 0;
            Integer entryCreated    = 0;
            
            while(rs.next()){
                Integer entryNo     = rs.getInt("ENTRYNO");
                Integer lineNo      = rs.getInt("LINENO");
                String accountCode  = rs.getString("ACCOUNTCODE");
                String normalBal    = rs.getString("NORMALBAL");
                Double drAmount     = rs.getDouble("DRAMOUNT");
                Double crAmount     = rs.getDouble("CRAMOUNT");
                
                Integer tbEntryCreated = this.createTBEntry(entryNo, lineNo, accountCode, normalBal, drAmount, crAmount, session, request);
                if(tbEntryCreated == 1){
                    entryCreated++;
                }
                
                count++;
            }
            
            if(count > 0 && count.equals(entryCreated)){
                batchPosted = 1;
            }
            
        }catch(SQLException e){
            e.getMessage();
        }
        
        return batchPosted;
    }
    
    public Integer createTBEntry(Integer entryNo, Integer lineNo, String accountCode, String normalBal, Double drAmount, Double crAmount, HttpSession session, HttpServletRequest request){
        Integer entryCreated = 0;
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            Sys system = new Sys();
            
            if(! system.recordExists(schema+".GLTB", "ENTRYNO = "+ entryNo +" AND LINENO = "+ lineNo +"")){
                Integer id      = system.generateId("GLTB", "ID");
                String query = "INSERT INTO "+ schema+".GLTB "
                    + "(ID, ENTRYNO, LINENO, "
                    + "ACCOUNTCODE, NORMALBAL, "
                    + "DRAMOUNT, CRAMOUNT, "
                    + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                    + "VALUES"
                    + "("
                    + id+ ", "
                    + entryNo+ ", "
                    + lineNo+ ", "
                    + "'"+ accountCode +"', "
                    + "'"+ normalBal +"', "
                    + drAmount+ ", "
                    + crAmount+ ", "
                    + "'"+ system.getLogUser(session) +"', "
                    + "'"+ system.getLogDate() +"', "
                    + system.getLogTime() +", "
                    + "'"+ system.getClientIpAdr(request) +"'"
                    + ")";
            
                entryCreated = stmt.executeUpdate(query);
            }else{
                entryCreated = 1;
            }
            
            
        }catch(Exception e){
            e.getMessage();
        }
             
        return entryCreated;
    }
    
    public Integer getBatchNo(Integer srcBatchNo, String srcBatchDesc, String batchSrc){
        Integer batchNo = 0;
        Sys system = new Sys();
        
        String batchNo_ = system.getOne(schema+".GLBATCHES", "BATCHNO", "SRCBATCHNO = "+ srcBatchNo+ " AND BATCHSRC = '"+ batchSrc+"'");
        
//        batchNo_ = srcBatchNo == -1? "0": batchNo_;
        
        if(batchNo_ != null && ! batchNo_.trim().equals("") && ! batchNo_.trim().equals("0")){
            batchNo = Integer.parseInt(batchNo_);
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                Integer id      = system.generateId(""+ schema+".GLBATCHES", "ID");

                String query = "INSERT INTO "+ schema+".GLBATCHES "
                        + "("
                        + "ID, BATCHNO, BATCHDESC, SRCBATCHNO, BATCHSRC, "
                        + "DATECREATED, DATEEDITED)"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + id+ ", "
                        + "'"+ srcBatchDesc+ "', "
                        + srcBatchNo+ ","
                        + "'"+ batchSrc+ "', "
                        + "'"+ system.getLogDate()+ "', "
                        + "'"+ system.getLogDate()+ "'"
                        + ")";

                Integer batchCreated = stmt.executeUpdate(query);
                if(batchCreated == 1){
                    batchNo = id;
                }
            }catch(Exception e){
                e.getMessage();
            }
        }
        
        return batchNo;
    }
    
    public Integer getEntryNo(Integer batchNo, String srcDocNo, String srcDocDesc, Integer pYear, Integer pMonth){
        Integer entryNo = 0;
        Sys system = new Sys();
        
        String entryNo_ = system.getOne(""+ schema+".GLHDR", "ENTRYNO", "BATCHNO = "+ batchNo+ " AND SRCDOCNO = '"+ srcDocNo+"'");
        
        if(entryNo_ != null && ! entryNo_.trim().equals("")){
            entryNo = Integer.parseInt(entryNo_);
        }else{
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt  = conn.createStatement();

                Integer id = system.generateId("GLHDR", "ID");
                
                entryNo_    = system.getNextNo("GLHDR", "ID", "", "", 1);
                entryNo     = Integer.parseInt(entryNo_);

                String query = "INSERT INTO "+ schema+".GLHDR "
                        + "(ID, BATCHNO, ENTRYNO, ENTRYDESC, SRCDOCNO, "
                        + "ENTRYDATE, PYEAR, PMONTH"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ batchNo+ "', "
                        + "'"+ entryNo+ "', "
                        + "'"+ srcDocDesc+ "', "
                        + "'"+ srcDocNo+ "', "
                        + "'"+ system.getLogDate()+ "', "
                        + pYear+ ", "
                        + pMonth+ " "
                        + ")";

                stmt.executeUpdate(query);
                
            }catch(SQLException | NumberFormatException e){
                e.getMessage();
            }
        }
        
        return entryNo;
    }
    
    public Integer createBatchDtls(Integer srcBatchNo, String srcBatchDesc, String batchSrc, String srcDocNo, String srcDocDesc, String reference, String accountCode, String normalBal, Double drAmount, Double crAmount, Integer pYear, Integer pMonth, HttpSession session, HttpServletRequest request){
        Integer dtlsCreated = 0;
        Sys system = new Sys();
        
        Integer batchNo = this.getBatchNo(srcBatchNo, srcBatchDesc, batchSrc);
        Integer entryNo = this.getEntryNo(batchNo, srcDocNo, srcDocDesc, pYear, pMonth);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            Integer id = system.generateId(""+ schema+".GLDTLS", "ID");
            
            String lineNo_ = system.getNextNo(""+ schema+".GLDTLS", "LINENO", "ENTRYNO = "+ entryNo+ "", "", 1);
            Integer lineNo = Integer.parseInt(lineNo_);
            
            String query = "INSERT INTO "+ schema+".GLDTLS "
                    + ""
                    + "(ID, ENTRYNO, LINENO, REFERENCE, ACCOUNTCODE, "
                    + "NORMALBAL, DRAMOUNT, CRAMOUNT, "
                    + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                    + ")"
                    + "VALUES"
                    + "("
                    + id+ ", "
                    + entryNo+ ", "
                    + lineNo+ ", "
                    + "'"+ reference+ "', "
                    + "'"+ accountCode+ "', "
                    + "'"+ normalBal+ "', "
                    + drAmount + ", "
                    + crAmount + ", "
                    + "'"+ system.getLogUser(session)+ "', "
                    + "'"+ system.getLogDate()+ "', "
                    + system.getLogTime()+ ", "
                    + "'"+ system.getClientIpAdr(request)+ "'"
                    + ")";
            
            dtlsCreated = stmt.executeUpdate(query);
                
        }catch(SQLException | NumberFormatException e){
            e.getMessage();
        }
        
        return dtlsCreated;
    }
    
}
