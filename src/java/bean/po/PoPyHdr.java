package bean.po;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class PoPyHdr {
    public String id;
    public String pyNo;
    public String pyDesc;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String supplierNo;
    public String fullName;
    public String supplierName;
    public String poNo;
    public Boolean posted;
    
    public PoPyHdr(String pyNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWPOPYHDR WHERE PYNO = '"+ pyNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.pyNo               = rs.getString("PYNO");			
                this.pyDesc             = rs.getString("PYDESC");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");	
                this.supplierNo         = rs.getString("SUPPLIERNO");
                this.fullName           = rs.getString("FULLNAME");
                this.supplierName       = rs.getString("SUPPLIERNAME");
                this.poNo               = rs.getString("PONO");
                this.posted             = rs.getBoolean("POSTED");
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
    
}