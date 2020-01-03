package bean.am;

import bean.ap.APDistribution;
import bean.conn.ConnectionProvider;
import bean.gl.GeneralLedger;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import bean.sys.Sys;
import java.sql.SQLException;

/**
 *
 * @author nicholas
 */
public class AM {
    public String schema;
    
    public AM(String schema){
        this.schema = schema;
    }
    
    public String postAqBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
        String html = "";
        
        Sys system = new Sys();
        GeneralLedger generalLedger = new GeneralLedger(schema);
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM VIEWAMAQDTLS WHERE BATCHNO = "+ batchNo;
                
            ResultSet rs = stmt.executeQuery(query);
            Integer count = 0;
            while(rs.next()){
                String entryDate    = rs.getString("ENTRYDATE");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                String aqNo         = rs.getString("AQNO");
                String aqDesc       = rs.getString("AQDESC");
                String serialNo     = rs.getString("SERIALNO");
                String depCode      = rs.getString("DEPCODE");
                String depStartDate = rs.getString("DEPSTARTDATE");
                Double estLife      = rs.getDouble("ESTLIFE");
                String estExpDate   = rs.getString("ESTEXPDATE");
                Double depRate      = rs.getDouble("DEPRATE");
                Double opc          = rs.getDouble("OPC");
                
                String astCtlAcc    = rs.getString("ASTCTLACC");
                String dtbCode      = rs.getString("DTBCODE");
                String supplierNo   = rs.getString("SUPPLIERNO");
                String poNo         = rs.getString("PONO");
                
                APDistribution aPDistribution = new APDistribution(dtbCode);
                
                String createAsset = this.createAsset(aqNo, aqDesc, entryDate, serialNo, depCode, depStartDate, estLife, estExpDate, depRate, opc, session, request);
                if(createAsset.equals("1")){
                    String assetNo = system.getOne("AMASSETS", "ASSETNO", "AQNO = '"+ aqNo+ "'");
                    for(int i = 1; i <= 2; i++){
                        if(i == 1){
                            generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-AQ", aqNo+ "", aqDesc, assetNo+ "-"+ aqDesc, astCtlAcc, "DR", opc, 0.0, pYear, pMonth, session, request);
                        }else if(i == 2){
                            generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-AQ", aqNo+ "", aqDesc, assetNo+ "-"+ aqDesc, aPDistribution.glAcc, "CR", 0.0, opc, pYear, pMonth, session, request);
                        }
                    }
                    
                    String batchNo_ = this.getApInBatchNo(aqNo);
                    
                    this.createApInHdr(Integer.parseInt(batchNo_), aqNo, aqDesc, supplierNo, entryDate, pYear, pMonth, poNo);
                                               
                    this.createApInDtls(Integer.parseInt(batchNo_), aqNo, dtbCode, 1, 0.0, 0.0, opc, opc, opc, session, request);
            
                    count++;
                }
            }
            
            html += count> 0? 1: "";
        }catch(SQLException | NumberFormatException e){
            html += e.getMessage();
        }
        
        return html;
    }
    
    public String createAsset(String aqNo, String aqDesc, String aqDate, String serialNo, String depCode, String depStartDate, Double estLife, String estExpDate, Double depRate, Double opc, HttpSession session, HttpServletRequest request){
        String html = "";
        
        Sys system = new Sys();
        
        AMAstStatusType aMAstStatusType  = new AMAstStatusType("NM");
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(! system.recordExists(depCode, aqDesc)){
                
                Integer id = system.generateId("AMASSETS", "ID");
                String assetNo = system.getNextNo("AMASSETS", "ID", "", "", 7);
                
                String query = "INSERT INTO AMASSETS "
                        + "("
                        + "ID, ASSETNO, ASSETDESC, AQNO, AQDATE, SERIALNO, "
                        + "STATUSCODE, DEPCODE, DEPSTARTDATE, ESTLIFE, ESTEXPDATE, "
                        + "DEPRATE, OPC, "
                        + "ACMDEP, PDV, NBV, SALV, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ assetNo+ "', "
                        + "'"+ aqDesc+ "', "
                        + "'"+ aqNo+ "', "
                        + "'"+ aqDate+ "', "
                        + "'"+ serialNo+ "', "
                        + "'"+ aMAstStatusType.statusCode+ "', "
                        + "'"+ depCode+ "', "
                        + "'"+ depStartDate+ "', "
                        + estLife+ ", "
                        + "'"+ estExpDate+ "', "
                        + depRate+ ", "
                        + opc+ ", "
                        + 0+ ", "
                        + 0+ ", "
                        + opc+ ", "
                        + 0+ ", "
                        + "'"+ system.getLogUser(session)+"', "
                        + "'"+ system.getLogDate()+ "', "
                        + "'"+ system.getLogTime()+ "', "
                        + "'"+ system.getClientIpAdr(request)+ "'"
                        + ")";

                Integer saved = stmt.executeUpdate(query);
                
                if(saved == 1){
                    html += 1;
                }
            }
        }catch(Exception e){
            html += e.getMessage();
        }
        
        return html;
    }
    
    public String getApInBatchNo(String srcDocNo){
        String html = "";
        
        Sys system = new Sys();
        
        String batchNo = system.getOne("APINBATCHES", "BATCHNO", "SRCDOCNO = '"+ srcDocNo+ "'");
        
        if(batchNo == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id = system.generateId("APINBATCHES", "ID");
                
                String query= "INSERT INTO APINBATCHES "
                        + "("
                        + "ID, BATCHNO, BATCHDESC, SRCDOCNO, DATECREATED, DATEEDITED, "
                        + "RTP)"
                        + "VALUES"
                        + "("
                        + id+ ","
                        + id+ ","
                        + "'AM Generated Batch', "
                        + "'"+ srcDocNo+ "', "
                        + "'"+ system.getLogDate()+ "', "
                        + "'"+ system.getLogDate()+ "', "
                        + 1
                        + ")";
                
                Integer saved = stmt.executeUpdate(query);
                
                if(saved == 1){
                    html += id;
                }
                
            }catch(Exception e){
                html += e.getMessage();
            }
        }else{
            html += batchNo;
        }
        
        return html;
    }
    
    public String createApInHdr(Integer batchNo, String inNo, String inDesc, String supplierNo, String entryDate, Integer pYear, Integer pMonth, String poNo){
        String html = "";
        
        Sys system = new Sys();
        
        if(! system.recordExists("APINHDR", "BATCHNO = "+ batchNo+ " AND INNO = '"+ inNo+ "'")){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                Integer id = system.generateId("APINHDR", "ID");

                String query = "INSERT INTO APINHDR "
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

            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        return html;
    }
    
    public String createApInDtls(Integer batchNo, String inNo, String dtbCode, 
            Integer taxIncl, Double taxRate, Double taxAmount, Double netAmount, 
            Double amount, Double total, HttpSession session, HttpServletRequest request){
        
        String html = "";
        
        Sys system = new Sys();
        
        try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query ;
                
                Integer sid = system.generateId("APINDTLS", "ID");
                
                String lineNo_ = system.getNextNo("APINDTLS", "LINENO", "BATCHNO = "+ batchNo+ " AND INNO = '"+ inNo+ "'", "", 1);
                Integer lineNo = Integer.parseInt(lineNo_);

                query = "INSERT INTO APINDTLS "
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
                        + "'"+ system.getLogUser(session)+"', "
                        + "'"+ system.getLogDate()+ "', "
                        + "'"+ system.getLogTime()+ "', "
                        + "'"+ system.getClientIpAdr(request)+ "'"
                        + ")";

                stmt.executeUpdate(query);

            }catch (SQLException | NumberFormatException e){
                html += e.getMessage();
            }
        
        return html;
    }
    
    public String postDpBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
        String html = "";
        
//        Sys system = new Sys();
        GeneralLedger generalLedger = new GeneralLedger(schema);
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM VIEWAMDPDTLS WHERE BATCHNO = "+ batchNo;
                
            ResultSet rs = stmt.executeQuery(query);
            Integer count = 0;
            while(rs.next()){
                String assetNo      = rs.getString("ASSETNO");
                String assetDesc    = rs.getString("ASSETDESC");
                Double acmDepV      = rs.getDouble("ACMDEPV");
                Double nbvE         = rs.getDouble("NBVE");
                Integer entryNo     = rs.getInt("ENTRYNO");
                String entryDesc    = rs.getString("ENTRYDESC");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                Double depV         = rs.getDouble("DEPV");
                String depExpAcc    = rs.getString("DEPEXPACC");
                String acmDepAcc    = rs.getString("ACMDEPACC");
                
                Statement stmtAst = conn.createStatement();
                
                Integer updated = stmtAst.executeUpdate("UPDATE AMASSETS SET ACMDEP = "+ acmDepV+ ", NBV = "+ nbvE+ " WHERE ASSETNO = '"+ assetNo+ "'");
                if(updated == 1){
                    for(int i = 1; i <= 2; i++){
                        if(i == 1){
                            generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-DP", entryNo+ "", entryDesc, assetNo+ "-"+ assetDesc, depExpAcc, "DR", depV, 0.0, pYear, pMonth, session, request);
                        }else if(i == 2){
                            generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-DP", entryNo+ "", entryDesc, assetNo+ "-"+ assetDesc, acmDepAcc, "CR", 0.0, depV, pYear, pMonth, session, request);
                        }
                    }
                    
                    count++;
                }
            }
            
            html += count> 0? 1: "";
        }catch(SQLException | NumberFormatException e){
            html += e.getMessage();
        }
        
        return html;
    }
    
    public String postDiBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
        String html = "";
        
        GeneralLedger generalLedger = new GeneralLedger(schema);
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM VIEWAMDIDTLS WHERE BATCHNO = "+ batchNo;
                
            ResultSet rs = stmt.executeQuery(query);
            Integer count = 0;
            while(rs.next()){
                Integer entryNo     = rs.getInt("ENTRYNO");
                String entryDesc    = rs.getString("ENTRYDESC");
                String assetNo      = rs.getString("ASSETNO");
                String assetDesc    = rs.getString("ASSETDESC");                
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                String diCostAcc    = rs.getString("DICOSTACC");
                Double nbv          = rs.getDouble("NBV");
                Double acmDepV      = rs.getDouble("ACMDEPV");
                String acmDepAcc    = rs.getString("ACMDEPACC");
                String astCtlAcc    = rs.getString("ASTCTLACC");
                Double opc          = rs.getDouble("OPC");
                String diClrAcc     = rs.getString("DICLRACC");
                Double div          = rs.getDouble("DIV");
                String diPrcdAcc    = rs.getString("DIPRCDACC");
                Double adic         = rs.getDouble("ADIC");
                
                Statement stmtAst = conn.createStatement();
                
                AMAstStatusType aMAstStatusType = new AMAstStatusType("DI");
                
                Integer updated = stmtAst.executeUpdate("UPDATE AMASSETS SET STATUSCODE = '"+ aMAstStatusType.statusCode+ "' WHERE ASSETNO = '"+ assetNo+ "'");
                if(updated == 1){
                    for(int i = 1; i <= 3; i++){
                        if(i == 1){
                            generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-DI", entryNo+ "", entryDesc, assetNo+ "-"+ assetDesc, diCostAcc, "DR", nbv, 0.0, pYear, pMonth, session, request);
                        }else if(i == 2){
                            generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-DI", entryNo+ "", entryDesc, assetNo+ "-"+ assetDesc, acmDepAcc, "DR", acmDepV, 0.0, pYear, pMonth, session, request);
                        }else if(i == 3){
                            generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-DI", entryNo+ "", entryDesc, assetNo+ "-"+ assetDesc, astCtlAcc, "CR", 0.0, opc, pYear, pMonth, session, request);
                        }
                    }
                    for(int i = 1; i <= 2; i++){
                        if(i == 1){
                            generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-DI", entryNo+ "", entryDesc, assetNo+ "-"+ assetDesc, diClrAcc, "DR", div, 0.0, pYear, pMonth, session, request);
                        }else if(i == 2){
                            generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-DI", entryNo+ "", entryDesc, assetNo+ "-"+ assetDesc, diPrcdAcc, "CR", 0.0, div, pYear, pMonth, session, request);
                        }
                    }
                    if(adic > 0){
                        for(int i = 1; i <= 2; i++){
                            if(i == 1){
                                generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-DI", entryNo+ "", entryDesc, assetNo+ "-"+ assetDesc, diCostAcc, "DR", adic, 0.0, pYear, pMonth, session, request);
                            }else if(i == 2){
                                generalLedger.createBatchDtls(batchNo, "AM Generated Batch", "AM-DI", entryNo+ "", entryDesc, assetNo+ "-"+ assetDesc, diClrAcc, "CR", 0.0, adic, pYear, pMonth, session, request);
                            }
                        }
                    }
                    count++;
                }
            }
            html += count > 0? 1: "";
        }catch(Exception e){
            html += e.getMessage();
        }
        
        return html;
    }
}