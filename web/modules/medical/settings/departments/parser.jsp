<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%@include file="class.departments.jsp" %>
<%
Departments departments = new Departments();
String function = request.getParameter("function");

Object obj = departments;

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
        
} catch ( NoSuchMethodException e) {
    out.print(e.getMessage());
}

%>