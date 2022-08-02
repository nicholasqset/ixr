
package bean.primary;

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
public class PrimarySchool {
    
    public Integer createPrObl(String studentNo, Integer academicYear, String termCode, String docNo, String docDesc, String docType, String entryDate, HttpSession session, HttpServletRequest request){
        Integer oblCreated = 0;
        
        Sys system = new Sys();
        
        if(system.recordExists("PROBL", "STUDENTNO = '"+ studentNo+ "' AND DOCNO = '"+ docNo+ "'")){
            oblCreated = 1;
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId("PROBL", "ID");

                String query = "INSERT INTO PROBL "
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
    
    public Integer createPrObs(String studentNo, Integer academicYear, String termCode, String docNo, String docDesc, String docType, String entryDate, String itemCode, Double amount, HttpSession session, HttpServletRequest request){
        Integer obsCreated = 0;
        
        Sys system = new Sys();
        
        if(! system.recordExists("PROBL", "STUDENTNO = '"+ studentNo+ "' AND DOCNO = '"+ docNo+ "'")){
            this.createPrObl(studentNo, academicYear, termCode, docNo, docDesc, docType, entryDate, session, request);
        }
        
        if(system.recordExists("PROBS", "STUDENTNO = '"+ studentNo+ "' AND DOCNO = '"+ docNo+ "' AND ITEMCODE = '"+ itemCode+ "'")){
            obsCreated = 1;
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId("PROBS", "ID");

                String query = "INSERT INTO PROBS "
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
                e.getMessage();
            }catch (Exception e){
                e.getMessage();
            }
        }
        
        return obsCreated;
    }
    
    public Integer registerSubject(String studentNo, Integer academicYear, String termCode, String subjectCode, HttpSession session, HttpServletRequest request){
        Integer subjectRegistered = 0;
        
        Sys system = new Sys();
        
        if(system.recordExists("PRSTUDSUBJECTS", "STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ academicYear+ " AND TERMCODE = '"+ termCode+ "' AND SUBJECTCODE = '"+ subjectCode+ "' ")){
            subjectRegistered = 1;
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId("PRSTUDSUBJECTS", "ID");

                String query = "INSERT INTO PRSTUDSUBJECTS "
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
    
    public Integer presetExam(String studentNo, Integer academicYear, String termCode, String examCode, String subjectCode, HttpSession session, HttpServletRequest request){
        Integer examPreset = 0;
        
        Sys system = new Sys();
        
        if(system.recordExists("PRSTUDENTMARKS", "STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ academicYear+ " AND TERMCODE = '"+ termCode+ "' AND EXAMCODE = '"+ examCode+ "' AND SUBJECTCODE = '"+ subjectCode+ "' ")){
            examPreset = 1;
        }else{
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId("PRSTUDENTMARKS", "ID");
                
                Double defaultScore = 0.0;
                String defaultGrade = "E";

                String query = "INSERT INTO PRSTUDENTMARKS "
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
                e.getMessage();
            }catch (Exception e){
                e.getMessage();
            }
        }
        
        return examPreset;
    }
    
    public Integer createMkSheetEntry(String studentNo, Integer academicYear, String termCode, String examCode, 
                                   
                                    Double eng, 
                                    String engGrd, 
                                    
                                    Double kis, 
                                    String kisGrd, 
                                    
                                    Double mat, 
                                    String matGrd, 
                                    
                                    Double sci, 
                                    String sciGrd, 
                                    
                                    Double sst, 
                                    String sstGrd, 
                                    
                                    Double total, 
                                    Double studAvg, 
                                    String grade, 
                                    
                                    HttpSession session, HttpServletRequest request){
        Integer subjectInserted = 0;
        
        Sys system = new Sys();
        system.delete("PRMARKSHEET", "STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ academicYear+ " AND TERMCODE = '"+ termCode+ "' AND EXAMCODE = '"+ examCode+ "'");
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();

            Integer id      = system.generateId("PRMARKSHEET", "ID");

            String query = "INSERT INTO PRMARKSHEET "
                    + "("
                    + "ID, STUDENTNO, ACADEMICYEAR, TERMCODE, EXAMCODE, "
                    + "ENG, ENGGRD, KIS, KISGRD, MAT, MATGRD, "
                    + "SCI, SCIGRD, SST, SSTGRD, "
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
                    
                    + sci+ ", "
                    + "'"+ sciGrd+ "', "
                    
                    + sst+ ", "
                    + "'"+ sstGrd+ "', "
                    
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
