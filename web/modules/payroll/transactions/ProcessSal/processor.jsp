<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="javax.script.ScriptEngine"%>
<%@page import="javax.script.ScriptEngineManager"%>
<%@page import="javax.script.ScriptException"%>
<%@page import="com.qset.payroll.Payroll"%>
 
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
  <title>Process Salary Backend</title>
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
    HttpSession session = request.getSession();
    
    String schema = session.getAttribute("comCode").toString();
    
    Integer pYear       = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth      = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
     
    public String init(){
        String html = "";
        
        Payroll payroll = new Payroll(schema);
        
        try{
            Integer recordCount = this.getStaffCount();
            
            if(recordCount > 0){
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
//                String query = "SELECT DISTINCT PFNO FROM PYSTAFFITEMS WHERE PFNO = '1212' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " ";
                String query = "SELECT DISTINCT PFNO FROM "+ schema+ ".PYSTAFFITEMS WHERE PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " ";
                
                ResultSet rs = stmt.executeQuery(query);
                
                Integer i = 1;
                while(rs.next()){
                    if((i - 1) < recordCount){
                        html += "<script type = \"text/javascript\">";
                        html += "comet.showProgress("+ i+ ", "+ recordCount+ ");";
                        html += "</script>" ;
                    }
                    
                    String pfNo         = rs.getString("PFNO");
                    
                    html += payroll.process(pfNo, this.pYear, this.pMonth);
                    
                    if(i == recordCount){
                        html += "<script type = \"text/javascript\">";
                        html += "comet.taskComplete();";
                        html += "</script>" ;
                    }

//                    out.flush(); // used to send the echoed data to the client
                    Thread.sleep(7); // a little break to unload the server CPU
                    
                    i++;
                }
                
            }else{
                html += "<script type = \"text/javascript\">";
                html += "alert('No Record found');";
                html += "comet.taskComplete();";
                html += "</script>" ;
            }

        }catch(Exception e){
            html += e.getMessage();
        }
        
        return html;
    }
    
    public Integer getStaffCount(){
        Integer staffCount = 0;
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            String query;
            
            query = "SELECT COUNT(DISTINCT PFNO)DCT FROM "+ schema+ ".PYSTAFFITEMS WHERE PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth;
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                staffCount = rs.getInt("DCT");		
            }
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
             e.getMessage();
        }
        
        return staffCount;
    }
  
    
}
 
// Process process = new Process();
// out.print(process.init());

//Integer pYear       = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
//Integer pMonth      = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
     
//ArrayList<String> StaffList = new ArrayList();
 
Process process = new Process();

out.print ("working year " + process.pYear + " " + process.pMonth + " <hr> ");

    
String schema = session.getAttribute("comCode").toString();
Payroll payroll = new Payroll(schema);

try{
    
    Integer recordCount = process.getStaffCount();
    
    if(recordCount > 0){

        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = conn.createStatement();

//        String query = "SELECT DISTINCT PFNO FROM PYSTAFFITEMS WHERE PFNO = '8122' AND PYEAR = 2018 AND PMONTH = 9";
        String query = "SELECT DISTINCT PFNO FROM "+ schema+ ".PYSTAFFITEMS WHERE PYEAR = "+ process.pYear+ " AND PMONTH = "+ process.pMonth+ " ORDER BY PFNO";

        ResultSet rs = stmt.executeQuery(query);

        Integer i = 1;
        while(rs.next()){
            if((i - 1) < recordCount){
                out.print("<script type = \"text/javascript\">");
                out.print("comet.showProgress("+ i+ ", "+ recordCount+ ");");
                out.print("</script>") ;
            }

            String pfNo         = rs.getString("PFNO");
            
            out.print("<hr><font color = \"cyan\">"+ pfNo+ " process START.</font><br>");

            out.print(payroll.process(pfNo, process.pYear, process.pMonth));
            
            out.print("<hr><font color = \"green\">"+ pfNo+ " process END.</font>");

            if(i == recordCount){
                out.print("<script type = \"text/javascript\">");
                out.print("comet.taskComplete();");
                out.print("</script>") ;
            }

            out.flush(); // used to send the echoed data to the client
            Thread.sleep(7); // a little break to unload the server CPU

            i++;
        }

    }else{
        out.print("<script type = \"text/javascript\">");
        out.print("alert('No Record found');");
        out.print("comet.taskComplete();");
        out.print("</script>") ;
    }

}catch(Exception e){
    out.print(e.getMessage());
}
  
%>
        
    </body>
</html>