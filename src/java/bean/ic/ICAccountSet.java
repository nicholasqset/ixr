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
public class ICAccountSet {
    public String id;
    public String accSetCode;
    public String accSetName;
    public String invCtlAcc;
    public String apClrAcc;
    
    public ICAccountSet(String accSetCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM ICACCSETS WHERE ACCSETCODE = '"+ accSetCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id             = rs.getString("ID");			
                this.accSetCode     = rs.getString("ACCSETCODE");			
                this.accSetName     = rs.getString("ACCSETNAME");			
                this.invCtlAcc      = rs.getString("INVCTLACC");			
                this.apClrAcc       = rs.getString("APCLRACC");			
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
}
