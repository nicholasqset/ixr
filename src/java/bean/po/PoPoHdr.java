package bean.po;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class PoPoHdr {
   
    public String id;
    public String poNo;
    public String poDesc;
    public String entryDate;
    public Integer pYear;
    public Integer pMonth;
    public String supplierNo;
    public String fullName;
    
    public PoPoHdr(String poNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWPOPOHDR WHERE PONO = '"+ poNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.poNo               = rs.getString("PONO");			
                this.poDesc             = rs.getString("PODESC");			
                this.entryDate          = rs.getString("ENTRYDATE");			
                this.pYear              = rs.getInt("PYEAR");			
                this.pMonth             = rs.getInt("PMONTH");	
                this.supplierNo         = rs.getString("SUPPLIERNO");
                this.fullName           = rs.getString("FULLNAME");
            }
        }catch (Exception e){
            e.getMessage();
        }
    }
    
}