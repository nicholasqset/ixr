<%@page import="com.qset.restaurant.Restaurant"%>
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

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
    <title>Post Transactions Backend</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>

    <script type="text/javascript">
        // KHTML browser don't share javascripts between iframes
        var is_khtml = navigator.appName.match("Konqueror") || navigator.appVersion.match("KHTML");
        if (is_khtml)
        {
            var prototypejs = document.createElement('script');
            prototypejs.setAttribute('type', 'text/javascript');
            prototypejs.setAttribute('src', '<%=request.getContextPath() + "/js/scriptaculous/lib/prototype.js"%>');
            var head = document.getElementsByTagName('head');
            head[0].appendChild(prototypejs);
        }
        // load the comet object
        var comet = window.parent.comet;
    </script>
    <%

        final class Process {

            HttpSession session = request.getSession();
            String comCode = session.getAttribute("comCode").toString();
            Integer pYear = (request.getParameter("pYear") != null && !request.getParameter("pYear").trim().equals("")) ? Integer.parseInt(request.getParameter("pYear")) : null;
            Integer pMonth = (request.getParameter("pMonth") != null && !request.getParameter("pMonth").trim().equals("")) ? Integer.parseInt(request.getParameter("pMonth")) : null;

            public Integer getReceiptCount() {
                Integer receiptCount = 0;

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query;

                    query = "SELECT COUNT(PYNO)DCT FROM " + this.comCode + ".RTPYHDR WHERE PYEAR = " + this.pYear + " AND PMONTH = " + this.pMonth + " AND CLEARED = 1 AND (POSTED IS NULL OR POSTED = 0)";

                    ResultSet rs = stmt.executeQuery(query);

                    while (rs.next()) {
                        receiptCount = rs.getInt("DCT");
                    }
                } catch (SQLException e) {
                    e.getMessage();
                } catch (Exception e) {
                    e.getMessage();
                }

                return receiptCount;
            }

            public String markPosted(String pyNo) {
                String posted = "";
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    stmt.executeUpdate("UPDATE " + this.comCode + ".RTPYHDR SET POSTED = 1 WHERE PYNO = '" + pyNo + "'");

                } catch (Exception e) {
                    posted += e.getMessage();
                }

                return posted;
            }

        }

        Process process = new Process();

        out.print("working year " + process.pYear + " " + process.pMonth + " <hr> ");
        
        String comCode = session.getAttribute("comCode").toString();

        Restaurant restaurant = new Restaurant(comCode);

        try {

            Integer recordCount = process.getReceiptCount();

            if (recordCount > 0) {

                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query = "SELECT PYNO FROM "+comCode+".RTPYHDR WHERE PYEAR = " + process.pYear + " AND PMONTH = " + process.pMonth + " AND CLEARED = 1 AND (POSTED IS NULL OR POSTED = 0)";

                ResultSet rs = stmt.executeQuery(query);

                Integer i = 1;
                while (rs.next()) {
                    if ((i - 1) < recordCount) {
                        out.print("<script type = \"text/javascript\">");
                        out.print("comet.showProgress(" + i + ", " + recordCount + ");");
                        out.print("</script>");
                    }

                    String pyNo = rs.getString("PYNO");

                    String pyPosted = restaurant.postReceipt(pyNo, session, request, comCode);

                    if (pyPosted.equals("1")) {
                        process.markPosted(pyNo);
                    }

                    if (i == recordCount) {
                        out.print("<script type = \"text/javascript\">");
                        out.print("comet.taskComplete();");
                        out.print("</script>");
                    }

                    out.flush(); // used to send the echoed data to the client
                    Thread.sleep(7); // a little break to unload the server CPU

                    i++;
                }

            } else {
                out.print("<script type = \"text/javascript\">");
                out.print("alert('No Record found');");
                out.print("comet.taskComplete();");
                out.print("</script>");
            }

        } catch (Exception e) {
            out.print(e.getMessage());
        }

    %>

</body>
</html>