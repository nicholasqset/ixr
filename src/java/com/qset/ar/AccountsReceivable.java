package com.qset.ar;

import com.qset.conn.ConnectionProvider;
import com.qset.finance.DefaultCoBank;
import com.qset.finance.FinConfig;
import com.qset.gl.GeneralLedger;
import com.qset.ic.ICAccountSet;
import com.qset.ic.ICItem;
import com.qset.ic.ICItemCategory;
import java.sql.Connection;
import java.sql.Statement;
import com.qset.sys.Sys;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 *
 * @author nicholas
 */
public class AccountsReceivable {
    public String schema;
    
    public AccountsReceivable(String schema){
        this.schema = schema;
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
            query = "SELECT SUM(AMOUNT)SM FROM "+schema+ ".VIEWARINDTLS WHERE BATCHNO = "+ batchNo+ "";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                amount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        return amount;
    }
    
    public Double getInOrgAmount(String inNo){
        Double amount = 0.0;
        
//        Sys system = new Sys();
//        
//        String orgAmountStr = system.getOne("VIEWARINDTLS", "SUM(AMOUNT)", "BATCHNO = "+ batchNo+ " AND INNO = '"+ inNo+ "'");
//        orgAmountStr = (orgAmountStr != null && ! orgAmountStr.trim().equals(""))? orgAmountStr: "0";
//        
//        orgAmount = Double.parseDouble(orgAmountStr);
//        
//        return orgAmount;
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(AMOUNT)SM FROM "+schema+".VIEWARINDTLS WHERE INNO = '"+ inNo+ "'";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                amount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        return amount;
    }
    
//    public Integer postInBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
    public String postInBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
//        Integer batchPosted = 0;
        String batchPosted = "";
        
        Sys system = new Sys();
        GeneralLedger generalLedger = new GeneralLedger(schema);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            FinConfig finConfig = new FinConfig(schema);
            
            String query = "SELECT * FROM "+schema+".VIEWARINDTLS WHERE BATCHNO = "+ batchNo+ " ORDER BY INNO ";
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count           = 0;
            Integer entryCount      = 0;
            Integer entryCreated    = 0;
            while(rs.next()){
                
                String batchDesc    = rs.getString("BATCHDESC");
                String inNo         = rs.getString("INNO");
                String inDesc       = rs.getString("INDESC");
                String entryType    = rs.getString("ENTRYTYPE");
                String customerNo   = rs.getString("CUSTOMERNO");
//                String fullName     = rs.getString("FULLNAME");
                String fullName     = rs.getString("CUSTOMERNAME");
                String cusGrpCode   = rs.getString("CUSGRPCODE");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                String itemDtbCode  = rs.getString("ITEMDTBCODE");
                Integer taxIncl     = rs.getInt("TAXINCL");
                Double qty          = rs.getDouble("QTY");
                Double taxAmount    = rs.getDouble("TAXAMOUNT");
//                Double netAmount    = rs.getDouble("NETAMOUNT");
                Double total        = rs.getDouble("TOTAL");
                
                ARCustomerGroup aRCustomerGroup = new ARCustomerGroup(cusGrpCode, schema);
                ARAccountSet aRAccountSet = new ARAccountSet(aRCustomerGroup.accSetCode, schema);
                
//                ARItem aRitem = new ARItem(itemDtbCode);
                
//                String dtbCode;
//                if(entryType.equals("I")){
//                    dtbCode = aRitem.dtbCode;
//                }else{
//                    dtbCode = itemDtbCode;
//                }
//                
//                if(entryType.equals("S")){
//                    
//                }
                
                Double totalItemCost;
                Double revAmount;
                
                if(taxAmount > 0){
                    revAmount = taxIncl == 1? total - taxAmount: total;
                    if(entryType.equals("I")){
                        
                        ICItem iCItem = new ICItem(itemDtbCode, schema);
                        ICItemCategory iCItemCategory = new ICItemCategory(iCItem.catCode, schema);
                        ICAccountSet iCAccountSet = new ICAccountSet(iCItem.accSetCode, schema); 
                        
//                        totalItemCost = qty * aRitem.unitCost;
                        totalItemCost = qty * iCItem.unitCost;
                        for(int i = 0; i < 5; i++){
                            if(i == 0){
                                Double newTotal = taxIncl == 1? total: total + taxAmount;
//                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, customerNo+ "-"+ fullName+ "-"+ inNo, aRAccountSet.rCtlAcc, "DR", total, 0.0, pYear, pMonth, session, request);
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, customerNo+ "-"+ fullName+ "-"+ inNo, aRAccountSet.rCtlAcc, "DR", newTotal, 0.0, pYear, pMonth, session, request);
                            }else if(i == 1){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, inNo, iCItemCategory.revAcc, "CR", 0.0, revAmount, pYear, pMonth, session, request);
                            }else if(i == 2){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, inNo, iCAccountSet.invCtlAcc, "CR", 0.0, totalItemCost, pYear, pMonth, session, request);
                            }else if(i == 3){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, inNo, iCItemCategory.cosAcc, "DR", totalItemCost, 0.0, pYear, pMonth, session, request);
                            }else if(i == 4){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, inNo, finConfig.taxLbAcc, "CR", 0.0, taxAmount, pYear, pMonth, session, request);
                            }
                            count++;
                        }
                    }else{
                        ARDistribution aRDistribution = new ARDistribution(itemDtbCode, schema);
                        for(int i = 0; i < 3; i++){
                            if(i == 0){
                                Double newTotal = taxIncl == 1? total: total + taxAmount;
//                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, customerNo+ "-"+ fullName+ "-"+ inNo, aRAccountSet.rCtlAcc, "DR", total, 0.0, pYear, pMonth, session, request);
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, customerNo+ "-"+ fullName+ "-"+ inNo, aRAccountSet.rCtlAcc, "DR", newTotal, 0.0, pYear, pMonth, session, request);
                            }else if(i == 1){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, inNo, aRDistribution.revAcc, "CR", 0.0, revAmount, pYear, pMonth, session, request);
                            }else if(i == 2){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, customerNo+ "-"+ fullName+ "-"+ inNo, finConfig.taxLbAcc, "CR", 0.0, taxAmount, pYear, pMonth, session, request);
                            }
                            count++;
                        }
                    }
                }else{
                    if(entryType.equals("I")){
                        ICItem iCItem = new ICItem(itemDtbCode, schema);
                        ICItemCategory iCItemCategory = new ICItemCategory(iCItem.catCode, schema);
                        ICAccountSet iCAccountSet = new ICAccountSet(iCItem.accSetCode, schema);
//                        totalItemCost = qty * aRitem.unitCost;
                        totalItemCost = qty * iCItem.unitCost;
                        for(int i = 0; i < 4; i++){
                            if(i == 0){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, customerNo+ "-"+ fullName+ "-"+ inNo, aRAccountSet.rCtlAcc, "DR", total, 0.0, pYear, pMonth, session, request);
                            }else if(i == 1){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, inNo, iCItemCategory.revAcc, "CR", 0.0, total, pYear, pMonth, session, request);
                            }else if(i == 2){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, inNo, iCAccountSet.invCtlAcc, "CR", 0.0, totalItemCost, pYear, pMonth, session, request);
                            }else if(i == 3){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, inNo, iCItemCategory.cosAcc, "DR", totalItemCost, 0.0, pYear, pMonth, session, request);
                            }
                            count++;
                        }
                    }else{
                        ARDistribution aRDistribution = new ARDistribution(itemDtbCode, schema);
                        for(int i = 0; i < 2; i++){
                            if(i == 0){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, customerNo+ "-"+ fullName+ "-"+ inNo, aRAccountSet.rCtlAcc, "DR", total, 0.0, pYear, pMonth, session, request);
                            }else if(i == 1){
                                entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-IN", inNo, inDesc, inNo, aRDistribution.revAcc, "CR", 0.0, total, pYear, pMonth, session, request);
                            }
                            count++;
                        }
                    }
                }
                count++;
            }
            
            if(count > 0){
//                batchPosted = 1;
                batchPosted = "1";
            }
            
        }catch(Exception e){
            batchPosted = e.getMessage();
        }
        return batchPosted;
    }
    
    public Double getPyUnAplAmount(String inNo, String pyNo){
        Double unAplAmount;
        
//        Sys system = new Sys();
        
//        String orgAmountStr = system.getOne("VIEWARINDTLS", "SUM(AMOUNT) SM", "BATCHNO = "+ srcBatchNo+ " AND INNO = '"+ inNo+ "'");
//        orgAmountStr = (orgAmountStr != null && ! orgAmountStr.trim().equals(""))? orgAmountStr: "0";
        
        Double orgAmount = this.getInOrgAmount(inNo);
        
//        String aplAmountStr = system.getOne("ARPYDTLS", "SUM(APLAMOUNT) SM", "BATCHNO = "+ batchNo+ " AND PYNO = '"+ pyNo+ "' AND SRCBATCHNO = "+ srcBatchNo+ " AND DOCNO = '"+ inNo+ "'");
//        aplAmountStr = (aplAmountStr != null && ! aplAmountStr.trim().equals(""))? aplAmountStr: "0";
        
        Double aplAmount = 0.0;
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(APLAMOUNT)SM FROM "+schema+ ".VIEWAPPYDTLS WHERE PYNO = '"+ pyNo+ "' AND DOCNO = '"+ inNo+ "'";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                aplAmount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        unAplAmount = orgAmount - aplAmount;
        
        return unAplAmount;
    }
    
    
    
    public Integer postPyBatch(Integer batchNo, HttpSession session, HttpServletRequest request){
        Integer batchPosted = 0;
        
        Sys system = new Sys();
        GeneralLedger generalLedger = new GeneralLedger(schema);
        
        DefaultCoBank defaultCoBank = new DefaultCoBank(schema);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM "+schema+".VIEWARPYDTLS WHERE BATCHNO = "+ batchNo+ " ORDER BY PYNO ";
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count           = 0;
            Integer entryCount      = 0;
            Integer entryCreated    = 0;
            while(rs.next()){
                
                String batchDesc    = rs.getString("BATCHDESC");
                String pyNo         = rs.getString("PYNO");
                String pyDesc       = rs.getString("PYDESC");
                String docNo        = rs.getString("DOCNO");
                String customerNo   = rs.getString("CUSTOMERNO");
//                String fullName     = rs.getString("FULLNAME");
                String fullName     = rs.getString("CUSTOMERNAME");
                String cusGrpCode   = rs.getString("CUSGRPCODE");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                Double aplAmount    = rs.getDouble("APLAMOUNT");
                
                ARCustomerGroup aRCustomerGroup = new ARCustomerGroup(cusGrpCode, schema);
                ARAccountSet aRAccountSet = new ARAccountSet(aRCustomerGroup.accSetCode, schema);
                
                for(int i = 0; i < 2; i++){
                    if(i == 0){
                        entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-PY", pyNo, pyDesc, docNo, aRAccountSet.rCtlAcc, "CR", 0.0, aplAmount, pYear, pMonth, session, request);
                    }else if(i == 1){
                        entryCreated = generalLedger.createBatchDtls(batchNo, batchDesc, "AR-PY", pyNo, pyDesc, customerNo+ "-"+ fullName, defaultCoBank.bkAcc, "DR", aplAmount, 0.0, pYear, pMonth, session, request);
                    }
                    count++;
                }
                
                count++;
            }
            
            if(count > 0){
                batchPosted = 1;
            }
            
        }catch(SQLException e){
            e.getMessage();
        }
        return batchPosted;
    }
    
    public Double getPyBatchAmount(Integer batchNo){
        Double amount = 0.0;
        
//        Sys system = new Sys();
//        
//        String amount_ = system.getOne("VIEWARPYDTLS", "SUM(APLAMOUNT)", "BATCHNO = "+ batchNo+ "");
//        amount_ = amount_ != null? amount_: "0";
//        amount = Double.parseDouble(amount_);
//        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            query = "SELECT SUM(APLAMOUNT)SM FROM "+schema+".VIEWARPYDTLS WHERE BATCHNO = "+ batchNo+ "";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                amount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
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
            query = "SELECT SUM(APLAMOUNT)SM FROM "+schema+".VIEWARPYDTLS WHERE PYNO = '"+ pyNo+ "'";
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                amount = rs.getDouble("SM");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        return amount;
//        return orgAmount;
    }
    
}
