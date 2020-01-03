<%-- 
    Document   : parser
    Created on : Dec 23, 2019, 2:54:27 PM
    Author     : nicholas
--%>

<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%@include file="class.statement.jsp" %>
<%
String function = request.getParameter("function");

Object obj = new Statement();

try{
    Method method = obj.getClass().getMethod(function);
    try{
        out.print(method.invoke(obj));
    }catch (IllegalArgumentException e) {
        out.print(e.getMessage());
    }catch (IllegalAccessException e) {
        out.print(e.getMessage());
    }catch (InvocationTargetException e) {
        out.print(e.getMessage());
    }
}catch (NoSuchMethodException e) {
    out.print(e.getMessage());
}catch (Exception e) {
    out.print(e.getMessage());
}

%>
