<%-- 
    Document   : index
    Created on : Dec 6, 2015, 10:05:06 AM
    Author     : nicholas
--%>

<%
    String reportType = request.getParameter("reportType");
    if(reportType.trim().equals("m")){
        %>
        <jsp:include page="./mainreport.jsp" />
        <%
    }else if(reportType.trim().equals("s")){
       %>
       <jsp:include page="./subreport.jsp" />
       <%
    }else{
        %>
        
        <html>
            <head>
                <title></title>
            </head>
            <body>
                <script type="text/javascript">
                    parent.reports.getUploadResponse(1, 'An unexpected error occured.');
                </script>
            </body>
        </html>
        
        <%
        
    }
%>