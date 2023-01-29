<%@page import="bean.sys.Sys"%>
<%
    String act = request.getParameter("act");
    
    Sys sys = new Sys();
    
    if (act != null) {
        if (act.equals("logout")) {
            if(session.getAttribute("comCode") != null){
                sys.logUser(session.getAttribute("comCode").toString(), session.getId(), session.getAttribute("userId").toString(), "out");
            }
            
            session.invalidate();
            response.sendRedirect("./");
            return;
        }
    }

    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId").toString().trim().equals(""))) {
%>
<jsp:include page="./login.jsp" />
<%
} else {
%>
<jsp:include page="./container.jsp" />
<%
    }
%>