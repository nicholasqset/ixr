
package com.qset.high;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class HighCalendar {
    public Integer academicYear;
    public String termCode;
    public String startDate;
    public String endDate;
    
    public HighCalendar(String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+comCode+".HGCALENDAR WHERE ACTIVE = 1";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.academicYear   = rs.getInt("ACADEMICYEAR");			
                this.termCode       = rs.getString("TERMCODE");			
                this.startDate      = rs.getString("STARTDATE");
                this.endDate        = rs.getString("ENDDATE");
            }
        
        }catch (SQLException  e){
            System.out.print(e.getMessage());
        }
    }
}
