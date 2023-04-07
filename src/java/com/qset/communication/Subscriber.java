package com.qset.communication;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class Subscriber {
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
    public String postalAdr;
    public String postalCode;
    public String physicalAdr;
    public String phoneNo;
    public String email;
    
    public Subscriber(String subscriberId, String schema){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT S.*, T.salutationname, G.gendername, C.countryname FROM "+schema+".cm_subscribers S "
                    + "LEFT JOIN "+schema+".cssalutation T ON T.salutationcode = S.salutation_code "
                    + "LEFT JOIN "+schema+".csgender G ON G.gendercode = S.gender_code "
                    + "LEFT JOIN "+schema+".cscountries C ON C.countrycode = S.country_code "
                    + "WHERE S.id = "+subscriberId+" ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.salutationCode     = rs.getString("SALUTATION_CODE");			
                this.salutationName     = rs.getString("SALUTATIONNAME");			
                this.firstName          = rs.getString("FIRST_NAME");			
                this.middleName         = rs.getString("MIDDLE_NAME");			
                this.lastName           = rs.getString("LAST_NAME");			
                this.fullName           = this.firstName+" "+this.middleName+ ""+ this.lastName;			
                this.genderCode         = rs.getString("GENDER_CODE");			
                this.genderName         = rs.getString("GENDERNAME");			
                this.dob                = rs.getString("DOB");			
                this.countryCode        = rs.getString("COUNTRY_CODE");			
                this.countryName        = rs.getString("COUNTRYNAME");			
                this.nationalId         = rs.getString("NATIONAL_ID");			
                this.passportNo         = rs.getString("PASSPORT_NO");			
                this.postalAdr         = rs.getString("POSTAL_ADR");			
                this.postalCode         = rs.getString("POSTAL_CODE");			
                this.physicalAdr       = rs.getString("PHYSICAL_ADR");			
                this.phoneNo          = rs.getString("phone_no");			
                this.email              = rs.getString("EMAIL");
                
            }
        
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        }

    }
    
}
