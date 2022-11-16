package bean.restaurant;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class RtPyHdr {
    public Integer id;
    public String pyNo;
    public String pyDesc;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String customerNo;
    public String fullName;
    public String tillNo;
    public String tableNo;
    public String pmCode;
    public String docNo;
    public Double bill;
    public Double tender;
    public Double change;
    public Boolean cleared;
    public Boolean posted;
    public String auditUser;
    public String userName;
    
    public RtPyHdr(String pyNo, String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+comCode+".VIEWRTPYHDR WHERE PYNO = '"+ pyNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id                 = rs.getInt("ID");
                this.pyNo               = rs.getString("PYNO");			
                this.pyDesc             = rs.getString("PYDESC");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");	
                this.customerNo         = rs.getString("CUSTOMERNO");
                this.fullName           = rs.getString("FULLNAME");
                this.tillNo             = rs.getString("TILLNO");
                this.tableNo            = rs.getString("TABLENO");
                this.pmCode             = rs.getString("PMCODE");
                this.docNo              = rs.getString("DOCNO");
                this.bill               = rs.getDouble("BILL");
                this.tender             = rs.getDouble("TENDER");
                this.change             = rs.getDouble("CHANGE");
                this.cleared            = rs.getBoolean("CLEARED");
                this.posted             = rs.getBoolean("POSTED");
                this.auditUser          = rs.getString("AUDITUSER");
                this.userName           = rs.getString("USERNAME");
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
    
}