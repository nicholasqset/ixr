
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
public class APDistribution {
    public String id;
    public String dtbCode;
    public String dtbName;
    public String glAcc;
    public Boolean invDflt;
    
    public APDistribution(String dtbCode, String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ comCode+ ".APDTBS WHERE DTBCODE = '"+ dtbCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id             = rs.getString("ID");			
                this.dtbCode        = rs.getString("DTBCODE");			
                this.dtbName        = rs.getString("DTBNAME");			
                this.glAcc          = rs.getString("GLACC");			
                this.invDflt        = rs.getBoolean("INVDFLT");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
}