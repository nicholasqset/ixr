<%@page import="bean.gl.GLAccount"%>
<%@page import="bean.finance.Finance"%>
<%@page import="bean.gl.GeneralLedger"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
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
        
        Integer nextPyear;
        Integer nextPmonth;
    }

    try{
        Process process = new Process();
        Sys sys = new Sys();
        GeneralLedger generalLedger = new GeneralLedger();
        Finance finance = new Finance();
        
        if(process.pMonth == 12){
            process.nextPyear   = process.pYear + 1;
            process.nextPmonth  = 1;
        }else{
            process.nextPyear   = process.pYear;
            process.nextPmonth  = process.pMonth + 1;
        }
        
        Integer recordCount = system.getRecordCount("VIEWGLTBOA", "PYEAR = "+ process.pYear+ " AND PMONTH = "+ process.pMonth);

        if(recordCount > 0){

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT * FROM VIEWGLTBOA WHERE PYEAR = "+ process.pYear+ " AND PMONTH = "+ process.pMonth;
                   
//            out.print(query);

            ResultSet rs = stmt.executeQuery(query);

            Integer i = 1;
            while(rs.next()){
                if((i - 1) < recordCount){
                    out.print("<script type = \"text/javascript\">");
                    out.print("comet.showProgress("+ i+ ", "+ recordCount+ ");");
                    out.print("</script>");
                }
                    
                String accountCode      = rs.getString("ACCOUNTCODE");
//                String normalBal        = rs.getString("NORMALBAL");
                Double drAmount         = rs.getDouble("DRAMOUNT");
                Double crAmount         = rs.getDouble("CRAMOUNT");
                
                String srcBatchNo_      = "-"+ process.nextPyear+ ""+ process.nextPmonth;
                String srcBatchDesc     = "OB-"+ process.nextPyear+ "-"+ process.nextPmonth;
                String srcDocNo         = "-"+ process.pYear+ ""+ process.pMonth;
                String srcDocDesc       = "OB-"+ process.pYear+ "-"+ process.pMonth;
                String reference        = srcBatchDesc;
                
                GLAccount gLAccount = new GLAccount(accountCode);
                if(gLAccount.normalBal.equals("DR")){
                    drAmount = drAmount - crAmount;
                    crAmount = 0.0;
                }else{
                    drAmount = 0.0;
                    crAmount = crAmount - drAmount;
                }

                generalLedger.createBatchDtls(Integer.parseInt(srcBatchNo_), srcBatchDesc, "GL-JE", srcDocNo, srcDocDesc, reference, accountCode, gLAccount.normalBal, drAmount, crAmount, process.nextPyear, process.nextPmonth, session, request);

                if(i == recordCount){
                    out.print("<script type = \"text/javascript\">");
                    out.print("comet.taskComplete();");
                    out.print("</script>");
                }

                out.flush(); // used to send the echoed data to the client
                Thread.sleep(7); // a little break to unload the server CPU

                i++;
            }

//                finance.activateNextPeriod(process.nextPyear, process.nextPmonth);

//                out.print("process.nextPmonth = "+ process.nextPmonth);
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