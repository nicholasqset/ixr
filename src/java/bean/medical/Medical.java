
package bean.medical;

import bean.conn.ConnectionProvider;
import bean.finance.FinConfig;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import bean.sys.Sys;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class Medical {
    String schema;
    
    public Medical(String schema){
        this.schema = schema;
    }
    
    public Integer createInvHdr(String regNo, String invType, HttpSession session, HttpServletRequest request){
        Integer createInvHdr = 0;
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            Sys sys = new Sys();
            
            Integer id      = sys.generateId("HMINVSHDR", "ID");
            String invNo    = sys.getNextNo("HMINVSHDR", "ID", "", "INV", 7);
            
            String query = "INSERT INTO HMINVSHDR "
                    + "(ID, REGNO, INVTYPE, INVNO, INVDATE, "
                    + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                    + "VALUES"
                    + "("
                    + id+", "
                    + "'"+ regNo +"', "
                    + "'"+ invType +"', "
                    + "'"+ invNo +"', "
                    + "'"+ sys.getLogDate() +"', "
                    + "'"+ sys.getLogUser(session) +"', "
                    + "'"+ sys.getLogDate() +"', "
                    + "'"+ sys.getLogTime() +"', "
                    + "'"+ sys.getClientIpAdr(request) +"'"
                    + ")";
            
            stmt.executeUpdate(query);
        }catch(SQLException e){
            System.out.print(e.getMessage());
        }
        
        return createInvHdr;
    }
    
    public Integer createInvDtls(String regNo, String invType, String itemCode, Double qty, HttpSession session, HttpServletRequest request){
        Integer createInvDtls = 0;
        Sys sys = new Sys();
        
        MedRegistration medRegistration = new MedRegistration(regNo);
        
        if(! sys.recordExists(this.schema+".HMINVSHDR", "REGNO = '"+ regNo +"' AND INVTYPE = '"+ invType +"'")){
            this.createInvHdr(regNo, invType, session, request);
        }
        
        String invNo = sys.getOne(this.schema+".HMINVSHDR", "INVNO", "REGNO = '"+ regNo +"' AND INVTYPE = '"+ invType +"'");
        
        MedInvHeader medInvHeader = new MedInvHeader(invNo);
        
        MedicalItem medicalItem = new MedicalItem(itemCode);
        Double vatRate = 0.00;
        
        if(medicalItem.vatable){
            FinConfig finConfig = new FinConfig(schema);
            vatRate = finConfig.vatRate / 100;
        }
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            Integer id = sys.generateId("HMINVSDTLS", "ID");
            
            Double rate = this.getItemRate(medRegistration.pYear, medRegistration.pMonth, itemCode);
            Double amount = qty * rate;
            
            Double vatAmount = vatRate * amount;
            Double netAmount = amount - vatAmount;
            
            String query = "INSERT INTO "+this.schema+".HMINVSDTLS "
                    + "(ID, INVNO, ITEMCODE, QTY, RATE, VATRATE, VATAMOUNT, NETAMOUNT, AMOUNT, "
                    + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                    + "VALUES"
                    + "("
                    + id +", "
                    + "'"+ medInvHeader.invNo +"', "
                    + "'"+ itemCode +"', "
                    + qty +", "
                    + rate +", "
                    + vatRate +", "
                    + vatAmount +", "
                    + netAmount +", "
                    + amount +", "
                    + "'"+ sys.getLogUser(session) +"', "
                    + "'"+ sys.getLogDate() +"', "
                    + "'"+ sys.getLogTime() +"', "
                    + "'"+ sys.getClientIpAdr(request) +"'"
                    + ")";

            createInvDtls = stmt.executeUpdate(query);
            
        }catch (SQLException e){
            System.out.print(e.getMessage());
        }
        
        return createInvDtls;
    }
    
    public Double getItemRate(Integer pYear, Integer pMonth, String itemCode){
        Double rate = 0.00;
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM VIEWHMITEMCHARGES WHERE PYEAR = "+ pYear +" AND PMONTH = "+ pMonth +" AND ITEMCODE = '"+ itemCode +"'";
            ResultSet rs = stmt.executeQuery(query);

            while(rs.next()){
                rate = rs.getDouble("AMOUNT");
            }
            
        }catch(SQLException e){
            System.out.print(e.getMessage());
        }
        
        return rate;
    }
    
    public Integer createBalanceItem(String itemCode, Double qty, HttpSession session, HttpServletRequest request){
        Integer createBalanceItem = 0;
        Sys sys = new Sys();
        
        Integer pYear   = sys.getPeriodYear(this.schema);
        Integer pMonth  = sys.getPeriodMonth(this.schema);
        
        if(! sys.recordExists("HMINVENTBAL", "PYEAR = "+ pYear +" AND PMONTH = "+ pMonth +" AND ITEMCODE = '"+ itemCode +"'")){
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt  = conn.createStatement();
                
                Integer id = sys.generateId("HMINVENTBAL", "ID");

                String query = "INSERT INTO HMINVENTBAL "
                        + "(ID, PYEAR, PMONTH, ITEMCODE, OBAL, BAL, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id +", "
                        + pYear+ ", "
                        + pMonth+ ", "
                        + "'"+ itemCode +"', "
                        + 0 +", "
                        + qty +", "
                        + "'"+ sys.getLogUser(session) +"', "
                        + "'"+ sys.getLogDate() +"', "
                        + "'"+ sys.getLogTime() +"', "
                        + "'"+ sys.getClientIpAdr(request) +"'"
                        + ")";

                createBalanceItem = stmt.executeUpdate(query);
            
            }catch(SQLException e){
                System.out.print(e.getMessage());
            }
        }
        
        return createBalanceItem;
    }
    
    public Integer addItemBalance(String itemCode, Double qty, HttpSession session, HttpServletRequest request){
        Integer addItemBalance = 0;
        
        Sys sys = new Sys();
        
        Integer pYear   = sys.getPeriodYear(this.schema);
        Integer pMonth  = sys.getPeriodMonth(this.schema);
        
        if(! sys.recordExists("HMINVENTBAL", "PYEAR = "+ pYear +" AND PMONTH = "+ pMonth +" AND ITEMCODE = '"+ itemCode +"'")){
            this.createBalanceItem(itemCode, qty, session, request);
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt  = conn.createStatement();
                
                String balStr = sys.getOne("HMINVENTBAL", "BAL", "PYEAR = "+ pYear +" AND PMONTH = "+ pMonth +" AND ITEMCODE = '"+ itemCode +"'");
                balStr = (balStr != null && ! balStr.trim().equals(""))? balStr: "0";
                Double qtyOld = Double.parseDouble(balStr);
                Double qtyNew = qtyOld + qty;
                String query = "UPDATE HMINVENTBAL SET "
                        + "BAL              = "+ qtyNew +", "
                        + "AUDITUSER        = '"+ sys.getLogUser(session) +"', "
                        + "AUDITDATE        = '"+ sys.getLogDate() +"', "
                        + "AUDITTIME        = '"+ sys.getLogTime() +"', "
                        + "AUDITIPADR       = '"+ sys.getClientIpAdr(request) +"' "

                        + "WHERE PYEAR = "+ pYear +" AND PMONTH = "+ pMonth +" AND ITEMCODE = '"+ itemCode +"'";

                addItemBalance = stmt.executeUpdate(query);
            
            }catch(NumberFormatException | SQLException e){
                System.out.print(e.getMessage());
            }
        }
        
        return addItemBalance;
    }
    
     public Integer reduceItemBalance(String itemCode, Double qty, HttpSession session, HttpServletRequest request){
        Integer reduceItemBalance = 0;
        
        Sys sys = new Sys();
        
        Integer pYear   = sys.getPeriodYear(this.schema);
        Integer pMonth  = sys.getPeriodMonth(this.schema);
        
        if(sys.recordExists("HMINVENTBAL", "PYEAR = "+ pYear +" AND PMONTH = "+ pMonth +" AND ITEMCODE = '"+ itemCode +"'")){
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt  = conn.createStatement();
                
                String balStr = sys.getOne("HMINVENTBAL", "BAL", "PYEAR = "+ pYear +" AND PMONTH = "+ pMonth +" AND ITEMCODE = '"+ itemCode +"'");
                balStr = (balStr != null && ! balStr.trim().equals(""))? balStr: "0";

                Double qtyOld = Double.parseDouble(balStr);
                Double qtyNew = qtyOld - qty;
                qtyNew = qtyNew < 0? 0: qtyNew;
                
                String query = "UPDATE HMINVENTBAL SET "
                        + "BAL              = "+ qtyNew +", "
                        + "AUDITUSER        = '"+ sys.getLogUser(session) +"', "
                        + "AUDITDATE        = '"+ sys.getLogDate() +"', "
                        + "AUDITTIME        = '"+ sys.getLogTime() +"', "
                        + "AUDITIPADR       = '"+ sys.getClientIpAdr(request) +"' "

                        + "WHERE PYEAR = "+ pYear +" AND PMONTH = "+ pMonth +" AND ITEMCODE = '"+ itemCode +"'";

                reduceItemBalance = stmt.executeUpdate(query);
                
            }catch(NumberFormatException | SQLException e){
                System.out.print(e.getMessage());
            }
        }
        
        return reduceItemBalance;
    }
    
}
