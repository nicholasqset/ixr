
package com.qset.finance;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

/**
 *
 * @author nicholas
 */
public class FiscalYear {
    public String fiscalYear;
    public String startDate;
    public String endDate;
    public Boolean active;
    
    public Integer startYear;
    public Integer endYear;
    
    public FiscalYear(String fiscalYear, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ schema+ ".FNFISCALYEAR WHERE FISCALYEAR = '"+ fiscalYear+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.fiscalYear     = rs.getString("FISCALYEAR");			
                this.startDate      = rs.getString("STARTDATE");			
                this.endDate        = rs.getString("ENDDATE");			
                this.active         = rs.getBoolean("ACTIVE");			
            }
            
            DateFormat formater = new SimpleDateFormat("yyyy-MM-dd");

            Calendar beginCalendar  = Calendar.getInstance();
            Calendar finishCalendar = Calendar.getInstance();

            beginCalendar.setTime(formater.parse(this.startDate));
            finishCalendar.setTime(formater.parse(this.endDate));
       
            this.startYear = beginCalendar.get(Calendar.YEAR);
            this.endYear = finishCalendar.get(Calendar.YEAR);
        
        }
        catch(ParseException e){
            
        }
        catch (SQLException  e){

        }
        catch(Exception e){
            
        }
    }
    
}
