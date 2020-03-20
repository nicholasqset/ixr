
package bean.finance;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class DefaultCoBank {
    public String bKBranchCode;
    public String bKBranchName;
    public String accountNo;
    public String bkAcc;
    public String woAcc;
    
    public DefaultCoBank(String comCode){
        try{
            
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ comCode+ ".VIEWFNCOBANKS WHERE ISDEFAULT = 1";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.bKBranchCode   = rs.getString("BKBRANCHCODE");			
                this.bKBranchName   = rs.getString("BKBRANCHNAME");			
                this.accountNo      = rs.getString("ACCOUNTNO");			
                this.bkAcc          = rs.getString("BKACC");
                this.woAcc          = rs.getString("WOACC");
            }
            
        }catch (SQLException  e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
    }
    
}
