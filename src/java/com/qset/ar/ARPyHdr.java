
package com.qset.ar;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class ARPyHdr {
    public Integer batchNo;
    public String batchDesc;
    public String pyNo;
    public String pyDesc;
    public String customerNo;
    public String fullName;
    public String customerName;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String pmCode;
    public String pmName;
    public String crqNo;
    public String bkBranchCode;
    
    public ARPyHdr(String pyNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWARPYHDR WHERE PYNO = '"+ pyNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.batchNo            = rs.getInt("BATCHNO");			
                this.batchDesc          = rs.getString("BATCHDESC");			
                this.pyNo               = rs.getString("PYNO");			
                this.pyDesc             = rs.getString("PYDESC");			
                this.customerNo         = rs.getString("CUSTOMERNO");			
                this.fullName           = rs.getString("FULLNAME");			
                this.customerName       = rs.getString("CUSTOMERNAME");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");	
                this.pmCode             = rs.getString("PMCODE");			
                this.pmName             = rs.getString("PMNAME");			
                this.crqNo              = rs.getString("CQRNO");			
                this.bkBranchCode       = rs.getString("BKBRANCHCODE");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
    
}
