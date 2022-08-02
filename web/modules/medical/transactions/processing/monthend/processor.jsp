<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="bean.sys.Sys"%>
<%
    
    final class Process{
    
        Integer yearFrom    = request.getParameter("yearFrom") != null && !request.getParameter("yearFrom").trim().equals("")? Integer.parseInt(request.getParameter("yearFrom")): null;
        Integer yearTo      = request.getParameter("yearTo") != null && !request.getParameter("yearTo").trim().equals("")? Integer.parseInt(request.getParameter("yearTo")): null;

        Integer monthFrom   = request.getParameter("monthFrom") != null && !request.getParameter("monthFrom").trim().equals("")? Integer.parseInt(request.getParameter("monthFrom")): null;
        Integer monthTo     = request.getParameter("monthTo") != null && !request.getParameter("monthTo").trim().equals("")? Integer.parseInt(request.getParameter("monthTo")): null;

        public Integer copyItemCharges(){
            Integer copyItemCharge = 0;

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query = "SELECT * FROM HMITEMCHARGES WHERE PYEAR = "+ this.yearFrom+ " AND PMONTH = "+ this.monthFrom+ "";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    String itemCode    = rs.getString("ITEMCODE");		
                    Double amount      = rs.getDouble("AMOUNT");

                    copyItemCharge = this.createItemCharge(itemCode, amount);
                }
            }catch (Exception e){

            }

            return copyItemCharge;
        }

        public Integer createItemCharge(String itemCode, Double amount){
            Integer createItemCharge = 0;
            Sys sys = new Sys();
            if(! system.recordExists("HMITEMCHARGES", "PYEAR = "+ this.yearTo+ " AND PMONTH = "+ this.monthTo+ " AND ITEMCODE = '"+ itemCode +"'")){
                try{
                    Connection conn  = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    Integer id      = system.generateId("HMITEMCHARGES", "ID");

                    String query = "INSERT INTO HMITEMCHARGES "
                            + "(ID, PYEAR, PMONTH, ITEMCODE, AMOUNT)"
                            + "VALUES"
                            + "("
                            + id +", "
                            + this.yearTo +", "
                            + this.monthTo +", "
                            + "'"+ itemCode +"', "
                            + amount
                            + ")";

                    createItemCharge = stmt.executeUpdate(query);

                }catch(Exception e){

                }
            }

            return createItemCharge;
        }

        public Integer copyRegItems(){
            Integer copyRegItem = 0;

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM HMREGITEMS WHERE PYEAR = "+ this.yearFrom+ " AND PMONTH = "+ this.monthFrom+ "";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    String itemCode    = rs.getString("ITEMCODE");		
                    String regType     = rs.getString("REGTYPE");

                    copyRegItem = this.createRegItem(itemCode, regType);
                }
            }catch (Exception e){

            }

            return copyRegItem;
        }

        public Integer createRegItem(String itemCode, String regType){
            Integer createRegItem = 0;
            Sys sys = new Sys();
            if(! system.recordExists("HMREGITEMS", "PYEAR = "+ this.yearTo+ " AND PMONTH = "+ this.monthTo+ " AND ITEMCODE = '"+ itemCode+ "' AND REGTYPE = '"+ regType+ "'")){
                try{
                    Connection conn  = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    Integer id      = system.generateId("HMREGITEMS", "ID");

                    String query = "INSERT INTO HMREGITEMS "
                            + "(ID, PYEAR, PMONTH, ITEMCODE, REGTYPE)"
                            + "VALUES"
                            + "("
                            + id +", "
                            + this.yearTo +", "
                            + this.monthTo +", "
                            + "'"+ itemCode +"', "
                            + "'"+ regType +"' "
                            + ")";

                    createRegItem = stmt.executeUpdate(query);

                }catch(Exception e){

                }
            }

            return createRegItem;
        }

        public Integer copyInventory(){
            Integer copyInventory = 0;

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM HMINVENTBAL WHERE PYEAR = "+ this.yearFrom+ " AND PMONTH = "+ this.monthFrom+ "";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    String itemCode     = rs.getString("ITEMCODE");		
                    Double bal          = rs.getDouble("BAL");

                    copyInventory = this.createInventory(itemCode, bal);
                }
            }catch (Exception e){

            }

            return copyInventory;
        }

        public Integer createInventory(String itemCode, Double bal){
            Integer createInventory = 0;
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            if(! system.recordExists("HMINVENTBAL", "PYEAR = "+ this.yearTo+ " AND PMONTH = "+ this.monthTo+ " AND ITEMCODE = '"+ itemCode +"'")){
                try{
                    Connection conn  = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    Integer id      = system.generateId("HMINVENTBAL", "ID");

                    String query = "INSERT INTO HMINVENTBAL "
                            + "(ID, PYEAR, PMONTH, ITEMCODE, OBAL, BAL, AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                            + "VALUES"
                            + "("
                            + id +", "
                            + this.yearTo +", "
                            + this.monthTo +", "
                            + "'"+ itemCode +"', "
                            +  bal +", "
                            +  bal +", "
                            + "'"+ system.getLogUser(session) +"', "
                            + "'"+ system.getLogDate() +"', "
                            + "'"+ system.getLogTime() +"', "
                            + "'"+ system.getClientIpAdr(request) +"'"
                            + ")";

                    
                    createInventory = stmt.executeUpdate(query);

                }catch(Exception e){

                }
            }

            return createInventory;
        }
    
}
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
    <title>Year End Backend</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  
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
  
</head>
<body>
    
    


    <%

        Process process = new Process();

        for(int i = 1; i <= 3; i++){

            if(i == 1){
                process.copyItemCharges();
            }
            else if (i == 2){
                process.copyRegItems();
            }
            else if(i == 3){
                process.copyInventory();
            }

            if((i - 1) < 3){
                out.print("<script type = \"text/javascript\">");
                out.print("comet.showProgress("+ i +", "+ 3 +");");
                out.print("</script>") ;
            }

            if(i == 3){
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