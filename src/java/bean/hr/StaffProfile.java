package bean.hr;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class StaffProfile{

    public String pfNo;
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
    
    public String brancCode;
    public String brancName;
    public String deptCode;
    public String deptName;
    public String sectionCode;
    public String sectionName;
    public String statusCode;
    public String statusName;
    public String gradeCode;
    public String gradeName;
    public String positionCode;
    public String positionName;
    public String engTrmCode;
    public String engTrmName;
    public String categoryCode;
    public String categoryName;
    
    public String pinNo;
    public String nhifNo;
    public String nssfNo;
    public String medicalNo;
    
    public StaffProfile(String pfNo, String schema){
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;

        try{
            stmt = conn.createStatement();
            String query = "SELECT * FROM "+ schema+ ".VIEWSTAFFPROFILE WHERE PFNO = '"+pfNo+"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.pfNo               = rs.getString("PFNO");			
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
                
                this.brancCode          = rs.getString("BRANCHCODE");			
                this.brancName          = rs.getString("BRANCHNAME");			
                this.deptCode           = rs.getString("DEPTCODE");			
                this.deptName           = rs.getString("DEPTNAME");			
                this.sectionCode        = rs.getString("SECTIONCODE");			
                this.sectionName        = rs.getString("SECTIONNAME");			
                this.statusCode         = rs.getString("STATUSCODE");			
                this.statusName         = rs.getString("STATUSNAME");			
                this.gradeCode          = rs.getString("GRADECODE");			
                this.gradeName          = rs.getString("GRADENAME");			
                this.positionCode       = rs.getString("POSITIONCODE");			
                this.positionName       = rs.getString("POSITIONNAME");			
                this.engTrmCode         = rs.getString("ENGTRMCODE");			
                this.engTrmName         = rs.getString("ENGTRMNAME");			
                this.categoryCode       = rs.getString("CATEGORYCODE");			
                this.categoryName       = rs.getString("CATEGORYNAME");	
                
                this.pinNo              = rs.getString("pinNo");			
                this.nhifNo             = rs.getString("NHIFNO");			
                this.nssfNo             = rs.getString("NSSFNO");			
                this.medicalNo          = rs.getString("MEDICALNO");			
            }
        
        }catch (SQLException  e){
            e.getMessage();
        }

    }

}
