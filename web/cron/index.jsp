<%-- 
    Document   : index
    Created on : Apr 10, 2023, 1:03:35 PM
    Author     : nicholas
--%>

<%@include file="Jobs.jsp" %>
<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%
String function = request.getParameter("function");

Object obj = new Jobs();;

try{
            
    Method method = obj.getClass().getMethod(function);
    try {
        out.print(method.invoke(obj));
    } catch (IllegalArgumentException e) {
        out.print(e.getMessage());
    } catch (IllegalAccessException e) {
        out.print(e.getMessage());
    } catch (InvocationTargetException e) {
        out.print(e.getMessage());
    }
        
} catch (NoSuchMethodException e) {
    out.print(e.getMessage());
}

%>
