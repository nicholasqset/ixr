package com.qset.ic;

import com.qset.conn.ConnectionProvider;
import com.qset.gl.GeneralLedger;
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
public class IC {
    public String schema;
    
    public IC(String schema){
        this.schema = schema;
    }
    
    public String postIU(String iuNo, HttpSession session, HttpServletRequest request){
        String posted;
        
        GeneralLedger generalLedger = new GeneralLedger(schema);
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ schema+ ".VIEWICIUDTLS WHERE IUNO = '"+ iuNo+"'";
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count = 0;

            while(rs.next()){
                String iuDesc       = rs.getString("IUDESC");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                String cvAcc        = rs.getString("CVACC");
                String accSetCode   = rs.getString("ACCSETCODE");
//                String itemCode     = rs.getString("ITEMCODE");
                String itemName     = rs.getString("ITEMNAME");
//                Double qty          = rs.getDouble("QTY");
                Double amount        = rs.getDouble("AMOUNT");
                
                String icNoBatch_   = iuNo.replace("IU", "");
                Integer icNoBatch   = Integer.parseInt(icNoBatch_);
                
                ICAccountSet iCAccountSet = new ICAccountSet(accSetCode, schema);
                
                for(int i = 0; i < 2; i++){
                    if(i == 0){
                        generalLedger.createBatchDtls(icNoBatch, "IC Generated Batch", "IC-IU", iuNo, iuDesc, itemName, cvAcc, "DR", amount, 0.0, pYear, pMonth, session, request);
                    }else if(i == 1){
                        generalLedger.createBatchDtls(icNoBatch, "IC Generated Batch", "IC-IU", iuNo, iuDesc, itemName, iCAccountSet.invCtlAcc, "CR", 0.0, amount, pYear, pMonth, session, request);
                    }
                }
                
                count++;
            }
            
            posted = count > 0? "1": "";
        }catch(SQLException | NumberFormatException e){
            posted = e.getMessage();
        }
        
        return posted;
    }
    
    public String effectItemQty(String itemCode, Double qty, Boolean addition, String schema){
        String effected = "";
        
        ICItem iCItem = new ICItem(itemCode, schema);
        
        if(iCItem.stocked){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;
                if(addition){
                    query = "UPDATE "+ schema+ ".ICITEMS SET QTY = (QTY + "+ qty+ ") WHERE ITEMCODE = '"+ itemCode+ "'";
                }else{
                    query = "UPDATE "+ schema+ ".ICITEMS SET QTY = (QTY - "+ qty+ ") WHERE ITEMCODE = '"+ itemCode+ "'";
                }
                Integer updated = stmt.executeUpdate(query);
                effected += updated;
            }
            catch(SQLException e){
                effected += e.getMessage();
            }
        }
        
        return effected;
    }
    
    public String postPY(String pyNo, HttpSession session, HttpServletRequest request, String schema){
        String posted;
        
        GeneralLedger generalLedger = new GeneralLedger(this.schema);
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWICPYDTLS WHERE PYNO = '"+ pyNo+"'";
            ResultSet rs = stmt.executeQuery(query);
            
            Integer count = 0;

            while(rs.next()){
                String pyDesc       = rs.getString("PYDESC");
                Integer pYear       = rs.getInt("PYEAR");
                Integer pMonth      = rs.getInt("PMONTH");
                String cvAcc        = rs.getString("CVACC");
                String accSetCode   = rs.getString("ACCSETCODE");
                String itemCode     = rs.getString("ITEMCODE");
                String itemName     = rs.getString("ITEMNAME");
                Double qty          = rs.getDouble("QTY");
                Double amount        = rs.getDouble("AMOUNT");
                
                this.effectItemQty(itemCode, qty, true, schema);
                
                String icNoBatch_   = pyNo.replace("PY", "");
                Integer icNoBatch   = Integer.parseInt(icNoBatch_);
                
                ICAccountSet iCAccountSet = new ICAccountSet(accSetCode, schema);
                
                for(int i = 0; i < 2; i++){
                    if(i == 0){
                        generalLedger.createBatchDtls(icNoBatch, "IC Generated Batch", "IC-PY", pyNo, pyDesc, itemName, iCAccountSet.invCtlAcc, "DR", amount, 0.0, pYear, pMonth, session, request);
                    }else if(i == 1){
                        generalLedger.createBatchDtls(icNoBatch, "IC Generated Batch", "IC-PY", pyNo, pyDesc, itemName, iCAccountSet.apClrAcc, "CR", 0.0, amount, pYear, pMonth, session, request);
                    }
                }
                
                count++;
            }
            
            posted = count > 0? "1": "";
        }catch(SQLException | NumberFormatException e){
            posted = e.getMessage();
        }
        
        return posted;
    }
}
