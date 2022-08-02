<%@page import="bean.restaurant.RtPyHdr"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.commonsrv.Company"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.sys.Sys"%>
<%
    final class PrintRptInvoice{
        
        String pyNo     = request.getParameter("invoiceNo") != null && ! request.getParameter("invoiceNo").trim().equals("")? request.getParameter("invoiceNo"): null;
    
        String rptName  = "Invoice/Order";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
//                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy HH:mm");
                
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
//                    html += "<td colspan = \"4\" style = \"text-align: center; font-weight: bold;\">"+ company.companyName +"</td>";
//                    html += "<td colspan = \"4\" style = \"font-weight: bold;\">"+ company.companyName +"</td>";
                    html += "<td style = \"font-weight: bold;\">"+ company.companyName +"</td>";
                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td width = \"33%\">&nbsp;</td>";
//                    html += "<td rowspan = \"5\" align = \"center\"><img id = \"imgLogo\" height = \"128\" width = \"128\" src=\""+ imgLogoSrc +"\"></td>";
//                    html += "<td width = \"33%\">&nbsp;</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>"+ company.postalAdr +" - "+ company.postalCode +"</td>";
//                    html += "</tr>";
//
//                    html += "<tr>";
//                    html += "<td>"+ company.email +"</td>";
//                    html += "</tr>";
//
//                    html += "<tr>";
//                    html += "<td>"+ company.website +"</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>"+ company.telephone +"</td>";
//                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>"+ company.cellphone +"</td>";
                    html += "</tr>";
                     
//                    html += "Mobile : "+ company.cellphone +" ";
//                    html += "";
                    
//                    html += "<td width = \"33%\">";
//                    html += "</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>&nbsp;</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>&nbsp;</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>&nbsp;</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td colspan = \"3\"  align = \"center\">"+ this.rptName+ "</td>";
//                    html += "<td>"+ this.rptName+ "</td>";
//                    html += "</tr>";
                    
                    java.util.Date now = new java.util.Date();

                    String reportDateLbl = targetFormat.format(now);

                    html += "<tr>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>&nbsp;</td>";
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
            
//            Sys sys = new Sys();
            
            RtPyHdr rtPyHdr = new RtPyHdr(this.pyNo);
            
            String entryDateLbl = "";
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

                java.util.Date entryDate = originalFormat.parse(rtPyHdr.entryDate);
                entryDateLbl = targetFormat.format(entryDate);
            }catch(Exception e){
                html += e.getMessage();
            }
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\" nowrap>Invoice/Order No</td>";
            html += "<td>"+ this.pyNo +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Description</td>";
            html += "<td>"+ rtPyHdr.pyDesc+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>Invoice/Order Date</td>";
            html += "<td>"+ entryDateLbl+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Period</td>";
            html += "<td>"+ rtPyHdr.pYear+ " - "+ rtPyHdr.pMonth+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Customer</td>";
            html += "<td>"+ rtPyHdr.fullName+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Waiter</td>";
            html += "<td>"+ rtPyHdr.auditUser+ " - "+ rtPyHdr.userName+ "</td>";
            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Change</td>";
//            html += "<td>"+ system.numberFormat(rtPyHdr.change.toString())+ "</td>";
//            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getPyDtls();
            
            return html;
        }
        
        public String getPyDtls(){
            String html = "";
            Sys sys = new Sys();

            if(system.recordExists("VIEWRTPYDTLS", "PYNO = '"+ this.pyNo+ "'")){

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

               html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Item</th>";
                html += "<th style = \"text-align: right;\">Quantity</th>";
                html += "<th style = \"text-align: right;\">Price</th>";
//                html += "<th style = \"text-align: right;\">Tax</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                
                html += "</tr>";
            
                Double sumAmount    = 0.0;
                Double sumTax       = 0.0;
                Double sumTotal     = 0.0;

                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    query = "SELECT * FROM VIEWRTPYDTLS WHERE PYNO = '"+ this.pyNo+ "' ORDER BY ITEMCODE";

                    ResultSet rs = stmt.executeQuery(query);

                    Integer count  = 1;
                    
                    while(rs.next()){
                        Integer id          = rs.getInt("ID");
                        String itemName     = rs.getString("ITEMNAME");
                        Double qty          = rs.getDouble("QTY");
                        Double unitPrice    = rs.getDouble("UNITPRICE");
                        Double taxAmount    = rs.getDouble("TAXAMOUNT");
                        Double amount       = rs.getDouble("AMOUNT");
                        Double total        = rs.getDouble("TOTAL");
                        Integer taxIncl     = rs.getInt("TAXINCL");

                        Double taxAmountAlt = taxIncl == 1? taxAmount: 0;

                        html += "<tr>";
                        html += "<td>"+ count +"</td>";
                        html += "<td>"+ itemName +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(qty.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(unitPrice.toString()) +"</td>";
//                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(taxAmountAlt.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(amount.toString()) +"</td>";
                        
                        html += "</tr>";

                        sumAmount   = sumAmount + amount;
                        sumTax      = sumTax + taxAmountAlt;
                        sumTotal    = sumTotal + total;

                        count++;
                    }
                    
                    html += "<tr>";
                    html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"4\">Total</td>";
                    
//                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumTax.toString()) +"</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumAmount.toString()) +"</td>";
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
        
        public String getReportFooter(){
            String html = "";
            
            html += "<table style = \"width: 100%;\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<td style = \"font-size: 8px; text-align: center;\">Powered by: <span style = \"font-style: italic;\">http://www.qset.co.ke; 0725999504</span></td>";
            html += "</tr>";
            
            html += "</table>";
            
            return html;
        }
        
        public String printRpt(){
            String html = "";
            
            html += this.getReportHeader();
            html += "<br>";
            html += this.getReportDetails();
            html += "<br>";
            html += this.getReportFooter();
            
            return html;
        }
    }
    
    PrintRptInvoice printRptInvoice = new PrintRptInvoice();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Invoice/Order</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptInvoice.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '1500');
            });
       </script>
    </body>
</html>