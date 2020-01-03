<%@page import="java.util.HashMap"%>
<%@page import="bean.sys.Sys"%>
<%
    Sys sys = new Sys();
   
    HashMap<String, String> map = system.getArray("SELECT PFNO, FULLNAME FROM HRSTAFFPROFILE");
   
    for (HashMap.Entry<String, String> entry : map.entrySet()){
        out.println(entry.getKey() + "/" + entry.getValue());
        out.print("<br>");
    }
%>