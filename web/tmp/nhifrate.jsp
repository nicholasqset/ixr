<%@page import="com.qset.payroll.Payroll"%>
<%
    
    Payroll payroll = new Payroll();
    
//    String nhifRate = payroll.getNHIFRate(86000.0);
    Double nhifRate = payroll.getNHIFRate(86000.0);
    
//    out.print(nhifRate);
    out.print("NHIFRate = "+ nhifRate);
    
    
    
%>