
package bean.medical;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class MedicalItem {
    public String itemCode;
    public String itemName;
    public String itemDesc;
    public Boolean vatable;
    public Boolean isDrug;
    public Boolean stocked;
    public MedicalItem(String itemCode){
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
        
        try{
            stmt = conn.createStatement();
            String query = "SELECT * FROM HMITEMS WHERE ITEMCODE = '"+itemCode+"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.itemCode           = rs.getString("ITEMCODE");			
                this.itemName           = rs.getString("ITEMNAME");			
                this.itemDesc           = rs.getString("ITEMDESC");
                this.vatable            = rs.getBoolean("VATABLE") ;			
                this.isDrug             = rs.getBoolean("ISDRUG");			
                this.stocked            = rs.getBoolean("STOCKED");			
                	
            }
        
        }catch (SQLException  e){

        }
    }
    
}
