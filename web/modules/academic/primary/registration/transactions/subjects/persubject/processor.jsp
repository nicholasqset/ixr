<%@page import="bean.primary.PrimarySchool"%>
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
  <title>Backend</title>
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
    HttpSession session=request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String classCode        = request.getParameter("studentClass");
    String subjectCode      = request.getParameter("subject");
    String[] studentNos     = request.getParameterValues("checkEach");
    
    public String init(){
        String html = "";
        
        HttpSession session = request.getSession();
        PrimarySchool primarySchool = new PrimarySchool();
        
        try{
            Integer recordCount = this.studentNos.length;
            
            if(recordCount > 0){
                for(int i = 1; i <= recordCount; i++){
                    
                    if((i - 1) < recordCount){
                        html += "<script type = \"text/javascript\">";
                        html += "comet.showProgress("+ i+ ", "+ recordCount+ ");";
                        html += "</script>" ;
                    }
                    
                    String studentNo = this.studentNos[(i - 1)];
                    
                    primarySchool.registerSubject(studentNo, this.academicYear, this.termCode, this.subjectCode, session, request, this.comCode);
                    
                    if(i == recordCount){
                        html += "<script type = \"text/javascript\">";
                        html += "comet.taskComplete();";
                        html += "</script>" ;
                    }

//                    out.flush(); // used to send the echoed data to the client
                    Thread.sleep(7); // a little break to unload the server CPU
                }
            }

        }catch(Exception e){
            html += e.getMessage();
        }
        
        return html;
    }
    
}

Process process = new Process();
out.print(process.init());

    
%>
        
    </body>
</html>