
package com.qset.ap;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class APInHdr {
    public Integer batchNo;
    public String batchDesc;
    public String inNo;
    public String inDesc;
    public String supplierNo;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String poNo;
    public String orderNo;
    public boolean applied;
    
    public APInHdr(String inNo){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM VIEWAPINHDR WHERE INNO = '"+ inNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.batchNo            = rs.getInt("BATCHNO");			
                this.batchDesc          = rs.getString("BATCHDESC");			
                this.inNo               = rs.getString("INNO");			
                this.inDesc             = rs.getString("INDESC");			
                this.supplierNo         = rs.getString("SUPPLIERNO");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");			
                this.poNo               = rs.getString("PONO");			
                this.orderNo            = rs.getString("ORDERNO");			
                this.applied            = rs.getBoolean("APPLIED");			
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
    
}
