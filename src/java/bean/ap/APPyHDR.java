package bean.ap;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class APPyHDR {
 public Integer batchNo;
    public String batchDesc;
    public String pyNo;
    public String pyDesc;
    public String supplierNo;
    public String fullName;
    public String supplierName;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String pmCode;
    public String refNo;
    public boolean isCheque;
    public String bkBranchCode;
    public String bankCode;
    
    public APPyHDR(String pyNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWAPPYHDR WHERE PYNO = '"+ pyNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.batchNo            = rs.getInt("BATCHNO");			
                this.batchDesc          = rs.getString("BATCHDESC");			
                this.pyNo               = rs.getString("PYNO");			
                this.pyDesc             = rs.getString("PYDESC");			
                this.supplierNo         = rs.getString("SUPPLIERNO");			
                this.fullName           = rs.getString("FULLNAME");			
                this.supplierName       = rs.getString("SUPPLIERNAME");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");			
                this.pmCode             = rs.getString("PMCODE");			
                this.refNo              = rs.getString("REFNO");			
                this.isCheque           = rs.getBoolean("ISCHEQUE");			
                this.bkBranchCode       = rs.getString("BKBRANCHCODE");			
                this.bankCode           = rs.getString("BANKCODE");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
    
}
