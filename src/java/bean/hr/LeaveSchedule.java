package bean.hr;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class LeaveSchedule {
    public String pfNo;
    public Integer pYear;
    public String lvTypeCode;
    public Integer balBf = 0;
    public Integer forfeited = 0;
    public Integer entitlement = 0;
    public Integer taken = 0;
    public Integer balTotal = 0;
    
    
    public LeaveSchedule(String pfNo, Integer pYear, String lvTypeCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM HRLVSCHEDULE WHERE PFNO = '"+ pfNo+ "' AND PYEAR = "+ pYear+ " AND LVTYPECODE = '"+ lvTypeCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.pfNo           = rs.getString("PFNO");
                this.pYear          = rs.getInt("PYEAR");
                this.lvTypeCode     = rs.getString("LVTYPECODE");	
                this.balBf          = rs.getInt("BALBF");
                this.forfeited      = rs.getInt("FORFEITED");
                this.entitlement    = rs.getInt("ENTITLEMENT");
                this.taken          = rs.getInt("TAKEN");
                this.balTotal       = rs.getInt("BALTOTAL");
            }
        }catch (Exception e){
            e.getMessage();
        }
    }
}