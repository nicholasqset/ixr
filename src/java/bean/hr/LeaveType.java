package bean.hr;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class LeaveType {
    public String lvTypeCode;
    public String lvTypeName;
    public String lvType;
    public Boolean hasGender;
    public String genderCode;
    
    public LeaveType(String lvTypeCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM HRLVTYPES WHERE LVTYPECODE = '"+ lvTypeCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.lvTypeCode     = rs.getString("LVTYPECODE");			
                this.lvTypeName     = rs.getString("LVTYPENAME");			
                this.lvType         = rs.getString("LVTYPE");			
                this.hasGender      = rs.getBoolean("HASGENDER");			
                this.genderCode     = rs.getString("GENDERCODE");			
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
}
