package com.qset.hr;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class LeaveConfig {
    public Boolean useRoster = false;
    
    public LeaveConfig(){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM HRLVCONF";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.useRoster         = rs.getBoolean("USEROSTER");			
            }
        }catch (SQLException  e){
            e.getMessage();
        }
        catch (Exception  e){
            e.getMessage();
        }
        
    }
    
}