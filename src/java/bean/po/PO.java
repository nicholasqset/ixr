package bean.po;

import bean.sys.Sys;
import bean.ap.APSupplierProfile;
import bean.conn.ConnectionProvider;
import bean.gl.GLAccount;
import bean.gl.GeneralLedger;
import bean.ic.ICAccountSet;
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
public class PO {
    public String schema;
    
    public PO(String schema){
        this.schema = schema;
    }
    
    public String postReceipt(String pyNo, HttpSession session, HttpServletRequest request){
        String posted;
        
        GeneralLedger generalLedger = new GeneralLedger(this.schema);
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWPOPYDTLS WHERE PYNO = '"+ pyNo+"'";
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count = 0;

            while(rs.next()){
                String pyDesc       = rs.getString("PYDESC");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                String supplierNo   = rs.getString("SUPPLIERNO");
                String accSetCode   = rs.getString("ACCSETCODE");
                String itemCode     = rs.getString("ITEMCODE");
                Integer stocked     = rs.getInt("STOCKED");
                Double qty          = rs.getDouble("QTY");
                Double total        = rs.getDouble("TOTAL");
                
                String pyNoBatch_   = pyNo.replace("PY", "");
                Integer pyNoBatch   = Integer.parseInt(pyNoBatch_);
                
                APSupplierProfile aPSupplierProfile = new APSupplierProfile(supplierNo, schema);
                
                ICAccountSet iCAccountSet = new ICAccountSet(accSetCode);
                
                for(int i = 0; i < 2; i++){
                    if(i == 0){
                        generalLedger.createBatchDtls(pyNoBatch, "PO Generated Batch", "PO-PY", pyNo, pyDesc, supplierNo+ "-"+ aPSupplierProfile.fullName, iCAccountSet.invCtlAcc, "DR", total, 0.0, pYear, pMonth, session, request);
                    }else if(i == 1){
                        generalLedger.createBatchDtls(pyNoBatch, "PO Generated Batch", "PO-PY", pyNo, pyDesc, supplierNo+ "-"+ aPSupplierProfile.fullName, iCAccountSet.apClrAcc, "CR", 0.0, total, pYear, pMonth, session, request);
                    }
                }
                
                if(stocked == 1){
                    this.addItemQty(itemCode, qty);
                }
                
                count++;
            }
            
            posted = count > 0? "1": "";
        }catch(SQLException | NumberFormatException e){
            posted = e.getMessage();
        }
        
        return posted;
    } 
    
    public String addItemQty(String itemCode, Double qty){
        String html = "";
        
        try{
            
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "UPDATE ICITEMS SET QTY = (QTY + "+ qty+ ") WHERE ITEMCODE = '"+ itemCode+ "'";
            
            stmt.executeUpdate(query);
            
        }catch(SQLException e){
            html += e.getMessage();
        }
        
        return html;
    }
    
    public String postInvoice(String inNo, HttpSession session, HttpServletRequest request){
        String posted = "";
        
        Sys sys = new Sys();
        
        String batchNo = this.getApInBatchNo(inNo);
        
        String dtbCode = sys.getOne(schema+".APDTBS", "DTBCODE", "INVDFLT = 1");
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWPOINDTLS WHERE INNO = '"+ inNo+ "'";
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count = 0;
            
            while(rs.next()){
                
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                String accSetCode   = rs.getString("ACCSETCODE");
                String supplierNo   = rs.getString("SUPPLIERNO");
                String entryDate    = rs.getString("ENTRYDATE");
                String pyNo         = rs.getString("PYNO");
                Integer taxIncl     = rs.getInt("TAXINCL");
                Double taxRate      = rs.getDouble("TAXRATE");
                Double taxAmount    = rs.getDouble("TAXAMOUNT");
                Double netAmount    = rs.getDouble("NETAMOUNT");
                Double amount       = rs.getDouble("AMOUNT");
                Double total        = rs.getDouble("TOTAL");
                
                ICAccountSet iCAccountSet = new ICAccountSet(accSetCode);
                
                GLAccount gLAccount = new GLAccount(iCAccountSet.apClrAcc, schema);
                
                PoPyHdr poPyHdr = new PoPyHdr(pyNo, schema);
                
                this.createApInHdr(Integer.parseInt(batchNo), inNo, gLAccount.accountName, supplierNo, entryDate, pYear, pMonth, poPyHdr.poNo);
                                               
                this.createApInDtls(Integer.parseInt(batchNo), inNo, dtbCode, taxIncl, taxRate, taxAmount, netAmount, amount, total, session, request);
            
                count++;
            }
            
            posted = count > 0? "1": "";
            
        }catch(SQLException | NumberFormatException e){
            posted += e.getMessage();
        }
        
        return posted;
    }
    
    public String getApInBatchNo(String srcDocNo){
        String html = "";
        
        Sys sys = new Sys();
        
        String batchNo = sys.getOne(schema+".APINBATCHES", "BATCHNO", "SRCDOCNO = '"+ srcDocNo+ "'");
        
        if(batchNo == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id = sys.generateId(schema+".APINBATCHES", "ID");
                
                String query= "INSERT INTO "+schema+".APINBATCHES "
                        + "("
                        + "ID, BATCHNO, BATCHDESC, SRCDOCNO, DATECREATED, DATEEDITED, "
                        + "RTP)"
                        + "VALUES"
                        + "("
                        + id+ ","
                        + id+ ","
                        + "'PO Generated Batch', "
                        + "'"+ srcDocNo+ "', "
                        + "'"+ sys.getLogDate()+ "', "
                        + "'"+ sys.getLogDate()+ "', "
                        + 1
                        + ")";
                
                Integer saved = stmt.executeUpdate(query);
                
                if(saved == 1){
                    html += id;
                }
                
            }catch(SQLException e){
                html += e.getMessage();
            }
        }else{
            html += batchNo;
        }
        
        return html;
    }
    
    public String createApInHdr(Integer batchNo, String inNo, String inDesc, String supplierNo, String entryDate, Integer pYear, Integer pMonth, String poNo){
        String html = "";
        
        Sys sys = new Sys();
        
        if(! sys.recordExists(schema+".APINHDR", "BATCHNO = "+ batchNo+ " AND INNO = '"+ inNo+ "'")){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                Integer id = sys.generateId(schema+".APINHDR", "ID");

                String query = "INSERT INTO "+schema+".APINHDR "
                        + "("
                        + "ID, BATCHNO, INNO, INDESC, SUPPLIERNO, "
                        + "ENTRYDATE, PYEAR, PMONTH, PONO"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ batchNo+ "', "
                        + "'"+ inNo+ "', "
                        + "'"+ inDesc+ "', "
                        + "'"+ supplierNo+ "', "
                        + "'"+ entryDate+ "', "
                        + pYear+ ", "
                        + pMonth+ ", "
                        + "'"+ poNo+ "' "
                        + ")";

                stmt.executeUpdate(query);

            }catch(SQLException e){
                html += e.getMessage();
            }
        }
        
        return html;
    }
    
    public String createApInDtls(Integer batchNo, String inNo, String dtbCode, 
            Integer taxIncl, Double taxRate, Double taxAmount, Double netAmount, 
            Double amount, Double total, HttpSession session, HttpServletRequest request){
        
        String html = "";
        
        Sys sys = new Sys();
        
        try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query ;
                
                Integer sid = sys.generateId(schema+".APINDTLS", "ID");
                
                String lineNo_ = sys.getNextNo(schema+".APINDTLS", "LINENO", "BATCHNO = "+ batchNo+ " AND INNO = '"+ inNo+ "'", "", 1);
                Integer lineNo = Integer.parseInt(lineNo_);

                query = "INSERT INTO "+schema+".APINDTLS "
                        + "("
                        + "ID, BATCHNO, INNO, LINENO, DTBCODE, "
                        + "TAXINCL, TAXRATE, TAXAMOUNT, NETAMOUNT, AMOUNT, TOTAL, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ")"
                        + "VALUES"
                        + "("
                        + sid+ ", "
                        + batchNo+ ", "
                        + "'"+ inNo+ "', "
                        + lineNo+ ", "
                        + "'"+ dtbCode+ "', "
                        + taxIncl+ ", "
                        + taxRate+ ", "
                        + taxAmount+ ", "
                        + netAmount+ ", "
                        + amount+ ", "
                        + total+ ", "
                        + "'"+ sys.getLogUser(session)+"', "
                        + "'"+ sys.getLogDate()+ "', "
                        + "'"+ sys.getLogTime()+ "', "
                        + "'"+ sys.getClientIpAdr(request)+ "'"
                        + ")";


                stmt.executeUpdate(query);

            }catch (SQLException | NumberFormatException e){
                html += e.getMessage();
            }
        
        return html;
    }
    
}
