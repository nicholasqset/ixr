
package bean.ap;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class APAccountSet {
    public String id;
    public String accSetCode;
    public String accSetName;
    public String pCtlAcc;
    
    public APAccountSet(String accSetCode, String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ comCode+ ".APACCSETS WHERE ACCSETCODE = '"+ accSetCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id             = rs.getString("ID");			
                this.accSetCode     = rs.getString("ACCSETCODE");			
                this.accSetName     = rs.getString("ACCSETNAME");			
                this.pCtlAcc        = rs.getString("PCTLACC");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
}