<%@page import="bean.finance.Finance"%>
<%@page import="bean.payroll.Payroll"%>
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
  <title>Period End Backend</title>
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
    
    Integer pYear       = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth      = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
      
    Integer nextPyear   = request.getParameter("nextPyear") != null && ! request.getParameter("nextPyear").trim().equals("")? Integer.parseInt(request.getParameter("nextPyear")): null;
    Integer nextPmonth  = (request.getParameter("nextPmonth") != null && ! request.getParameter("nextPmonth").trim().equals(""))? Integer.parseInt(request.getParameter("nextPmonth")): null;
      
    public String init(){
        String html = "";
        
        
        
        return html;
    }
    
}

Process process = new Process();
//out.print(process.init());

//HttpSession session = request.getSession();
String schema = session.getAttribute("comCode").toString();
        
        Sys sys = new Sys();
        Payroll payroll = new Payroll(schema);
        Finance finance = new Finance(schema);
        
        try{
            Integer recordCount = sys.getRecordCount(schema+ ".VIEWPYSLIP", "PYEAR = "+ process.pYear+ " AND PMONTH = "+ process.pMonth+ " AND RECUR = 1");
            
            if(recordCount > 0){
                
                sys.delete(schema+ ".PYSTAFFITEMS", "PYEAR = "+ process.nextPyear+ " AND PMONTH = "+ process.nextPmonth);
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+ schema+ ".VIEWPYSLIP WHERE PYEAR = "+ process.pYear+ " AND PMONTH = "+ process.pMonth+ " AND RECUR = 1";
                out.println(query);
                
                ResultSet rs = stmt.executeQuery(query);
                
                Integer i = 1;
                while(rs.next()){
                    if((i - 1) < recordCount){
                        out.print("<script type = \"text/javascript\">");
                        out.print("comet.showProgress("+ i+ ", "+ recordCount+ ");");
                        out.print("</script>");
                    }
                    
                    String pfNo         = rs.getString("PFNO");
                    String itemCode     = rs.getString("ITEMCODE");
                    Double amount       = rs.getDouble("AMOUNT");
                    
                    payroll.periodEnd(pfNo, itemCode, process.nextPyear, process.nextPmonth, amount, session, request);
                    
                    if(i == recordCount){
                        out.print("<script type = \"text/javascript\">");
                        out.print("comet.taskComplete();");
                        out.print("</script>");
                    }

                    out.flush(); // used to send the echoed data to the client
                    Thread.sleep(7); // a little break to unload the server CPU
                    
                    i++;
                }
                
                finance.activateNextPeriod(process.nextPyear, process.nextPmonth);
                
//                out.print("process.nextPmonth = "+ process.nextPmonth);
                
                if(process.nextPmonth == 1){
                    payroll.yearEnd(process.nextPyear);
//                    out.print(payroll.yearEnd(process.nextPyear));
                }
            }else{
                out.print("<script type = \"text/javascript\">");
                out.print("alert('No record found');");
                out.print("comet.taskComplete();");
                out.print("</script>");
            }

        }catch(Exception e){
            out.print(e.getMessage());
        }

    
%>
        
    </body>
</html>