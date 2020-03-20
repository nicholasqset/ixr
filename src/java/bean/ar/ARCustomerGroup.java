
package bean.ar;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class ARCustomerGroup {
    public String id;
    public String cusGrpCode;
    public String cusGrpName;
    public String accSetCode;
    
    public ARCustomerGroup(String cusGrpCode, String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+comCode+".ARCUSGRPS WHERE CUSGRPCODE = '"+ cusGrpCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id                 = rs.getString("ID");			
                this.cusGrpCode         = rs.getString("CUSGRPCODE");			
                this.cusGrpName         = rs.getString("CUSGRPNAME");
                this.accSetCode         = rs.getString("ACCSETCODE");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
    
    
}
