
package com.qset.ap;

import com.qset.conn.ConnectionProvider;
import com.qset.finance.DefaultCoBank;
import com.qset.finance.FinConfig;
import com.qset.gl.GeneralLedger;
import com.qset.sys.Sys;
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
public class AccountsPayable {
    public String schema;
    
    public AccountsPayable(String schema){
        this.schema = schema;
    }
    
    public Double getInOrgAmount(String inNo){
        Double amount = 0.0;
        
//        Sys system = new Sys();
//        
//        String orgAmountStr = system.getOne("VIEWAPINDTLS", "SUM(AMOUNT)", "BATCHNO = "+ batchNo+ " AND INNO = '"+ inNo+ "'");
//        orgAmountStr = (orgAmountStr != null && ! orgAmountStr.trim().equals(""))? orgAmountStr: "0";
//        
//        orgAmount = Double.parseDouble(orgAmountStr);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(AMOUNT)SM FROM "+schema+".VIEWAPINDTLS WHERE INNO = '"+ inNo+ "'";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                amount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        
        return amount;
//        return orgAmount;
    }
    
    public Double getPyUnAplAmount(String inNo, String pyNo){
        Double unAplAmount;
        
        Sys system = new Sys();
        
        String orgAmountStr = system.getOneAgt(this.schema+".VIEWAPINDTLS", "SUM", "AMOUNT", "SM", "INNO = '"+ inNo+ "'");
        orgAmountStr = (orgAmountStr != null && ! orgAmountStr.trim().equals(""))? orgAmountStr: "0";
        
        Double orgAmount = Double.parseDouble(orgAmountStr);
        
        String aplAmountStr = system.getOneAgt(this.schema+".APPYDTLS", "SUM", "APLAMOUNT", "SM", "PYNO = '"+ pyNo+ "' AND DOCNO = '"+ inNo+ "'");
        aplAmountStr = (aplAmountStr != null && ! aplAmountStr.trim().equals(""))? aplAmountStr: "0";
        
        Double aplAmount = Double.parseDouble(aplAmountStr);
        
        unAplAmount = orgAmount - aplAmount;
        
        return unAplAmount;
    }
    
    public Double getInBatchAmount(Integer batchNo){
        Double amount = 0.0;
        
//        Sys system = new Sys();
//        
//        String amount_ = system.getOne("APINDTLS", "SUM(AMOUNT)", "BATCHNO = "+ batchNo+ "");
//        amount_ = amount_ != null? amount_: "0";
//        amount = Double.parseDouble(amount_);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(AMOUNT)SM FROM "+schema+".APINDTLS WHERE BATCHNO = "+ batchNo+ "";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                amount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        
        return amount;
    }
    
    public Integer postInBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
        Integer batchPosted = 0;
        
        Sys system = new Sys();
        GeneralLedger generalLedger = new GeneralLedger(schema);
        
        FinConfig finConfig = new FinConfig(schema);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM "+schema+".VIEWAPINDTLS WHERE BATCHNO = "+ batchNo+ " ORDER BY INNO ";
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count           = 0;
            Integer entryCount      = 0;
            Integer entryCreated    = 0;
            while(rs.next()){
                
                String batchDesc    = rs.getString("BATCHDESC");
                String inNo         = rs.getString("INNO");
                String inDesc       = rs.getString("INDESC");
                String supplierNo   = rs.getString("SUPPLIERNO");
//                String fullName     = rs.getString("FULLNAME");
                String fullName     = rs.getString("SUPPLIERNAME");
                String supGrpCode   = rs.getString("SUPGRPCODE");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                String dtbCode      = rs.getString("DTBCODE");
                String dtbName      = rs.getString("DTBNAME");
                Double taxAmount    = rs.getDouble("TAXAMOUNT");
                Double netAmount    = rs.getDouble("NETAMOUNT");
                Double total        = rs.getDouble("TOTAL");
                
                APSupplierGroup aPSupplierGroup = new APSupplierGroup(supGrpCode, schema);
                APAccountSet APAccountSet = new APAccountSet(aPSupplierGroup.accSetCode, schema);
                APDistribution aPDistribution = new APDistribution(dtbCode, schema);
                
                if(taxAmount > 0){
                    for(int i = 0; i < 3; i++){
                        if(i == 0){
                            entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AP-IN", inNo, inDesc, supplierNo+ "-"+ fullName+ "-"+ inNo, APAccountSet.pCtlAcc, "CR", 0.0, total, pYear, pMonth, session, request);
                        }else if(i == 1){
                            entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AP-IN", inNo, inDesc, dtbName+ "-"+ inNo, aPDistribution.glAcc, "DR", netAmount, 0.0, pYear, pMonth, session, request);
                        }else if(i == 2){
                            entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AP-IN", inNo, inDesc, dtbName+ "-"+ inNo, finConfig.taxLbAcc, "DR", taxAmount, 0.0, pYear, pMonth, session, request);
                        }
                        count++;
                    }
                }else{
                    for(int i = 0; i < 2; i++){
                        if(i == 0){
                            entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AP-IN", inNo, inDesc, supplierNo+ "-"+ fullName+ "-"+ inNo, APAccountSet.pCtlAcc, "CR", 0.0, total, pYear, pMonth, session, request);
                        }else if(i == 1){
                            entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AP-IN", inNo, inDesc, dtbName+ "-"+ inNo, aPDistribution.glAcc, "DR", netAmount, 0.0, pYear, pMonth, session, request);
                        }
                        count++;
                    }
                }
                
                count++;
            }
            
            if(count > 0){
                batchPosted = 1;
            }
            
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        return batchPosted;
    }
    
    public Double getPyBatchAmount(Integer batchNo){
        Double amount = 0.0;
        
//        Sys system = new Sys();
//        
//        String amount_ = system.getOne("VIEWAPPYDTLS", "SUM(APLAMOUNT)", "BATCHNO = "+ batchNo+ "");
//        amount_ = amount_ != null? amount_: "0";
//        amount = Double.parseDouble(amount_);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(APLAMOUNT)SM FROM "+schema+".VIEWAPPYDTLS WHERE BATCHNO = "+ batchNo+ "";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                amount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        
        return amount;
    }
    
    public Double getPyAmount(String pyNo){
        Double amount = 0.0;
        
//        Sys system = new Sys();
//        
//        String orgAmountStr = system.getOne("VIEWAPINDTLS", "SUM(AMOUNT)", "BATCHNO = "+ batchNo+ " AND INNO = '"+ inNo+ "'");
//        orgAmountStr = (orgAmountStr != null && ! orgAmountStr.trim().equals(""))? orgAmountStr: "0";
//        
//        orgAmount = Double.parseDouble(orgAmountStr);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(APLAMOUNT)SM FROM "+schema+".VIEWAPPYDTLS WHERE PYNO = '"+ pyNo+ "'";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                amount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        
        return amount;
//        return orgAmount;
    }
    
    public Integer postPyBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
        Integer batchPosted = 0;
        
//        Sys system = new Sys();
        GeneralLedger generalLedger = new GeneralLedger(schema);
        
        DefaultCoBank defaultCoBank = new DefaultCoBank(schema);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM "+schema+".VIEWAPPYDTLS WHERE BATCHNO = "+ batchNo+ " ORDER BY PYNO ";
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count           = 0;
            Integer entryCount      = 0;
            Integer entryCreated    = 0;
            while(rs.next()){
                
                String batchDesc    = rs.getString("BATCHDESC");
                String pyNo         = rs.getString("PYNO");
                String pyDesc       = rs.getString("PYDESC");
                String supplierNo   = rs.getString("SUPPLIERNO");
//                String fullName     = rs.getString("FULLNAME");
                String fullName     = rs.getString("SUPPLIERNAME");
                String supGrpCode   = rs.getString("SUPGRPCODE");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                Double aplAmount    = rs.getDouble("APLAMOUNT");
                
                APSupplierGroup aPSupplierGroup = new APSupplierGroup(supGrpCode, schema);
                APAccountSet APAccountSet = new APAccountSet(aPSupplierGroup.accSetCode, schema);
                
                for(int i = 0; i < 2; i++){
                    if(i == 0){
                        entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AP-PY", pyNo, pyDesc, pyNo, APAccountSet.pCtlAcc, "DR", aplAmount, 0.0, pYear, pMonth, session, request);
                    }else if(i == 1){
                        entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AP-PY", pyNo, pyDesc, supplierNo+ "-"+ fullName, defaultCoBank.bkAcc, "CR", 0.0, aplAmount, pYear, pMonth, session, request);
                    }
                    count++;
                }
                
                count++;
            }
            
            if(count > 0){
                batchPosted = 1;
            }
            
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        return batchPosted;
    }
    
    
}
