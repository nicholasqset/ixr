<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.medical.MedicalReceipt"%>
<%@page import="bean.commonsrv.Company"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.sys.Sys"%>
<%
    final class RptReceipts{
        public String rcptNo = request.getParameter("receiptNo");
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            String companyCode = system.getOne("CSCOPROFILE", "COMPANYCODE", "");
            if(companyCode != null){
                
                Company company = new Company(companyCode);
                
                String imgLogoSrc;
                
                if(system.getOne("CSCOLOGO", "LOGO", "COMPANYCODE = '"+ companyCode +"'") != null){
                    imgLogoSrc = "logo.jsp?code="+companyCode;
                }else{
                    imgLogoSrc = request.getContextPath()+"/images/logo/default-logo.png";
                }
            
                html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\" >";

                html += "<tr>";
                html += "<td align = \"center\" colspan = \"4\">"+ company.companyName +"</td>";
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
                html += "<td colspan = \"3\"  align = \"center\">Medical Receipt</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>"+ system.getLogDate() +"</td>";
                html += "</tr>";

                html += "</table>";
            }else{
                html += "Company details not defined.";
            }
            
            return html;
        }
        
        public String getReportDetails(){
            String html = "";
//            Sys sys = new Sys();
//            String invNo = system.getOne("HMRCPTS", "INVNO", "RCPTNO = '"+ this.rcptNo +"'");
//            
//            if(invNo != null){
            
            MedicalReceipt medicalReceipt = new MedicalReceipt(this.rcptNo);
                
            html += "<table width = \"100%\" cellpadding = \"1\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\">Receipt No</td>";
            html += "<td>"+ this.rcptNo +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Date</td>";
            html += "<td>"+ medicalReceipt.rcptDate +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Payment Mode</td>";
            html += "<td>"+ medicalReceipt.pmName +"</td>";
            html += "</tr>";

            html += "</table>";
                
//            }else{
//                html += "Receipt invoice details not found.";
//            }
            
            html += "<br>";
            
            html += this.getInvoiceDtls(medicalReceipt.invNo);
            
            return html;
        }
        
        public String getInvoiceDtls(String invNo){
        String html = "";
        
        Sys sys = new Sys();
        
        if(system.recordExists("VIEWHMINVSDETAILS", "INVNO = '"+ invNo +"'")){
            
            html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Item</th>";
            html += "<th>Quantity</th>";
            html += "<th style = \"text-align: right;\">VAT</th>";
            html += "<th style = \"text-align: right;\">Net</th>";
            html += "<th style = \"text-align: right;\">Gross</th>";
            html += "</tr>";
            
            Double total   = 0.00;
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM VIEWHMINVSDETAILS WHERE INVNO = '"+ invNo +"'";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String qty          = rs.getString("QTY");
                    String itemName     = rs.getString("ITEMNAME");
                    Double vatAmount    = rs.getDouble("VATAMOUNT");
                    Double netAmount    = rs.getDouble("NETAMOUNT");
                    Double amount       = rs.getDouble("AMOUNT");
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ itemName +"</td>";
                    html += "<td>"+ qty +"</td>";
                    html += "<td style = \"text-align: right;\">"+ vatAmount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ netAmount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ amount +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;

                    count++;
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"5\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ total +"</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No invoice items record found.";
        }
        
        return html;
    }
        
        public String printReceipt(){
            String html = "";
            
            html += this.getReportHeader();
            html += "<br>";
            html += this.getReportDetails();
            
            return html;
        }
    }
    
    RptReceipts rptReceipts = new RptReceipts();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Medical Receipts</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= rptReceipts.printReceipt() %>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
