
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
public class ARCustomerProfile {
    public String id;
    public String customerNo;
    public String firstName;
    public String middleName;
    public String lastName;
    public String fullName;
    public String customerName;
    public String genderCode;
    public String genderName;
    public String dob;
    public String countryCode;
    public String countryName;
    public String nationalId;
    public String passportNo;
    public String postalAdr;
    public String postalCode;
    public String physicalAdr;
    public String telephone;
    public String cellphone;
    public String email;
    public String cusGrpCode;
    public String cusGrpName;
   
    
    public ARCustomerProfile(String customerNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWARCUSTOMERS WHERE CUSTOMERNO = '"+ customerNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id                 = rs.getString("ID");			
                this.customerNo         = rs.getString("CUSTOMERNO");			
                this.firstName          = rs.getString("FIRSTNAME");			
                this.middleName         = rs.getString("MIDDLENAME");			
                this.lastName           = rs.getString("LASTNAME");			
                this.fullName           = rs.getString("FULLNAME");			
                this.customerName       = rs.getString("CUSTOMERNAME");			
                this.genderCode         = rs.getString("GENDERCODE");			
                this.genderName         = rs.getString("GENDERNAME");			
                this.dob                = rs.getString("DOB");			
                this.countryCode        = rs.getString("COUNTRYCODE");			
                this.countryName        = rs.getString("COUNTRYNAME");			
                this.nationalId         = rs.getString("NATIONALID");			
                this.passportNo         = rs.getString("PASSPORTNO");			
                this.postalAdr          = rs.getString("POSTALADR");			
                this.postalCode         = rs.getString("POSTALCODE");			
                this.physicalAdr        = rs.getString("PHYSICALADR");			
                this.telephone          = rs.getString("TELEPHONE");			
                this.cellphone          = rs.getString("CELLPHONE");			
                this.email              = rs.getString("EMAIL");
                this.cusGrpCode         = rs.getString("CUSGRPCODE");
                this.cusGrpName         = rs.getString("CUSGRPNAME");
                
            }
        }catch (SQLException  e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
    }
    
    
}
