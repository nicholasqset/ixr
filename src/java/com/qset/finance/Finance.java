
package com.qset.finance;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.Statement;
import com.qset.sys.Sys;
import java.sql.SQLException;
/**
 *
 * @author nicholas
 */
public class Finance {
    
    String schema;
    
    public Finance(String schema){
        this.schema = schema;
    }
    
    public Integer activateNextPeriod(Integer nextPeriodYear, Integer nextPeriodMonth){
        Integer activated = 0;
        
        Sys system = new Sys();
        
        String fiscalYear = nextPeriodMonth == 1? ""+ nextPeriodYear: ""+ system.getFiscalYear(this.schema);
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            stmt.executeUpdate("UPDATE "+ this.schema+ ".FNFISCALPRD SET ACTIVE = NULL");
            
            String query;
            
            if(! system.recordExists(this.schema+ ".FNFISCALPRD", "PYEAR = "+ nextPeriodYear+ " AND PMONTH = "+ nextPeriodMonth)){
                Integer id = system.generateId("FNFISCALPRD", "ID");

                query = "INSERT INTO "+ this.schema+ ".FNFISCALPRD "
                    + "(ID, FISCALYEAR, PYEAR, PMONTH, ACTIVE)"
                    + "VALUES"
                    + "("
                    + id + ","
                    + "'"+ fiscalYear+ "',"
                    + nextPeriodYear+ ","
                    + nextPeriodMonth+ ","
                    + "1"
                    + ")";
            }else{
                query = "UPDATE "+ this.schema+ ".FNFISCALPRD SET ACTIVE = 1 WHERE PYEAR = "+ nextPeriodYear+ " AND PMONTH = "+ nextPeriodMonth;
            }

            activated = stmt.executeUpdate(query);
        }catch (SQLException e){
            System.out.println(e.getMessage());
        }
        
        return activated;
    }
    
}
