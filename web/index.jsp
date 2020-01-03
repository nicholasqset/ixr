<%
    String act = request.getParameter("act");
    if(act != null){
       if(act.equals("logout")){
           session.invalidate();
           response.sendRedirect("./");
           return;
        }
    }
   
   
    if ((session.getAttribute("userId") == null)||(session.getAttribute("userId").toString().trim().equals(""))) {
        %>
        <jsp:include page="./login.jsp" />
        <%
    } else {
        %>
      <jsp:include page="./container.jsp" />
<%
        }
%>