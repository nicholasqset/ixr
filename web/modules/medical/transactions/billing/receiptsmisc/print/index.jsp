<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.medical.MedMiscRcptHeader"%>
<%@page import="com.qset.commonsrv.Company"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.sys.Sys"%>
<%
    final class RptReceipts{
        HttpSession session = request.getSession();
        String comCode      = session.getAttribute("comCode").toString();
        public String rcptmNo = request.getParameter("miscReceiptNo");
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
//            String companyCode = sys.getOne("CSCOPROFILE", "COMPANYCODE", "");
            if(this.comCode != null){
                
                Company company = new Company(this.comCode);
                
                String imgLogoSrc;
                
                if(sys.getOne("CSCOLOGO", "LOGO", "COMPANYCODE = '"+ this.comCode +"'") != null){
                    imgLogoSrc = "logo.jsp?code="+this.comCode;
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
                html += "<td colspan = \"3\"  align = \"center\">Medical Miscellaneous Receipt</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>"+ sys.getLogDate() +"</td>";
                html += "</tr>";

                html += "</table>";
            }else{
                html += "Company details not defined.";
            }
            
            return html;
        }
        
        public String getReportDetails(){
            String html = "";
            
            MedMiscRcptHeader medMiscRcptHeader = new MedMiscRcptHeader(this.rcptmNo, this.comCode);
                
            html += "<table width = \"100%\" cellpadding = \"1\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\">Receipt No</td>";
            html += "<td>"+ this.rcptmNo +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Date</td>";
            html += "<td>"+ medMiscRcptHeader.rcptmDate +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Payment Mode</td>";
            html += "<td>"+ medMiscRcptHeader.pmName +"</td>";
            html += "</tr>";

            html += "</table>";
                
//            }else{
//                html += "Receipt invoice details not found.";
//            }
            
            html += "<br>";
            
            html += this.getMiscReceiptDtls(this.rcptmNo);
            
            return html;
        }
        
        public String getMiscReceiptDtls(String rcptmNo){
        String html = "";
        
        Sys sys = new Sys();
        
        if(sys.recordExists(""+this.comCode+".VIEWHMMISCRCPTSDTLS", "RCPTMNO = '"+ rcptmNo +"'")){
            
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
                
                String query = "SELECT * FROM "+this.comCode+".VIEWHMMISCRCPTSDTLS WHERE RCPTMNO = '"+ rcptmNo +"'";
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
