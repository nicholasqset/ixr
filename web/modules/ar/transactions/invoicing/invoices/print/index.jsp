<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="bean.ic.ICItem"%>
<%@page import="bean.ar.ARDistribution"%>
<%@page import="bean.ar.ARInHdr"%>
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
    final class PrintRptReceipt{
        HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
//        Integer batchNo     = request.getParameter("batchNo") != null && ! request.getParameter("batchNo").trim().equals("")? Integer.parseInt(request.getParameter("batchNo")): null;
        String inNo         = request.getParameter("invoiceNo") != null && ! request.getParameter("invoiceNo").trim().equals("")? request.getParameter("invoiceNo"): null;
    
        String rptName  = "Invoice";
        
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
                        imgLogoSrc = request.getContextPath()+"/images/logo/default-logo.png";
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
            
            ARInHdr aRInHdr = new ARInHdr(inNo, comCode);
            
            String entryDateLbl = "";
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

                java.util.Date entryDate = originalFormat.parse(aRInHdr.entryDate);
                entryDateLbl = targetFormat.format(entryDate);
            }catch(Exception e){
                html += e.getMessage();
            }
            
            
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\">Receipt No</td>";
            html += "<td>"+ this.inNo +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Description</td>";
            html += "<td>"+ aRInHdr.inDesc+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Receipt Date</td>";
            html += "<td>"+ entryDateLbl+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Period</td>";
            html += "<td>"+ aRInHdr.pYear+ " - "+ aRInHdr.pMonth+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Customer</td>";
//            html += "<td>"+ aRInHdr.fullName+ "</td>";
            html += "<td>"+ aRInHdr.customerName+ "</td>";
            html += "</tr>";

//            html += "<tr>";
//            html += "<td class = \"bold\">Payment Mode</td>";
//            html += "<td>"+ aRInHdr.pmName+ "</td>";
//            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getReceiptDtls();
            
            return html;
        }
        
        public String getReceiptDtls(){
            String html = "";
            Sys sys = new Sys();

            if(sys.recordExists(comCode+".VIEWARINDTLS", "INNO = '"+ this.inNo+ "'")){

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Item No</th>";
                html += "<th>Description</th>";
                html += "<th style = \"text-align: right;\">Quantity</th>";
                html += "<th style = \"text-align: right;\">Unit Price</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                html += "</tr>";

                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    query = "SELECT * FROM "+comCode+".VIEWARINDTLS WHERE INNO = '"+ this.inNo+ "' ORDER BY ITEMDTBCODE";

                    ResultSet rs = stmt.executeQuery(query);

                    Integer count  = 1;
                    
                    Double aplAmtTotal = 0.0;

                    while(rs.next()){
                        String entryType    = rs.getString("ENTRYTYPE");
                        String itemDtbCode           = rs.getString("ITEMDTBCODE");
//                        Double itemDesc         = rs.getDouble("APLAMOUNT");
                        Double qty              = rs.getDouble("QTY");
                        Double unitPrice        = rs.getDouble("UNITPRICE");
                        Double amount           = rs.getDouble("AMOUNT");
                        
                        String itemName;
                    
                        if(entryType.equals("S")){
                            ARDistribution aRDistribution = new ARDistribution(itemDtbCode, comCode);
                            itemName = aRDistribution.dtbName;
                        }else{
                            ICItem iCItem = new ICItem(itemDtbCode, comCode);
                            itemName = iCItem.itemName;
                        }

                        html += "<tr>";
                        html += "<td>"+ count+ "</td>";
                        html += "<td>"+ itemDtbCode+ "</td>";
                        html += "<td>"+ itemName+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(qty.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(unitPrice.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(amount.toString())+ "</td>";
                        html += "</tr>";
                        
                        aplAmtTotal = aplAmtTotal + amount;

                        count++;
                    }
                    
                    html += "<tr>";
                    html += "<td colspan = \"5\" style = \"text-align: center; font-weight: bold;\">Total</td>";
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
        <title>Invoice</title>
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
