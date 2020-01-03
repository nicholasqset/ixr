<%-- 
    Document   : parser
    Created on : Nov 14, 2019, 7:41:34 PM
    Author     : nicholas
--%>

<%@include file="class.subscription.jsp" %>
<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%
String function = request.getParameter("function");

Object obj = new Subscription();;

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
