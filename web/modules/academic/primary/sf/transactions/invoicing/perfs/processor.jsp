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
  <title>Auto Invoicing Backend</title>
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
    
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String classCode        = request.getParameter("studentClass");
    String studTypeCode     = request.getParameter("studentType");
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
    
    public Integer createInvHdr(String studentNo){
        Integer invHdrCreated = 0;
        
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        String invType = "AT";
        
        if(system.recordExists("PRINVSHDR", "ACADEMICYEAR = "+ this.academicYear+" AND TERMCODE = '"+ this.termCode+ "' AND STUDENTNO = '"+ studentNo+ "' AND INVTYPE = '"+ invType+ "'")){
            invHdrCreated = 1;
        }else{
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId("PRINVSHDR", "ID");
                String invNo    = system.getNextNo("PRINVSHDR", "ID", "", "IN", 7);

                String query = "INSERT INTO PRINVSHDR "
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
                                + "'Auto Invoice "+ this.academicYear+ "-"+ this.termCode+ "-"+ this.classCode+ "', "
                                + "'"+ invType+ "', "
                                + "'"+ system.getLogDate()+ "', "
                                + "'"+ system.getLogUser(session)+"', "
                                + "'"+ system.getLogDate()+ "', "
                                + "'"+ system.getLogTime()+ "', "
                                + "'"+ system.getClientIpAdr(request)+ "'"
                                + ")";

                invHdrCreated = stmt.executeUpdate(query);
                
            }catch(SQLException e){
                
            }catch(Exception e){
                
            }
        }
        
        return invHdrCreated;
    }
    
    public Integer createInvDtls(String studentNo){
        Integer invDtlsCreated = 0;
        Sys sys = new Sys();
        
        if(this.createInvHdr(studentNo) == 1){
            String invType = "AT";
            String invNo = system.getOne("PRINVSHDR", "INVNO", "ACADEMICYEAR = "+ this.academicYear+" AND TERMCODE = '"+ this.termCode+ "' AND STUDENTNO = '"+ studentNo+ "' AND INVTYPE = '"+ invType+ "'");
            if(invNo != null && ! invNo.trim().equals("")){
                if(system.recordExists("VIEWPRFSDETAILS", "ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND CLASSCODE = '"+ this.classCode+ "' AND STUDTYPECODE = '"+ this.studTypeCode+ "' ")){
                    try{
                        Connection conn = ConnectionProvider.getConnection();
                        Statement stmt = conn.createStatement();

                        String query = "SELECT * FROM VIEWPRFSDETAILS WHERE ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE     = '"+ this.termCode+ "' AND CLASSCODE     = '"+ this.classCode+ "' AND STUDTYPECODE = '"+ this.studTypeCode+ "' ";

                        ResultSet rs = stmt.executeQuery(query);
                        while(rs.next()){
                            String itemCode     = rs.getString("ITEMCODE");
                            Double amount       = rs.getDouble("AMOUNT");

                            this.insertInvDtls(invNo, itemCode, amount);

                        }

                    }catch (SQLException e){

                    }catch (Exception e){

                    }
                }
            }
        }
        
        return invDtlsCreated;
    }
    
    public Integer insertInvDtls(String invNo, String itemCode, Double amount){
        Integer invDtlsInserted = 0;
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        if(system.recordExists("PRINVSDTLS", "INVNO = '"+ invNo+ "' AND ITEMCODE = '"+ itemCode+ "'")){
            invDtlsInserted = 1;
        }else{
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id      = system.generateId("PRINVSDTLS", "ID");

                String query = "INSERT INTO PRINVSDTLS "
                                + "(ID, INVNO, ITEMCODE, AMOUNT, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + id+ ", "
                                + "'"+ invNo+ "', "
                                + "'"+ itemCode+ "', "
                                + amount+ ", "
                                + "'"+ system.getLogUser(session)+"', "
                                + "'"+ system.getLogDate()+ "', "
                                + "'"+ system.getLogTime()+ "', "
                                + "'"+ system.getClientIpAdr(request)+ "'"
                                + ")";

                invDtlsInserted = stmt.executeUpdate(query);
                
            }catch(SQLException e){
                e.getMessage();
            }catch(Exception e){
                e.getMessage();
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