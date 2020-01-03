<%@page import="bean.primary.PrimarySchool"%>
<%@page import="bean.academic.Academic"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="bean.sys.Sys"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
  <title>Process Marks Backend</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>

<script type="text/javascript">
  // KHTML browser don't share javascripts between iframes
  var is_khtml = navigator.appName.match("Konqueror") || navigator.appVersion.match("KHTML");
  if (is_khtml)
  {
    var prototypejs = document.createElement('script');
    prototypejs.setAttribute('type','text/javascript');
    prototypejs.setAttribute('src','<%=request.getContextPath()+"/js/scriptaculous/lib/prototype.js" %>');
    var head = document.getElementsByTagName('head');
    head[0].appendChild(prototypejs);
  }
  // load the comet object
  var comet = window.parent.comet;
</script>
<%

final class Process{
    
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String examCode         = request.getParameter("exam");
    
    public String populateMkSheet(){
        String html = "";
        HttpSession session = request.getSession();
        Sys sys = new Sys();
        PrimarySchool primarySchool = new PrimarySchool();
        
        Academic academic = new Academic();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT STUDENTNO, ACADEMICYEAR, TERMCODE, EXAMCODE, SUM(SCORE)TOTAL "
                    + "FROM VIEWPRSTUDENTMARKS "
                    + "WHERE "
                    + "ACADEMICYEAR = "+ this.academicYear+ " AND "
                    + "TERMCODE     = '"+ this.termCode+ "' AND "
                    + "EXAMCODE     = '"+ this.examCode+ "' "
                    + "GROUP BY STUDENTNO, ACADEMICYEAR, TERMCODE, EXAMCODE "
                    + "ORDER BY TOTAL DESC, STUDENTNO";
            
            html += query;
            html += "<hr>";
            ResultSet rs = stmt.executeQuery(query);

            while(rs.next()){
                
                String studentNo    = rs.getString("STUDENTNO");
                Double total        = rs.getDouble("TOTAL");
                
                Double studAvg = total / 5;
                String grade = academic.getGrade((double)Math.round(studAvg));
                
                String engStr = system.getOne("PRSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ENG' ");
                String engSbj = system.getOne("PRSTUDENTMARKS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ENG' ");
                String engAst = (engStr != null && engSbj == null)? "*": "";
                engStr = engStr != null? engStr: "0";
                Double eng  = Double.parseDouble(engStr);
                String engGrd = system.getOne("PRSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ENG' ");
                engGrd = (engGrd != null && ! engGrd.trim().equals(""))? engGrd+ engAst: "na";
                
                String kisStr = system.getOne("PRSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'KIS' ");
                String kisSbj = system.getOne("PRSTUDENTMARKS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'KIS' ");
                String kisAst = (kisStr != null && kisSbj == null)? "*": "";
                kisStr = kisStr != null? kisStr: "0";
                Double kis  = Double.parseDouble(kisStr);
                String kisGrd = system.getOne("PRSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'KIS' ");
                kisGrd = (kisGrd != null && ! kisGrd.trim().equals(""))? kisGrd+ kisAst: "na";
                
                String matStr = system.getOne("PRSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'MAT' ");
                String matSbj = system.getOne("PRSTUDENTMARKS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'MAT' ");
                String matAst = (matStr != null && matSbj == null)? "*": "";
                matStr = matStr != null? matStr: "0";
                Double mat  = Double.parseDouble(matStr);
                String matGrd = system.getOne("PRSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'MAT' ");
                matGrd = (matGrd != null && ! matGrd.trim().equals(""))? matGrd+ matAst: "na";
                
                String sciStr = system.getOne("PRSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'SCI' ");
                String sciSbj = system.getOne("PRSTUDENTMARKS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'SCI' ");
                String sciAst = (sciStr != null && sciSbj == null)? "*": "";
                sciStr = sciStr != null? sciStr: "0";
                Double sci  = Double.parseDouble(sciStr);
                String sciGrd = system.getOne("PRSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'SCI' ");
                sciGrd = (sciGrd != null && ! sciGrd.trim().equals(""))? sciGrd+ sciAst: "na";

                String sstStr = system.getOne("PRSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'SST' ");
                String sstSbj = system.getOne("PRSTUDENTMARKS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'SST' ");
                String sstAst = (sstStr != null && sstSbj == null)? "*": "";
                sstStr = sstStr != null? sstStr: "0";
                Double sst  = Double.parseDouble(sstStr);
                String sstGrd = system.getOne("PRSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'SST' ");
                sstGrd = (sstGrd != null && ! sstGrd.trim().equals(""))? sstGrd+ sstAst: "na";
                
                primarySchool.createMkSheetEntry(studentNo, this.academicYear, this.termCode, this.examCode, eng, engGrd, kis, kisGrd, mat, matGrd, sci, sciGrd, sst, sstGrd, total, studAvg, grade, session, request);

            }
            
        }catch (SQLException e){
            html += e.getMessage();
        }catch (Exception e){
            html += e.getMessage();
        }
        
        return html;
    }
    
    
}

Process process = new Process();

for(int i = 1; i <= 1; i++){
    
    if(i == 1){
        out.print(process.populateMkSheet());
    }
    
    if((i - 1) < 1){
        out.print("<script type = \"text/javascript\">");
        out.print("comet.showProgress("+ i +", "+ 1 +");");
        out.print("</script>") ;
    }

    if(i == 1){
        out.print("<script type = \"text/javascript\">");
        out.print("comet.taskComplete();");
        out.print("</script>") ;
    }
    
    out.flush(); // used to send the echoed data to the client
    Thread.sleep(7); // a little break to unload the server CPU
}

    
%>
        
    </body>
</html>