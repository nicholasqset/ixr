<%@page import="com.qset.payroll.Payroll"%>
<%
    
    Payroll payroll = new Payroll();
    
//    String myTax = payroll.getIncomeTax(120089.0);
//    String myTax = payroll.getIncomeTax(20781.0);
    Double myTax = payroll.getIncomeTax(20781.0);
    
    out.print("TotalTax = "+ myTax);
    
    
    
%>