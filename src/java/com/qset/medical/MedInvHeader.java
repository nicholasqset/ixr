
package com.qset.medical;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import com.qset.sys.Sys;

/**
 *
 * @author Nicholas
 */
public class MedInvHeader {
    public String regNo;
    public String invType;
    public String invNo;
    public String invDate;
    public Double amount = 0.00;
    public Boolean paid;
    
    
    public MedInvHeader(String invNo){
        try{
            Sys system = new Sys();
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM HMINVSHDR WHERE INVNO = '"+invNo+"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.regNo              = rs.getString("REGNO");			
                this.invType            = rs.getString("INVTYPE");			
                this.invNo              = rs.getString("INVNO");
                this.invDate            = rs.getString("INVDATE");

//                String amountInvDtls_    = system.getOne("HMINVSDTLS", "SUM(AMOUNT)", "INVNO = '"+ invNo +"'");
                String amountInvDtls_   = system.getOneAgt("HMINVSDTLS", "SUM", "AMOUNT", "SM", "INVNO = '"+ invNo +"'");

                if(amountInvDtls_ != null){
                    this.amount = Double.parseDouble(amountInvDtls_);
                }
                
                this.paid               = rs.getBoolean("PAID");

            }
        }catch(Exception e){
            
        }
    }
}
