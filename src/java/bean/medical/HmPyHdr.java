/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package bean.medical;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class HmPyHdr {
    public String pyNo;
    public String pyDesc;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String ptNo;
    public String fullName;
    public String regNo;
    public String tillNo;
    public String pmCode;
    public String docNo;
    public Double bill;
    public Double tender;
    public Double change;
    public Boolean cleared;
    public Boolean posted;
    
    public HmPyHdr(String pyNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWHMPYHDR WHERE PYNO = '"+ pyNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.pyNo               = rs.getString("PYNO");			
                this.pyDesc             = rs.getString("PYDESC");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");	
                this.ptNo               = rs.getString("PTNO");
                this.fullName           = rs.getString("FULLNAME");
                this.regNo              = rs.getString("REGNO");
                this.tillNo             = rs.getString("TILLNO");
                this.pmCode             = rs.getString("PMCODE");
                this.docNo              = rs.getString("DOCNO");
                this.bill               = rs.getDouble("BILL");
                this.tender             = rs.getDouble("TENDER");
                this.change             = rs.getDouble("CHANGE");
                this.cleared            = rs.getBoolean("CLEARED");
                this.posted             = rs.getBoolean("POSTED");
            }
        }catch (SQLException e){
            e.getMessage();
        }
    }
    
}
