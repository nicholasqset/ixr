package com.qset.restaurant;

import com.qset.conn.ConnectionProvider;
import com.qset.finance.DefaultCoBank;
import com.qset.finance.FinConfig;
import com.qset.gl.GeneralLedger;
import com.qset.ic.ICAccountSet;
import com.qset.ic.ICItem;
import com.qset.ic.ICItemCategory;
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
public class Restaurant {
    
    public String schema;
    
    public Restaurant(String schema){
        this.schema = schema;
    }
    
    public String postReceipt(String pyNo, HttpSession session, HttpServletRequest request, String schema){
        String posted = "";
        
        GeneralLedger generalLedger = new GeneralLedger(schema);
        FinConfig finConfig = new FinConfig(schema);
        DefaultCoBank defaultCoBank = new DefaultCoBank(schema);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT PYNO, PYDESC, PYEAR, PMONTH, ITEMCODE, QTY, TAXINCL, "
                    + "SUM(UNITCOST)UNITCOST, SUM(UNITPRICE)UNITPRICE, SUM(AMOUNT)AMOUNT, "
                    + "SUM(TOTAL)TOTAL, SUM(TAXAMOUNT)TAXAMOUNT "
                    + "FROM "+schema+".VIEWRTPYDTLS "
                    + "WHERE PYNO = '"+ pyNo+"' "
                    + "GROUP BY PYNO, PYDESC, PYEAR, PMONTH, ITEMCODE, QTY, TAXINCL";
            
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count = 0;
            
            while(rs.next()){
                String pyDesc       = rs.getString("PYDESC");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                String itemCode     = rs.getString("ITEMCODE");
                Double qty          = rs.getDouble("QTY");
                Boolean taxIncl     = rs.getBoolean("TAXINCL");
//                Double unitPrice    = rs.getDouble("UNITPRICE");
                Double unitCost     = rs.getDouble("UNITCOST");
                Double amount       = rs.getDouble("AMOUNT");
                Double total        = rs.getDouble("TOTAL");
                Double taxAmount    = rs.getDouble("TAXAMOUNT");
                
                String pyNoBatch_   = pyNo.replace("PY", "");
                Integer pyNoBatch   = Integer.parseInt(pyNoBatch_);
                
                ICItem iCItem = new ICItem(itemCode, schema);
                ICItemCategory iCItemCategory = new ICItemCategory(iCItem.catCode, schema);
                ICAccountSet iCAccountSet = new ICAccountSet(iCItem.accSetCode, schema); 
                
                Double sumItemCost = qty * unitCost;
                
                for(int i = 0; i < 5; i++){
                    Double newTotal = total;
                    if(i == 0){
                        if(! taxIncl){
                            newTotal = amount;
                        }
                        generalLedger.createBatchDtls(pyNoBatch, "POS Generated Batch", "PS-PY", pyNo, pyDesc, pyNo, defaultCoBank.bkAcc, "DR", newTotal, 0.0, pYear, pMonth, session, request);
                    }else if(i == 1){
                        if(taxIncl){
                            newTotal = total - taxAmount;
                        }else{
                            newTotal = amount;
                        }
                        generalLedger.createBatchDtls(pyNoBatch, "POS Generated Batch", "PS-PY", pyNo, pyDesc, pyNo, iCItemCategory.revAcc, "CR", 0.0, newTotal, pYear, pMonth, session, request);
                    }else if(i == 2){
                        generalLedger.createBatchDtls(pyNoBatch, "POS Generated Batch", "PS-PY", pyNo, pyDesc, pyNo, iCAccountSet.invCtlAcc, "CR", 0.0, sumItemCost, pYear, pMonth, session, request);
                    }else if(i == 3){
                        generalLedger.createBatchDtls(pyNoBatch, "POS Generated Batch", "PS-PY", pyNo, pyDesc, pyNo, iCItemCategory.cosAcc, "DR", sumItemCost, 0.0, pYear, pMonth, session, request);
                    }else if(i == 4){
                        if(taxIncl){
                            if(taxAmount > 0){
                                generalLedger.createBatchDtls(pyNoBatch, "POS Generated Batch", "PS-PY", pyNo, pyDesc, pyNo, finConfig.taxLbAcc, "CR", 0.0, taxAmount, pYear, pMonth, session, request);
                            }
                        }
                    }
                    count++;
                }
            }
            
            posted = count > 0? "1": "";
            
        }catch(SQLException | NumberFormatException e){
            posted += e.getMessage();
        }
        
        return posted;
    }
}
