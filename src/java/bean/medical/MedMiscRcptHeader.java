
package bean.medical;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author Nicholas
 */
public class MedMiscRcptHeader {
    public String rcptmNo;
    public Integer pYear;
    public Integer pMonth;
    public String rcptmDate;
    public String pmCode;
    public String pmName;
    public String docNo;
    public Boolean paid;
    public Double amount = 0.0;
    
    public MedMiscRcptHeader(String rcptmNo){
        try{
            bean.sys.Sys system = new bean.sys.Sys();
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM VIEWHMMISCRCPTSHDR WHERE RCPTMNO = '"+rcptmNo+"' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.rcptmNo        = rs.getString("RCPTMNO");			
                this.pYear          = rs.getInt("PYEAR");
                this.pMonth         = rs.getInt("PMONTH");
                this.rcptmDate      = rs.getString("RCPTMDATE");
                this.pmCode         = rs.getString("PMCODE");
                this.pmName         = rs.getString("PMNAME");
                this.docNo          = rs.getString("DOCNO");

//                String amountMiscRcptDtls_   = system.getOne("HMRCPTSMISCDTLS", "SUM(AMOUNT)", "RCPTMNO = '"+ rcptmNo +"'");
                String amountMiscRcptDtls_   = system.getOneAgt("HMRCPTSMISCDTLS", "SUM", "AMOUNT", "SM", "RCPTMNO = '"+ rcptmNo +"'");

                if(amountMiscRcptDtls_ != null){
                    this.amount = Double.parseDouble(amountMiscRcptDtls_);
                }
                
                this.paid               = rs.getBoolean("PAID");

            }
        }catch(Exception e){
            
        }
    }
    
}
