
package com.qset.ar;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class ARDistribution {
    public String id;
    public String dtbCode;
    public String dtbName;
    public String revAcc;
    public String invAcc;
    public String cosAcc;
    
    public ARDistribution(String dtbCode, String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ comCode+ ".ARDTBS WHERE DTBCODE = '"+ dtbCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id             = rs.getString("ID");			
                this.dtbCode        = rs.getString("DTBCODE");			
                this.dtbName        = rs.getString("DTBNAME");			
                this.revAcc         = rs.getString("REVACC");			
                this.invAcc         = rs.getString("INVACC");			
                this.cosAcc         = rs.getString("COSACC");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
}
