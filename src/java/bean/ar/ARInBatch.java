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
public class ARInBatch {
    public String id;
    public String batchNo;
    public String batchDesc;
    public String dateCreated;
    public String dateEdited;
    public Boolean rtp;
    public Boolean posted;
    
    public ARInBatch(String batchNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".ARINBATCHES WHERE BATCHNO = '"+ batchNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id                 = rs.getString("ID");			
                this.batchNo            = rs.getString("BATCHNO");			
                this.batchDesc          = rs.getString("BATCHDESC");			
                this.dateCreated        = rs.getString("DATECREATED");			
                this.dateEdited         = rs.getString("DATEEDITED");			
                this.rtp                = rs.getBoolean("RTP");			
                this.posted             = rs.getBoolean("POSTED");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
    
    
}
