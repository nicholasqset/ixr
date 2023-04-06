package com.qset.am;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class AMAstStatusType {
    public String statusCode;
    public String statusName;
    public String statusType;
    
    public AMAstStatusType(String statusType){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM AMASTSTATUS WHERE STATUSCODE = '"+ statusType+ "'";
                
            ResultSet rs = stmt.executeQuery(query);
            Integer count = 0;
            while(rs.next()){
                this.statusCode = rs.getString("STATUSCODE");
                this.statusName = rs.getString("STATUSNAME");
                this.statusType = rs.getString("STATUSTYPE");
                
                count++;
            }
            
            if(count == 0){
                switch(statusType){
                    case "NM":
                        this.statusCode = "Normal";
                        break;
                    case "RD":
                        this.statusCode = "Ready to Dispose";
                        break;
                    case "DI":
                        this.statusCode = "Disposed";
                        break;
                    case "SV":
                        this.statusCode = "Salvaged";
                        break;
                }
            }
        }catch(Exception e){
            e.getMessage();
        }
    }
    
}
