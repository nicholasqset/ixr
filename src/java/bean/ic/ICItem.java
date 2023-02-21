package bean.ic;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class ICItem {
    public String id;
    public String itemCode;
    public String itemName;
    public String catCode;
    public String accSetCode;
    public Double unitCost;
    public Double unitPrice;
    public Double wsprice;
    public Boolean stocked;
    public Double qty;
    public Double minlevel;
    public Double maxlevel;
    public String mfgdt;
    public String expdt;
    
    public ICItem(String itemCode, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".ICITEMS WHERE ITEMCODE = '"+ itemCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id                 = rs.getString("ID");			
                this.itemCode           = rs.getString("ITEMCODE");			
                this.itemName           = rs.getString("ITEMNAME");			
                this.catCode            = rs.getString("CATCODE");			
                this.accSetCode         = rs.getString("ACCSETCODE");			
                this.unitCost           = rs.getDouble("UNITCOST");			
                this.unitPrice          = rs.getDouble("UNITPRICE");			
                this.stocked            = rs.getBoolean("STOCKED");			
                this.qty                = rs.getDouble("QTY");			
                this.wsprice            = rs.getDouble("wsprice");			
                this.minlevel           = rs.getDouble("minlevel");
                this.maxlevel           = rs.getDouble("maxlevel");
                this.mfgdt              = rs.getString("mfgdt");
                this.expdt              = rs.getString("expdt");
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
}