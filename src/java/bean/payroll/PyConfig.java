
package bean.payroll;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class PyConfig {
    public String bp;
    public String hs;
    public String cm;
    public String cr;
    public String gp;
    public String np;
    public String lv;
    public String cb;
    public String cp;
    public String tx;
    public String pr;
    public String ir;
    public String mb;
    public String mc;
    public String pe;
    
    public PyConfig(String schema){
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ schema+".PYCONFIG ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.bp     = rs.getString("BP");		
                this.hs     = rs.getString("HS");		
                this.cm     = rs.getString("CM");		
                this.cr     = rs.getString("CR");		
                this.gp     = rs.getString("GP");		
                this.np     = rs.getString("NP");	
                this.lv     = rs.getString("LV");		
                this.cb     = rs.getString("CB");		
                this.cp     = rs.getString("CP");		
                this.tx     = rs.getString("TX");		
                this.pr     = rs.getString("PR");		
                this.ir     = rs.getString("IR");		
                this.mb     = rs.getString("MB");		
                this.mc     = rs.getString("MC");		
                this.pe     = rs.getString("PE");
            }
        }catch(Exception e){
            e.getMessage();
        }
        
    }
    
}
