/*
package bean.ar;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
*/
/**
 *
 * @author nicholas
 */
/*
public class ARItem {
    public String id;
    public String itemCode;
    public String itemName;
    public String dtbCode;
    public Double unitCost;
    public Double unitPrice;
//    public Boolean taxExcl;
    
    public ARItem(String itemCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM ARITEMS WHERE ITEMCODE = '"+ itemCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id                 = rs.getString("ID");			
                this.itemCode           = rs.getString("ITEMCODE");			
                this.itemName           = rs.getString("ITEMNAME");			
                this.dtbCode            = rs.getString("DTBCODE");			
                this.unitCost           = rs.getDouble("UNITCOST");			
                this.unitPrice          = rs.getDouble("UNITPRICE");			
//                this.taxExcl            = rs.getBoolean("TAXEXCL");			
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
}
*/