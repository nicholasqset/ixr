
package com.qset.medical;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author Nicholas
 */
public class MedRegistration {
    public String regNo;
    public String regType;
    public String ptNo;
    public String ptType;
    public Integer pYear;
    public Integer pMonth;
    public String regDate;
    public Boolean triaged;
    public Boolean discharged;
    public String drNo;
    public String nrNo;
    public String remarks;
    
    public MedRegistration(String regNo){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM VIEWHMREGISTRATION WHERE REGNO = '"+ regNo +"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.regNo              = rs.getString("REGNO");			
                this.regType            = rs.getString("REGTYPE");			
                this.ptNo               = rs.getString("PTNO");
                this.ptType             = rs.getString("PTTYPE");
                this.pYear              = rs.getInt("PYEAR");
                this.pMonth             = rs.getInt("PMONTH");
                this.regDate            = rs.getString("REGDATE");
                this.triaged            = rs.getBoolean("TRIAGED");
                this.discharged         = rs.getBoolean("DISCHARGED");
                this.drNo               = rs.getString("DRNO");
                this.nrNo               = rs.getString("NRNO");
                this.remarks            = rs.getString("REMARKS");
            }
        }catch(Exception e){
            
        }
    }
}
