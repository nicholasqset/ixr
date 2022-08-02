/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
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
public class ARAccountSet {
    public String id;
    public String accSetCode;
    public String accSetName;
    public String rCtlAcc;
    
    public ARAccountSet(String accSetCode, String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ comCode+ ".ARACCSETS WHERE ACCSETCODE = '"+ accSetCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id             = rs.getString("ID");			
                this.accSetCode     = rs.getString("ACCSETCODE");			
                this.accSetName     = rs.getString("ACCSETNAME");			
                this.rCtlAcc        = rs.getString("RCTLACC");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
}
