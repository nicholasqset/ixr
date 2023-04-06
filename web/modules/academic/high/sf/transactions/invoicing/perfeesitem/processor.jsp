<%@page import="com.qset.high.HighSchool"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="com.qset.sys.Sys"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
  <title>Invoice Per Item Backend</title>
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
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String formCode         = request.getParameter("studentForm");
    String studTypeCode     = request.getParameter("studentType");
    String itemCode         = request.getParameter("item");
    Double amount           = (request.getParameter("amount") != null && ! request.getParameter("amount").toString().trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
    
    String[] studentNos     = request.getParameterValues("checkEach");
    
    public String init(){
        String html = "";
        
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
                    
                    this.createInvDtls(studentNo);
                    
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
    
    public Integer createInvDtls(String studentNo){
        Integer invDtlsCreated = 0;
        Sys sys = new Sys();
        
        if(this.createInvHdr(studentNo) == 1){
            String invType = "PI";
            String invNo = sys.getOne(""+this.comCode+".HGINVSHDR", "INVNO", "ACADEMICYEAR = "+ this.academicYear+" AND TERMCODE = '"+ this.termCode+ "' AND STUDENTNO = '"+ studentNo+ "' AND INVTYPE = '"+ invType+ "'");
            if(invNo != null && ! invNo.trim().equals("")){
                this.insertInvDtls(invNo, this.itemCode, this.amount);
            }
        }
        
        return invDtlsCreated;
    }
    
    public Integer createInvHdr(String studentNo){
        Integer invHdrCreated = 0;
        
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        String invType = "PI";
        
        if(sys.recordExists(""+this.comCode+".HGINVSHDR", "ACADEMICYEAR = "+ this.academicYear+" AND TERMCODE = '"+ this.termCode+ "' AND STUDENTNO = '"+ studentNo+ "' AND INVTYPE = '"+ invType+ "'")){
            invHdrCreated = 1;
        }else{
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = sys.generateId(""+this.comCode+".HGINVSHDR", "ID");
                String invNo    = sys.getNextNo(""+this.comCode+".HGINVSHDR", "ID", "", "IN", 7);

                String query = "INSERT INTO "+this.comCode+".HGINVSHDR "
                                + "(ID, ACADEMICYEAR, TERMCODE, STUDENTNO, INVNO, INVDESC, INVTYPE, INVDATE, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + id+ ", "
                                + this.academicYear+", "
                                + "'"+ this.termCode+ "', "
                                + "'"+ studentNo+ "', "
                                + "'"+ invNo+ "', "
                                + "'Auto Invoice "+ this.academicYear+ "-"+ this.termCode+ "-"+ this.formCode+ "', "
                                + "'"+ invType+ "', "
                                + "'"+ sys.getLogDate()+ "', "
                                + "'"+ sys.getLogUser(session)+"', "
                                + "'"+ sys.getLogDate()+ "', "
                                + "'"+ sys.getLogTime()+ "', "
                                + "'"+ sys.getClientIpAdr(request)+ "'"
                                + ")";

                invHdrCreated = stmt.executeUpdate(query);
                
            }catch(SQLException e){
                
            }catch(Exception e){
                
            }
        }
        
        return invHdrCreated;
    }
    
    public Integer insertInvDtls(String invNo, String itemCode, Double amount){
        Integer invDtlsInserted = 0;
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        if(sys.recordExists(""+this.comCode+".HGINVSDTLS", "INVNO = '"+ invNo+ "' AND ITEMCODE = '"+ itemCode+ "'")){
            invDtlsInserted = 1;
        }else{
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = sys.generateId(""+this.comCode+".HGINVSDTLS", "ID");

                String query = "INSERT INTO "+this.comCode+".HGINVSDTLS "
                                + "(ID, INVNO, ITEMCODE, AMOUNT, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + id+ ", "
                                + "'"+ invNo+ "', "
                                + "'"+ itemCode+ "', "
                                + amount+ ", "
                                + "'"+ sys.getLogUser(session)+"', "
                                + "'"+ sys.getLogDate()+ "', "
                                + "'"+ sys.getLogTime()+ "', "
                                + "'"+ sys.getClientIpAdr(request)+ "'"
                                + ")";

                invDtlsInserted = stmt.executeUpdate(query);
                
            }catch(SQLException e){
                
            }catch(Exception e){
                
            }
        }
        
        return invDtlsInserted;
    }
    
}

Process process = new Process();
out.print(process.init());

    


%>
        
    </body>
</html>