<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%@include file="Programme.jsp" %>
<%    
    String function = request.getParameter("function");

    Object obj = new Programme();

    try {

        Method method = obj.getClass().getMethod(function);
        try {
            out.print(method.invoke(obj));
        } catch (IllegalArgumentException e) {
            out.print(method.invoke(obj));
        } catch (IllegalAccessException e) {
            out.print(method.invoke(obj));
        } catch (InvocationTargetException e) {
            out.print(method.invoke(obj));
        }

    } catch (NoSuchMethodException e) {
        out.print(e.getMessage());
    }

%>