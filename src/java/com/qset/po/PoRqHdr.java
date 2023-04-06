package com.qset.po;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class PoRqHdr {
    
    public String id;
    public String rqNo;
    public String rqDesc;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String supplierNo;
    public String fullName;
    public String supplierName;
    
    public PoRqHdr(String rqNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWPORQHDR WHERE RQNO = '"+ rqNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.rqNo               = rs.getString("RQNO");			
                this.rqDesc             = rs.getString("RQDESC");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");	
                this.supplierNo         = rs.getString("SUPPLIERNO");
                this.fullName           = rs.getString("FULLNAME");
                this.supplierName       = rs.getString("SUPPLIERNAME");
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
    
}
