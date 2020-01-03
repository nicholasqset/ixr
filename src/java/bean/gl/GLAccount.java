package bean.gl;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class GLAccount {
    public String id;
    public String accountCode;
    public String accountName;
    public String normalBal;
    public String accTypeCode;
    public String accGrpCode;
    public Boolean active;
    
    public GLAccount(String accountCode, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWGLACCOUNTS WHERE ACCOUNTCODE = '"+ accountCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id                 = rs.getString("ID");			
                this.accountCode        = rs.getString("ACCOUNTCODE");			
                this.accountName        = rs.getString("ACCOUNTNAME");			
                this.normalBal          = rs.getString("NORMALBAL");			
                this.accTypeCode        = rs.getString("ACCTYPECODE");			
                this.accGrpCode         = rs.getString("ACCGRPCODE");			
                this.active             = rs.getBoolean("ACTIVE");			
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
    
}
