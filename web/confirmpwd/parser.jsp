<%@page import="java.lang.reflect.InvocationTargetException"%>
<%@page import="java.lang.reflect.Method"%>
<%@include file="class.confirmpwd.jsp" %>
<%
    ConfirmPwd confirmPwd = new ConfirmPwd();
    String function = request.getParameter("function");

    Object obj = confirmPwd;

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
    }catch (NoSuchMethodException e) {
        out.print(e.getMessage());
    }

%>