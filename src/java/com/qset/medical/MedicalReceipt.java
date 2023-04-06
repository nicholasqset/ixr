
package com.qset.medical;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author Nicholas
 */
public class MedicalReceipt {
    public String invNo;
    public String rcptNo;
    public String rcptDate;
    public String pmCode;
    public String pmName;
    public String docNo;
    public Double amount = 0.00;
    
    public MedicalReceipt(String rcptNo){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM VIEWHMRECEIPTS WHERE RCPTNO = '"+ rcptNo +"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.invNo              = rs.getString("INVNO");
                this.rcptNo             = rs.getString("RCPTNO");	
                this.rcptDate           = rs.getString("RCPTDATE");			
                this.pmCode             = rs.getString("PMCODE");			
                this.pmName             = rs.getString("PMNAME");			
                this.docNo              = rs.getString("DOCNO");			
                this.amount             = rs.getDouble("AMOUNT");			
            }
        }catch(Exception e){
            
        }
    }
    
}
