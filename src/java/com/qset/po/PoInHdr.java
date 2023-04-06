package com.qset.po;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class PoInHdr {
  public String id;
    public String inNo;
    public String inDesc;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String supplierNo;
    public String fullName;
    public String pyNo;
    public Boolean posted;
    
    public PoInHdr(String inNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWPOINHDR WHERE INNO = '"+ inNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.inNo               = rs.getString("INNO");			
                this.inDesc             = rs.getString("INDESC");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");	
                this.supplierNo         = rs.getString("SUPPLIERNO");
                this.fullName           = rs.getString("FULLNAME");
                this.pyNo               = rs.getString("PYNO");
                this.posted             = rs.getBoolean("POSTED");
            }
        }catch (Exception e){
            e.getMessage();
        }
    }
    
}