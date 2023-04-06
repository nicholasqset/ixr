<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="com.qset.ar.ARPyHdr"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.commonsrv.Company"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.sys.Sys"%>
<%
    final class PrintRptReceipt{
        HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
//        Integer batchNo     = request.getParameter("batchNo") != null && ! request.getParameter("batchNo").trim().equals("")? Integer.parseInt(request.getParameter("batchNo")): null;
        String pyNo         = request.getParameter("receiptNo") != null && ! request.getParameter("receiptNo").trim().equals("")? request.getParameter("receiptNo"): null;
    
        String rptName  = "Receipt";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
//                String comCode = sys.getOne("CSCOPROFILE", "COMPANYCODE", "");

                if(comCode != null){

                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if(sys.getOne(comCode+".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+comCode;
                    }else{
                        imgLogoSrc = request.getContextPath()+"/assets/img/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\" >";

                    html += "<tr>";
                    html += "<td align = \"center\" colspan = \"4\">"+ company.compName +"</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td width = \"33%\">&nbsp;</td>";
                    html += "<td rowspan = \"5\" align = \"center\"><img id = \"imgLogo\" height = \"128\" width = \"128\" src=\""+ imgLogoSrc +"\"></td>";
                    html += "<td width = \"33%\">&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td width = \"33%\">";
                    html += ""+ company.postalAdr +" - "+ company.postalCode +"  <br>";
                    html += "Email : "+ company.email +" <br>";
                    html += "Website : "+ company.website +" <br>";
                    html += "</td>";
                    html += "<td width = \"33%\">";
                    html += "Tel Office : "+ company.telephone +" <br>";
                    html += "Mobile : "+ company.cellphone +" ";
                    html += "</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td colspan = \"3\"  align = \"center\">"+ this.rptName+ "</td>";
                    html += "</tr>";

                    java.util.Date reportDate = originalFormat.parse(sys.getLogDate());
                    String reportDateLbl = targetFormat.format(reportDate);

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>"+ reportDateLbl+ "</td>";
                    html += "</tr>";

                    html += "</table>";
                }else{
                    html += "Company details not defined.";
                }
                
            }catch (Exception e){
                html += e.getMessage();
            }
            
            return html;
        }
        
        public String getReportDetails(){
            String html = "";
            
            ARPyHdr aRPyHdr = new ARPyHdr(pyNo, comCode);
            
            String entryDateLbl = "";
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

                java.util.Date entryDate = originalFormat.parse(aRPyHdr.entryDate);
                entryDateLbl = targetFormat.format(entryDate);
            }catch(Exception e){
                html += e.getMessage();
            }
            
            
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\">Receipt No</td>";
            html += "<td>"+ this.pyNo +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Description</td>";
            html += "<td>"+ aRPyHdr.pyDesc+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Receipt Date</td>";
            html += "<td>"+ entryDateLbl+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Period</td>";
            html += "<td>"+ aRPyHdr.pYear+ " - "+ aRPyHdr.pMonth+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Customer</td>";
//            html += "<td>"+ aRPyHdr.fullName+ "</td>";
            html += "<td>"+ aRPyHdr.customerName+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Payment Mode</td>";
            html += "<td>"+ aRPyHdr.pmName+ "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getReceiptDtls();
            
            return html;
        }
        
        public String getReceiptDtls(){
            String html = "";
            Sys sys = new Sys();

            if(sys.recordExists(comCode+".VIEWARPYDTLS", "PYNO = '"+ this.pyNo+ "'")){

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Document No</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                html += "</tr>";

                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    query = "SELECT * FROM "+comCode+".VIEWARPYDTLS WHERE PYNO = '"+ this.pyNo+ "' ORDER BY DOCNO";

                    ResultSet rs = stmt.executeQuery(query);

                    Integer count  = 1;
                    
                    Double aplAmtTotal = 0.0;

                    while(rs.next()){
                        String docNo        = rs.getString("DOCNO");
                        Double aplAmount    = rs.getDouble("APLAMOUNT");

                        html += "<tr>";
                        html += "<td>"+ count+ "</td>";
                        html += "<td>"+ docNo+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(aplAmount.toString())+ "</td>";
                        html += "</tr>";
                        
                        aplAmtTotal = aplAmtTotal + aplAmount;

                        count++;
                    }
                    
                    html += "<tr>";
                    html += "<td colspan = \"2\" style = \"text-align: center; font-weight: bold;\">Total</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(aplAmtTotal.toString())+ "</td>";
                    html += "</tr>";
                    
                }catch (SQLException e){
                    html += e.getMessage();
                }catch (Exception e){
                    html += e.getMessage();
                }

                html += "</table>";

            }else{
                html += "No record found.";
            }

            return html;
        }
        
        public String printRpt(){
            String html = "";
            
            html += this.getReportHeader();
            html += "<br>";
            html += this.getReportDetails();
            
            return html;
        }
    }
    
    PrintRptReceipt printRptReceipt = new PrintRptReceipt();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Receipt</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptReceipt.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
