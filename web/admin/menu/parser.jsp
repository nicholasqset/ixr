<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%@include file="class.menu.jsp" %>
<%
Menu menu = new Menu();
String function = request.getParameter("function");

Object obj = menu;

try{
            
    Method method = obj.getClass().getMethod(function);
    try {
        out.print(method.invoke(obj));
    } catch (IllegalArgumentException e) {
              
    } catch (IllegalAccessException e) {
              
    } catch (InvocationTargetException e) {}
        
} catch (NoSuchMethodException e) {
        
}

%>