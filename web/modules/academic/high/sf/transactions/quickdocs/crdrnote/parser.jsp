<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%@include file="class.crdrnote.jsp" %>
<%
String function = request.getParameter("function");

//CrDrNote crDrNote = new CrDrNote();
//Object obj = crDrNote;

Object obj = new CrDrNote();

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