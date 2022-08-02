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
public class ICItemCategory {
    public String catCode;
    public String catName;
    public String revAcc;
    public String cosAcc;
    public String cvAcc;
    public String iuAcc;
    
    public ICItemCategory(String catCode, String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ comCode+ ".ICITEMCATS WHERE CATCODE = '"+ catCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.catCode    = rs.getString("CATCODE");			
                this.catName    = rs.getString("CATNAME");			
                this.revAcc     = rs.getString("REVACC");			
                this.cosAcc     = rs.getString("COSACC");			
                this.cvAcc      = rs.getString("CVACC");			
                this.iuAcc      = rs.getString("IUACC");			
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
}
