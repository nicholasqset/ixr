
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
public class APSupplierGroup {
    public String id;
    public String supGrpCode;
    public String supGrpName;
    public String accSetCode;
    public String bkBranchCode;
    public String pmCode;
    
    public APSupplierGroup(String supGrpCode, String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ comCode+ ".APSUPGRPS WHERE SUPGRPCODE = '"+ supGrpCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id                 = rs.getString("ID");			
                this.supGrpCode         = rs.getString("SUPGRPCODE");			
                this.supGrpName         = rs.getString("SUPGRPNAME");
                this.accSetCode         = rs.getString("ACCSETCODE");			
                this.bkBranchCode       = rs.getString("BKBRANCHCODE");			
                this.pmCode             = rs.getString("PMCODE");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
    
    
}