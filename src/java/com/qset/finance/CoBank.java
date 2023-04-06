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
public class CoBank {
    public String bankCode;
    public String bankName;
    public String bkBranchCode;
    public String bkBranchName;
    public String accountNo;
    public Boolean isDefault;
    public String bkAcc;
    public String woAcc;
    
    public CoBank(String bkBranchCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM VIEWFNCOBANKS WHERE BKBRANCHCODE = '"+ bkBranchCode+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.bankCode           = rs.getString("BANKCODE");			
                this.bankName           = rs.getString("BANKNAME");			
                this.bkBranchCode       = rs.getString("BKBRANCHCODE");
                this.bkBranchName       = rs.getString("BKBRANCHNAME");
                this.accountNo          = rs.getString("ACCOUNTNO");
                this.isDefault          = rs.getBoolean("ISDEFAULT");
                this.bkAcc              = rs.getString("BKACC");
                this.woAcc              = rs.getString("WOACC");			
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
}