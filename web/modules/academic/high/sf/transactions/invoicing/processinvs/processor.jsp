<%@page import="bean.high.HighSchool"%>
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
  <title>Process Invoices Backend</title>
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

//Enumeration params = request.getParameterNames(); 
//
//while(params.hasMoreElements()){
//    String paramName = (String)params.nextElement();
//    out.print("Attribute Name = "+paramName+", Value = "+request.getParameter(paramName)+"<br>");
//}
//    
//String[] ids=request.getParameterValues("checkEach");
//for(int i = 0; i < ids.length; i++){
//    out.print(ids[i]);
//}

final class Process{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String formCode         = request.getParameter("studentForm");
    String[] invNos         = request.getParameterValues("checkEach");
    
    public String init(){
        String html = "";
        
        HttpSession session = request.getSession();
        HighSchool highSchool = new HighSchool();
        
        try{
            Integer recordCount = this.invNos.length;
            
            if(recordCount > 0){
                for(int i = 1; i <= recordCount; i++){
                    
                    if((i - 1) < recordCount){
                        html += "<script type = \"text/javascript\">";
                        html += "comet.showProgress("+ i+ ", "+ recordCount+ ");";
                        html += "</script>" ;
                    }
                    
                    String invNo = this.invNos[(i - 1)];
                    
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "SELECT * FROM "+this.comCode+".VIEWHGINVSDETAILS WHERE INVNO = '"+ invNo+ "' ";

                    ResultSet rs = stmt.executeQuery(query);
                    while(rs.next()){
                        String studentNo        = rs.getString("STUDENTNO");
                        Integer academicYear    = rs.getInt("ACADEMICYEAR");
                        String termCode         = rs.getString("TERMCODE");
                        String invDesc          = rs.getString("INVDESC");
                        String invDate          = rs.getString("INVDATE");
                        String itemCode         = rs.getString("ITEMCODE");
                        Double amount           = rs.getDouble("AMOUNT");
                        
                        Integer obsCreated = highSchool.createHgObs(studentNo, academicYear, termCode, invNo, invDesc, "IN", invDate, itemCode, amount, session, request);
                        
                        if(obsCreated == 1){
                            Statement st = conn.createStatement();
                            st.executeUpdate("UPDATE "+this.comCode+".HGINVSHDR SET PROCESSED = 1 WHERE INVNO = '"+ invNo+ "' ");
                        }
                    }
                    
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