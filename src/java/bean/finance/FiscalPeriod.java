
package bean.finance;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class FiscalPeriod {
    public String fiscalYear;
    public Integer pYear;
    public Integer pMonth;
    public Boolean active;
    
    public FiscalPeriod(Integer pYear, Integer pMonth){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM FNFISCALPRD WHERE PYEAR = '"+ pYear+ "' AND PMONTH = '"+ pMonth+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.fiscalYear     = rs.getString("FISCALYEAR");			
                this.pYear          = rs.getInt("PYEAR");			
                this.pMonth         = rs.getInt("PMONTH");			
                this.active         = rs.getBoolean("ACTIVE");			
            } 
        }catch(Exception e){
           
        }
    }
    
}
