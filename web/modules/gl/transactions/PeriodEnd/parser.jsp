<%-- 
    Document   : parser
    Created on : Oct 15, 2018, 10:44:18 AM
    Author     : nicholas
--%>

<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%@include file="class.PeriodEnd.jsp" %>
<%
String function = request.getParameter("function");

Object obj = new PeriodEnd();

try{
    Method method = obj.getClass().getMethod(function);
    try {
        out.print(method.invoke(obj));
    } catch(IllegalArgumentException e) {
        out.print(e.getMessage());
    } catch(IllegalAccessException e) {
        out.print(e.getMessage());
    } catch(InvocationTargetException e) {
        out.print(e.getMessage());
    }
        
} catch(NoSuchMethodException e) {
    out.print(e.getMessage());
} catch (Exception e) {
    out.print(e.getMessage());
}

%>
