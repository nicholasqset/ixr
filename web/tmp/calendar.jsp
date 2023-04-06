<%-- 
    Document   : calendar
    Created on : Sep 5, 2016, 8:29:09 AM
    Author     : nicholas
--%>

<%@page import="com.qset.gui.Gui"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <script type="text/javascript"> var rootPath = '<%= request.getContextPath() %>';</script>
    </head>
    <body>
        <%
            Gui gui = new Gui();

            String calendarUI = gui.formInput("text", "startDate", 15, "", "onfocus=\"lcs(this);\" onclick=\"event.cancelBubble=true;lcs(this);\"", "");
            out.print("hieeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
            out.print(calendarUI);
            out.print("<br>hieeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
        %>
        <%
            
            out.print(gui.loadJs(request.getContextPath(), "calendar"));
        %>
    </body>
</html>
