
package bean.high;

import bean.conn.ConnectionProvider;
import bean.sys.Sys;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 *
 * @author nicholas
 */
public class HighSchool {
    
    public Integer createHgObl(String studentNo, Integer academicYear, String termCode, String docNo, String docDesc, String docType, String entryDate, HttpSession session, HttpServletRequest request, String comCode){
        Integer oblCreated = 0;
        
        Sys system = new Sys();
        
        if(system.recordExists(comCode+".HGOBL", "STUDENTNO = '"+ studentNo+ "' AND DOCNO = '"+ docNo+ "'")){
            oblCreated = 1;
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId("HGOBL", "ID");

                String query = "INSERT INTO "+comCode+".HGOBL "
                        + "(ID, STUDENTNO, ACADEMICYEAR, TERMCODE, DOCNO, DOCDESC, DOCTYPE, ENTRYDATE, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ studentNo +"', "
                        + academicYear +", "
                        + "'"+ termCode +"', "
                        + "'"+ docNo +"', "
                        + "'"+ docDesc +"', "
                        + "'"+ docType +"', "
                        + "'"+ system.getLogDate() +"', "
                        + "'"+ system.getLogUser(session) +"', "
                        + "'"+ system.getLogDate() +"', "
                        + "'"+ system.getLogTime() +"', "
                        + "'"+ system.getClientIpAdr(request) +"'"
                        + ")";

                oblCreated = stmt.executeUpdate(query);
                
                
            }catch (SQLException e){

            }catch (Exception e){

            }
        }
        
        return oblCreated;
    }
    
    public Integer createHgObs(String studentNo, Integer academicYear, String termCode, String docNo, String docDesc, String docType, String entryDate, String itemCode, Double amount, HttpSession session, HttpServletRequest request, String comCode){
        Integer obsCreated = 0;
        
        Sys system = new Sys();
        
        if(! system.recordExists(comCode+".HGOBL", "STUDENTNO = '"+ studentNo+ "' AND DOCNO = '"+ docNo+ "'")){
            this.createHgObl(studentNo, academicYear, termCode, docNo, docDesc, docType, entryDate, session, request, comCode);
        }
        
        if(system.recordExists(comCode+".HGOBS", "STUDENTNO = '"+ studentNo+ "' AND DOCNO = '"+ docNo+ "' AND ITEMCODE = '"+ itemCode+ "'")){
            obsCreated = 1;
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId("HGOBS", "ID");

                String query = "INSERT INTO "+comCode+".HGOBS "
                        + "(ID, STUDENTNO, DOCNO, ITEMCODE, AMOUNT, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ studentNo +"', "
                        + "'"+ docNo +"', "
                        + "'"+ itemCode +"', "
                        + amount +", "
                        + "'"+ system.getLogUser(session) +"', "
                        + "'"+ system.getLogDate() +"', "
                        + "'"+ system.getLogTime() +"', "
                        + "'"+ system.getClientIpAdr(request) +"'"
                        + ")";

                obsCreated = stmt.executeUpdate(query);
                
                
            }catch (SQLException e){

            }catch (Exception e){

            }
        }
        
        return obsCreated;
    }
    
    public Integer registerSubject(String studentNo, Integer academicYear, String termCode, String subjectCode, HttpSession session, HttpServletRequest request, String comCode){
        Integer subjectRegistered = 0;
        
        Sys system = new Sys();
        
        if(system.recordExists(""+comCode+".HGSTUDSUBJECTS", "STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ academicYear+ " AND TERMCODE = '"+ termCode+ "' AND SUBJECTCODE = '"+ subjectCode+ "' ")){
            subjectRegistered = 1;
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId(""+comCode+".HGSTUDSUBJECTS", "ID");

                String query = "INSERT INTO "+comCode+".HGSTUDSUBJECTS "
                        + "(ID, STUDENTNO, ACADEMICYEAR, TERMCODE, SUBJECTCODE, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ studentNo +"', "
                        + academicYear +", "
                        + "'"+ termCode +"', "
                        + "'"+ subjectCode +"', "
                        + "'"+ system.getLogUser(session) +"', "
                        + "'"+ system.getLogDate() +"', "
                        + "'"+ system.getLogTime() +"', "
                        + "'"+ system.getClientIpAdr(request) +"'"
                        + ")";

                subjectRegistered = stmt.executeUpdate(query);
                
                
            }catch (SQLException e){

            }catch (Exception e){

            }
        }
        
        return subjectRegistered;
    }
    
    public Integer presetExam(String studentNo, Integer academicYear, String termCode, String examCode, String subjectCode, HttpSession session, HttpServletRequest request, String comCode){
        Integer examPreset = 0;
        
        Sys system = new Sys();
        
        if(system.recordExists(""+comCode+".HGSTUDENTMARKS", "STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ academicYear+ " AND TERMCODE = '"+ termCode+ "' AND EXAMCODE = '"+ examCode+ "' AND SUBJECTCODE = '"+ subjectCode+ "' ")){
            examPreset = 1;
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId(""+comCode+".HGSTUDENTMARKS", "ID");
                
                Double defaultScore = 0.0;
                String defaultGrade = "E";

                String query = "INSERT INTO "+comCode+".HGSTUDENTMARKS "
                        + "(ID, STUDENTNO, ACADEMICYEAR, TERMCODE, "
                        + "EXAMCODE, SUBJECTCODE, SCORE, GRADE, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ studentNo +"', "
                        + academicYear +", "
                        + "'"+ termCode +"', "
                        + "'"+ examCode +"', "
                        + "'"+ subjectCode +"', "
                        + defaultScore +", "
                        + "'"+ defaultGrade +"', "
                        + "'"+ system.getLogUser(session) +"', "
                        + "'"+ system.getLogDate() +"', "
                        + "'"+ system.getLogTime() +"', "
                        + "'"+ system.getClientIpAdr(request) +"'"
                        + ")";

                examPreset = stmt.executeUpdate(query);
                
                
            }catch (SQLException e){

            }catch (Exception e){

            }
        }
        
        return examPreset;
    }
    
    public Integer insertCoreSubject(String studentNo, Integer academicYear, String termCode, String examCode, String subjectCode, HttpSession session, HttpServletRequest request, String comCode){
        Integer subjectInserted = 0;
        
        Sys system = new Sys();
        
        system.delete(""+comCode+".HGSTUDCORESBJS", "STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ academicYear+ " AND TERMCODE = '"+ termCode+ "' AND EXAMCODE = '"+ examCode+ "' AND SUBJECTCODE = '"+ subjectCode+ "' ");
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();

            Integer id      = system.generateId(""+comCode+".HGSTUDCORESBJS", "ID");

            String query = "INSERT INTO "+comCode+".HGSTUDCORESBJS "
                    + "(ID, STUDENTNO, ACADEMICYEAR, TERMCODE, "
                    + "EXAMCODE, SUBJECTCODE, "
                    + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                    + "VALUES"
                    + "("
                    + id+ ", "
                    + "'"+ studentNo +"', "
                    + academicYear +", "
                    + "'"+ termCode +"', "
                    + "'"+ examCode +"', "
                    + "'"+ subjectCode +"', "
                    + "'"+ system.getLogUser(session) +"', "
                    + "'"+ system.getLogDate() +"', "
                    + "'"+ system.getLogTime() +"', "
                    + "'"+ system.getClientIpAdr(request) +"'"
                    + ")";

            subjectInserted = stmt.executeUpdate(query);


        }catch (SQLException e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
        
        return subjectInserted;
    }
    
    public Integer insertElectiveSubject(String studentNo, Integer academicYear, String termCode, String examCode, String subjectCode, HttpSession session, HttpServletRequest request, String comCode){
        Integer subjectInserted = 0;
        
        Sys system = new Sys();
        system.delete(""+comCode+".HGSTUDELECTSBJS", "STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ academicYear+ " AND TERMCODE = '"+ termCode+ "' AND EXAMCODE = '"+ examCode+ "' AND SUBJECTCODE = '"+ subjectCode+ "' ");
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();

            Integer id      = system.generateId(""+comCode+".HGSTUDELECTSBJS", "ID");

            String query = "INSERT INTO "+comCode+".HGSTUDELECTSBJS "
                    + "(ID, STUDENTNO, ACADEMICYEAR, TERMCODE, "
                    + "EXAMCODE, SUBJECTCODE, "
                    + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                    + "VALUES"
                    + "("
                    + id+ ", "
                    + "'"+ studentNo +"', "
                    + academicYear +", "
                    + "'"+ termCode +"', "
                    + "'"+ examCode +"', "
                    + "'"+ subjectCode +"', "
                    + "'"+ system.getLogUser(session) +"', "
                    + "'"+ system.getLogDate() +"', "
                    + "'"+ system.getLogTime() +"', "
                    + "'"+ system.getClientIpAdr(request) +"'"
                    + ")";

            subjectInserted = stmt.executeUpdate(query);


        }catch (SQLException e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
        
        return subjectInserted;
    }
    
    public Integer createMkSheetEntry(String studentNo, Integer academicYear, String termCode, String examCode, 
                                   
                                    Double eng, 
                                    String engGrd, 
                                    
                                    Double kis, 
                                    String kisGrd, 
                                    
                                    Double mat, 
                                    String matGrd, 
                                    
                                    Double bio, 
                                    String bioGrd, 
                                    
                                    Double phy, 
                                    String phyGrd, 
                                    
                                    Double che, 
                                    String cheGrd, 
                                    
                                    Double gsc, 
                                    String gscGrd, 
                                    
                                    Double hig, 
                                    String higGrd, 
                                    
                                    Double geo, 
                                    String geoGrd, 
                                    
                                    Double cre, 
                                    String creGrd, 
                                    
                                    Double ire, 
                                    String ireGrd, 
                                    
                                    Double hre, 
                                    String hreGrd, 
                                    
                                    Double hsc, 
                                    String hscGrd, 
                                    
                                    Double atd, 
                                    String atdGrd, 
                                    
                                    Double agr, 
                                    String agrGrd, 
                                    
                                    Double cst, 
                                    String cstGrd, 
                                    
                                    Double avt, 
                                    String avtGrd, 
                                    
                                    Double frn, 
                                    String frnGrd, 
                                    
                                    Double gmn, 
                                    String gmnGrd, 
                                    
                                    Double arb, 
                                    String arbGrd, 
                                    
                                    Double mus, 
                                    String musGrd, 
                                    
                                    Double bst, 
                                    String bstGrd, 
                                    
                                    Double total, 
                                    Double studAvg, 
                                    String grade, 
                                    
                                    HttpSession session, HttpServletRequest request){
        Integer subjectInserted = 0;
        
        Sys system = new Sys();
        system.delete("HGMARKSHEET", "STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ academicYear+ " AND TERMCODE = '"+ termCode+ "' AND EXAMCODE = '"+ examCode+ "'");
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();

            Integer id      = system.generateId("HGMARKSHEET", "ID");

            String query = "INSERT INTO HGMARKSHEET "
                    + "("
                    + "ID, STUDENTNO, ACADEMICYEAR, TERMCODE, EXAMCODE, "
                    + "ENG, ENGGRD, KIS, KISGRD, MAT, MATGRD, "
                    + "BIO, BIOGRD, PHY, PHYGRD, CHE, CHEGRD, GSC, GSCGRD, "
                    + "HIG, HIGGRD, GEO, GEOGRD, CRE, CREGRD, IRE, IREGRD, HRE, HREGRD, "
                    + "HSC, HSCGRD, ATD, ATDGRD, AGR, AGRGRD, CST, CSTGRD, "
                    + "AVT, AVTGRD, FRN, FRNGRD, GMN, GMNGRD, ARB, ARBGRD, MUS, MUSGRD, BST, BSTGRD, "
                    + "TOTAL, STUDAVG, GRADE, "
                    + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                    + ")"
                    + "VALUES"
                    + "("
                    + id+ ", "
                    + "'"+ studentNo+ "', "
                    + academicYear+ ", "
                    + "'"+ termCode+ "', "
                    + "'"+ examCode+ "', "
                    
                    + eng+ ", "
                    + "'"+ engGrd+ "', "
                    
                    + kis+ ", "
                    + "'"+ kisGrd+ "', "
                    
                    + mat+ ", "
                    + "'"+ matGrd+ "', "
                    
                    + bio+ ", "
                    + "'"+ bioGrd+ "', "
                    
                    + phy+ ", "
                    + "'"+ phyGrd+ "', "
                    
                    + che+ ", "
                    + "'"+ cheGrd+ "', "
                    
                    + gsc +", "
                    + "'"+ gscGrd+ "', "
                    
                    + hig+ ", "
                    + "'"+ higGrd+ "', "
                    
                    + geo+ ", "
                    + "'"+ geoGrd+ "', "
                    
                    + cre+ ", "
                    + "'"+ creGrd+ "', "
                    
                    + ire+ ", "
                    + "'"+ ireGrd+ "', "
                    
                    + hre+ ", "
                    + "'"+ hreGrd+ "', "
                    
                    + hsc+ ", "
                    + "'"+ hscGrd+ "', "
                    
                    + atd+ ", "
                    + "'"+ atdGrd+ "', "
                    
                    + agr+ ", "
                    + "'"+ agrGrd+ "', "
                    
                    + cst+ ", "
                    + "'"+ cstGrd+ "', "
                    
                    + avt+ ", "
                    + "'"+ avtGrd+ "', "
                    
                    + frn+ ", "
                    + "'"+ frnGrd+ "', "
                    
                    + gmn+ ", "
                    + "'"+ gmnGrd+ "', "
                    
                    + arb+ ", "
                    + "'"+ arbGrd+ "', "
                    
                    + mus+ ", "
                    + "'"+ musGrd+ "', "
                    
                    + bst+ ", "
                    + "'"+ bstGrd+ "', "
                    
                    + total+ ", "
                    + studAvg+ ", "
                    + "'"+ grade+ "', "
                    
                    + "'"+ system.getLogUser(session)+ "', "
                    + "'"+ system.getLogDate()+ "', "
                    + "'"+ system.getLogTime()+ "', "
                    + "'"+ system.getClientIpAdr(request)+ "'"
                    + ")";

            subjectInserted = stmt.executeUpdate(query);


        }catch (SQLException e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
        
        return subjectInserted;
    }
    
    
}
