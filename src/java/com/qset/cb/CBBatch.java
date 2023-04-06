package com.qset.cb;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class CBBatch {
    public String batchNo;
    public String batchDesc;
    public String dateCreated;
    public String bkBranchCode;
    public String bkBranchName;
    public String dateEdited;
    public Boolean rtp;
    public Boolean posted;
    
    public CBBatch(Integer batchNo){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM VIEWCBBATCHES WHERE BATCHNO = "+ batchNo+ " ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.batchNo            = rs.getString("BATCHNO");			
                this.batchDesc          = rs.getString("BATCHDESC");			
                this.dateCreated        = rs.getString("DATECREATED");	
                this.bkBranchCode       = rs.getString("BKBRANCHCODE");
                this.bkBranchName       = rs.getString("BKBRANCHNAME");
                this.dateEdited         = rs.getString("DATEEDITED");			
                this.rtp                = rs.getBoolean("RTP");			
                this.posted             = rs.getBoolean("POSTED");			
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
}