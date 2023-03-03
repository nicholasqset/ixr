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
public class PatientProfile{

    public String ptNo;
    public String salutationCode;
    public String salutationName;
    public String firstName;
    public String middleName;
    public String lastName;
    public String fullName;
    public String genderCode;
    public String genderName;
    public String dob;
    public String age;
    public String countryCode;
    public String countryName;
    public String nationalId;
    public String passportNo;
    public String bloodGrpCode;
    public String bloodGrpName;
    public Integer physChald;
    public String disabCode;
    public String disabName;
    public String postalAddr;
    public String postalCode;
    public String physicalAddr;
    public String telephone;
    public String cellphone;
    public String email;
    public String allergies;
    public String warns;
    public String familyHist;
    public String selfHist;
    public String pastMedHist;
    public String socialHist;
    
    public String nhifNo;
    
    public String nok_fullname;
    public String nok_relation;
    public String nok_phone_no;
    public String nok_email;


    public PatientProfile(String ptNo, String schema){
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;

        try{
            stmt = conn.createStatement();
            String query = "SELECT * FROM "+schema+".VIEWPATIENTPROFILE WHERE PTNO = '"+ptNo+"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.ptNo               = rs.getString("PTNO");			
                this.salutationCode     = rs.getString("SALUTATIONCODE");			
                this.salutationName     = rs.getString("SALUTATIONNAME");			
                this.firstName          = rs.getString("FIRSTNAME");			
                this.middleName         = rs.getString("MIDDLENAME");			
                this.lastName           = rs.getString("LASTNAME");			
                this.fullName           = rs.getString("FULLNAME");			
                this.genderCode         = rs.getString("GENDERCODE");			
                this.genderName         = rs.getString("GENDERNAME");			
                this.dob                = rs.getString("DOB");			
                this.age                = rs.getString("AGE");			
                this.countryCode        = rs.getString("COUNTRYCODE");			
                this.countryName        = rs.getString("COUNTRYNAME");			
                this.nationalId         = rs.getString("NATIONALID");			
                this.passportNo         = rs.getString("PASSPORTNO");			
                this.bloodGrpCode       = rs.getString("BLOODGRPCODE");			
                this.bloodGrpName       = rs.getString("BLOODGRPNAME");			
                this.physChald          = rs.getInt("PHYSCHALD");			
                this.disabCode          = rs.getString("DISABCODE");			
                this.disabName          = rs.getString("DISABNAME");			
                this.postalAddr         = rs.getString("POSTALADDR");			
                this.postalCode         = rs.getString("POSTALCODE");			
                this.physicalAddr       = rs.getString("PHYSICALADDR");			
                this.telephone          = rs.getString("TELEPHONE");			
                this.cellphone          = rs.getString("CELLPHONE");			
                this.email              = rs.getString("EMAIL");
                this.allergies          = rs.getString("ALLERGIES");			
                this.warns              = rs.getString("WARNS");			
                this.familyHist         = rs.getString("FAMILYHIST");			
                this.selfHist           = rs.getString("SELFHIST");			
                this.pastMedHist        = rs.getString("PASTMEDHIST");			
                this.socialHist         = rs.getString("SOCIALHIST");	
                
                this.nhifNo             = rs.getString("NHIFNO");	
                
                this.nok_fullname       = rs.getString("nok_fullname");			
                this.nok_relation       = rs.getString("nok_relation");			
                this.nok_phone_no       = rs.getString("nok_phone_no");			
                this.nok_email          = rs.getString("nok_email");			
            }
        
        }catch (SQLException  e){

        }

    }

}
