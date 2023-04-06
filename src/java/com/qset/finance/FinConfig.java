package com.qset.finance;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class FinConfig {
    public String taxAth = "";
    public String taxLbAcc = "";
    public Double vatRate = 0.0;
    
    public FinConfig(String schema){
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ schema+ ".FNCONFIG";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.taxAth         = rs.getString("TAXATH");			
                this.taxLbAcc       = rs.getString("TAXLBACC");			
                this.vatRate        = rs.getDouble("VATRATE");			
            }
        
        }catch (SQLException  e){
            e.getMessage();
        }
        catch (Exception  e){
            e.getMessage();
        }
        
    }
    
}
