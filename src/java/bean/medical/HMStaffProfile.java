package bean.medical;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class HMStaffProfile{

    public String staffNo;
    public String salutationCode;
    public String salutationName;
    public String firstName;
    public String middleName;
    public String lastName;
    public String fullName;
    public String genderCode;
    public String genderName;
    public String dob;
    public String countryCode;
    public String countryName;
    public String nationalId;
    public String passportNo;
    public Integer physChald;
    public String disabCode;
    public String disabName;
    public String postalAddr;
    public String postalCode;
    public String physicalAddr;
    public String telephone;
    public String cellphone;
    public String email;
    
    public String staffTypeCode;
    public String staffTypeName;
    public String deptCode;
    public String deptName;
    public String cmnt;


    public HMStaffProfile(String staffNo, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWHMSTAFFPROFILE WHERE STAFFNO = '"+staffNo+"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.staffNo            = rs.getString("STAFFNO");			
                this.salutationCode     = rs.getString("SALUTATIONCODE");			
                this.salutationName     = rs.getString("SALUTATIONNAME");			
                this.firstName          = rs.getString("FIRSTNAME");			
                this.middleName         = rs.getString("MIDDLENAME");			
                this.lastName           = rs.getString("LASTNAME");			
                this.fullName           = rs.getString("FULLNAME");			
                this.genderCode         = rs.getString("GENDERCODE");			
                this.genderName         = rs.getString("GENDERNAME");			
                this.dob                = rs.getString("DOB");			
                this.countryCode        = rs.getString("COUNTRYCODE");			
                this.countryName        = rs.getString("COUNTRYNAME");			
                this.nationalId         = rs.getString("NATIONALID");			
                this.passportNo         = rs.getString("PASSPORTNO");			
                this.physChald          = rs.getInt("PHYSCHALD");			
                this.disabCode          = rs.getString("DISABCODE");			
                this.disabName          = rs.getString("DISABNAME");			
                this.postalAddr         = rs.getString("POSTALADDR");			
                this.postalCode         = rs.getString("POSTALCODE");			
                this.physicalAddr       = rs.getString("PHYSICALADDR");			
                this.telephone          = rs.getString("TELEPHONE");			
                this.cellphone          = rs.getString("CELLPHONE");			
                this.email              = rs.getString("EMAIL");
                
                this.staffTypeCode      = rs.getString("STAFFTYPECODE");			
                this.staffTypeName      = rs.getString("STAFFTYPENAME");			
                this.deptCode           = rs.getString("DEPTCODE");			
                this.deptName           = rs.getString("DEPTNAME");			
                this.cmnt               = rs.getString("CMNT");			
            }
        
        }catch (SQLException  e){

        }

    }

}
