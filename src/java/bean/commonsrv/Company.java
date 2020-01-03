
package bean.commonsrv;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author Nicholas
 */
public class Company {
    
    public String compName;
    public String postalAdr;
    public String postalCode;
    public String physicalAdr;
    public String telephone;
    public String cellphone;
    public String email;
    public String website;
    
    public String pinNo;
    
    public String optFld1;
    public String optFld2;
    public String optFld3;
    public String optFld4;
    public String optFld5;
    
    public Company(String comCode){
        try{
            Connection con = ConnectionProvider.getConnection();
            Statement stmt = con.createStatement();
            String query = "SELECT * FROM sys.coms WHERE comcode = '"+ comCode +"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.compName           = rs.getString("COMPNAME");	
                this.postalAdr          = rs.getString("POSTALADR");			
                this.postalCode         = rs.getString("POSTALCODE");			
                this.physicalAdr        = rs.getString("PHYSICALADR");			
                this.telephone          = rs.getString("TELEPHONE");			
                this.cellphone          = rs.getString("CELLPHONE");			
                this.email              = rs.getString("EMAIL");			
                this.website            = rs.getString("WEBSITE");	
                this.pinNo              = rs.getString("PINNO");
                
                this.optFld1            = rs.getString("OPTFLD1");			
                this.optFld2            = rs.getString("OPTFLD2");			
                this.optFld3            = rs.getString("OPTFLD3");			
                this.optFld4            = rs.getString("OPTFLD4");			
                this.optFld5            = rs.getString("OPTFLD5");			
            }
        
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }catch (Exception  e){
            System.out.println(e.getMessage());
        }
    }
    
    
}
