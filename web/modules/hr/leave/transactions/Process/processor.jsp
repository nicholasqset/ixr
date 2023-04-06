<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
  <title>Leave Processing Backend</title>
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

try{
    
    Connection conn = ConnectionProvider.getConnection();
    Statement stmt;
    
    stmt = conn.createStatement();
    String query = " SELECT COUNT(*) FROM HRSTAFFPROFILE ";
    ResultSet rs = stmt.executeQuery(query);
    
    Integer recordCount = 0;
    while(rs.next()){
        recordCount = rs.getInt("COUNT(*)");			
    }
    
    query = " SELECT * FROM HRSTAFFPROFILE ";
    rs = stmt.executeQuery(query);
    int count = 1;
    while(rs.next()){
        String pfno = rs.getString("PFNO");
        
        if((count -1) < recordCount){
            out.print("<script type = \"text/javascript\">");
            out.print("comet.showProgress("+count+", "+recordCount+");");
            out.print("</script>") ;
        }
        
        if(count == recordCount){
            out.print("<script type = \"text/javascript\">");
            out.print("comet.taskComplete();");
            out.print("</script>") ;
        }
        
        out.print(query+"<br>");
        
        out.flush(); // used to send the echoed data to the client
        Thread.sleep(7); // a little break to unload the server CPU
        count++;
    }
    
}catch(Exception e){
    out.print(e.getMessage());
}

%>
    </body>
</html>