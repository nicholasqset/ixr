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
public class ARInHdr {
    public Integer batchNo;
    public String batchDesc;
    public Boolean rtp;
    public String inNo;
    public String inDesc;
    public String customerNo;
    public String customerName;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String poNo;
    public String orderNo;
    public boolean applied;
    
    public ARInHdr(String inNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWARINHDR WHERE INNO = '"+ inNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.batchNo            = rs.getInt("BATCHNO");			
                this.batchDesc          = rs.getString("BATCHDESC");			
                this.rtp                = rs.getBoolean("RTP");			
                this.inNo               = rs.getString("INNO");			
                this.inDesc             = rs.getString("INDESC");			
                this.customerNo         = rs.getString("CUSTOMERNO");			
                this.customerName       = rs.getString("CUSTOMERNAME");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");			
                this.poNo               = rs.getString("PONO");			
                this.orderNo            = rs.getString("ORDERNO");			
                this.applied            = rs.getBoolean("APPLIED");			
            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
    }
    
}
