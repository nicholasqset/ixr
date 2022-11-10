
package bean.high;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class HGStudentProfile {
    public String id;
    public String studentNo;
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
    public String postalAdr;
    public String postalCode;
    public String physicalAdr;
    public String telephone;
    public String cellphone;
    public String email;
    public String admGrp;
    public String streamCode;
    public String streamName;
    public String formCode;
    public String formName;
    public String studPrdCode;
    public String studPrdName;
    public String studTypeCode;
    public String studTypeName;
    public String statusCode;
    public String statusName;
    
    public HGStudentProfile(String studentNo, String comCode){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+comCode+".VIEWHGSTUDENTPROFILE WHERE STUDENTNO = '"+studentNo+"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.id                 = rs.getString("ID");			
                this.studentNo          = rs.getString("STUDENTNO");			
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
                this.postalAdr          = rs.getString("POSTALADR");			
                this.postalCode         = rs.getString("POSTALCODE");			
                this.physicalAdr        = rs.getString("PHYSICALADR");			
                this.telephone          = rs.getString("TELEPHONE");			
                this.cellphone          = rs.getString("CELLPHONE");			
                this.email              = rs.getString("EMAIL");
                this.admGrp             = rs.getString("ADMGRP");
                this.streamCode         = rs.getString("STREAMCODE");
                this.streamName         = rs.getString("STREAMNAME");
                this.formCode           = rs.getString("FORMCODE");
                this.formName           = rs.getString("FORMNAME");
                this.studPrdCode        = rs.getString("STUDPRDCODE");
                this.studPrdName        = rs.getString("STUDPRDNAME");
                this.studTypeCode       = rs.getString("STUDTYPECODE");
                this.studTypeName       = rs.getString("STUDTYPENAME");
                this.statusCode         = rs.getString("STATUSCODE");
                this.statusName         = rs.getString("STATUSNAME");
            }
        }catch (SQLException  e){

        }catch (Exception e){
            
        }
    }
    
    public Double getFeesBalance(){
        Double feesBalance;
        
        bean.sys.Sys system = new bean.sys.Sys();
        
        String dr = system.getOne("VIEWHGOBS", "SUM(AMOUNT)", "STUDENTNO = '"+ this.studentNo+ "' AND (DOCTYPE = 'IN' OR DOCTYPE = 'DN')");
        if(dr == null){
            dr = "0";
        }
        
        Double drAmount = Double.parseDouble(dr);
        
        String cr = system.getOne("VIEWHGOBS", "SUM(AMOUNT)", "STUDENTNO = '"+ this.studentNo+ "' AND (DOCTYPE = 'RC' OR DOCTYPE = 'CN')");
        if(cr == null){
            cr = "0";
        }
        
        Double crAmount = Double.parseDouble(cr);
        
        feesBalance = drAmount - crAmount;
        
        return feesBalance;
    }
    
    
    
}
