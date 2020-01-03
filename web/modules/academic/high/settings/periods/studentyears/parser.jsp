<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%@include file="class.studentyears.jsp" %>
<%
String function = request.getParameter("function");

StudentYears studentYears = new StudentYears();
Object obj = studentYears;

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