<%
    Boolean showPage = false;
%>


<%
    if (showPage) {
%>
<jsp:include page="./ixr_admin.jsp" />
<%
} else {
%>
<%--<jsp:include page="./ixr_admin.jsp" />--%>
<%
    }
%>