<%@page import="bean.pos.PsPyHdr"%>
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
        HttpSession session = request.getSession();
        String comCode      = session.getAttribute("comCode").toString();
        
        String pyNo     = request.getParameter("receiptNo") != null && ! request.getParameter("receiptNo").trim().equals("")? request.getParameter("receiptNo"): null;
    
        String rptName  = "Fiscal Receipt";
        
        public String getReportHeader(){
            String html = "";
            Sys system = new Sys();
            
            try{
//                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy HH:mm");
                
//                String companyCode = system.getOne("sys.coms", "COMCODE", "");

                if(comCode != null){

                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if(system.getOne(comCode+".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+comCode;
                    }else{
                        imgLogoSrc = request.getContextPath()+"/assets/img/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\">";

                    html += "<tr>";
//                    html += "<td colspan = \"4\" style = \"text-align: center; font-weight: bold;\">"+ company.companyName +"</td>";
//                    html += "<td colspan = \"4\" style = \"font-weight: bold;\">"+ company.companyName +"</td>";
                    html += "<td style = \"font-weight: bold; text-align: center;\">"+ company.compName +"</td>";
                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td width = \"33%\">&nbsp;</td>";
//                    html += "<td rowspan = \"5\" align = \"center\"><img id = \"imgLogo\" height = \"128\" width = \"128\" src=\""+ imgLogoSrc +"\"></td>";
//                    html += "<td width = \"33%\">&nbsp;</td>";
//                    html += "</tr>";

                    html += "<tr>";
                    html += "<td style = \"text-align: center;\">"+ company.physicalAdr +"</td>";
                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td style = \"text-align: center;\">"+ company.postalAdr +" - "+ company.postalCode +"</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>"+ company.email +"</td>";
//                    html += "</tr>";
//
//                    html += "<tr>";
//                    html += "<td>"+ company.website +"</td>";
//                    html += "</tr>";

                    html += "<tr>";
//                    html += "<td>"+ company.telephone +"</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td style = \"text-align: center;\">"+ company.cellphone +"</td>";
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
                    
//                    java.util.Date now = new java.util.Date();
//
//                    String reportDateLbl = targetFormat.format(now);

//                    html += "<tr>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>"+ reportDateLbl+ "</td>";
//                    html += "</tr>";

                    html += "</table>";
                    
                    //                    html += "<tr>";
//                    html += "<td colspan = \"3\"  align = \"center\">"+ this.rptName+ "</td>";
//                    html += "<td>"+ this.rptName+ "</td>";
//                    html += "</tr>";
                
                    html += "<div style = \"width: 100%; padding: 7px; border-top: 1px solid #000; border-bottom: 1px solid #000; text-align:center;\">"+ this.rptName+ "</div>";

                }else{
                    html += "Company details not defined.";
                }
                
            }catch (Exception e){
                html += e.getMessage();
            }
            
            return html;
        }
        
        public String getReportHeaderx(){
            String html = "";
            Sys system = new Sys();
            
            try{
//                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy HH:mm");
                
                String companyCode = system.getOne(this.comCode+".CSCOPROFILE", "COMPANYCODE", "");

                if(companyCode != null){

                    Company company = new Company(companyCode);

                    String imgLogoSrc;

                    if(system.getOne(this.comCode+".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ companyCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+companyCode;
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
                    
//                    Calendar calendar = Calendar.getInstance();
//                    SimpleDateFormat dateFormat     = new SimpleDateFormat("yyyy-MM-dd hh:mm");
        
//                    String dateNow  =  dateFormat.format(calendar.getTime());
                    
                    java.util.Date now = new java.util.Date();

//                    java.util.Date reportDate = originalFormat.parse(system.getLogDate());
//                    java.util.Date reportDate = originalFormat.parse(dateNow);
                    String reportDateLbl = targetFormat.format(now);

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
            
            Sys system = new Sys();
            
            PsPyHdr psPyHdr = new PsPyHdr(pyNo, this.comCode);
            
            String entryDateLbl = "";
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

                java.util.Date entryDate = originalFormat.parse(psPyHdr.entryDate);
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
            html += "<td>"+ psPyHdr.pyDesc+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Receipt Date</td>";
            html += "<td>"+ entryDateLbl+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Period</td>";
            html += "<td>"+ psPyHdr.pYear+ " - "+ psPyHdr.pMonth+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Customer</td>";
            html += "<td>"+ psPyHdr.fullName+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Tendered</td>";
            html += "<td>"+ system.numberFormat(psPyHdr.tender.toString())+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Change</td>";
            html += "<td>"+ system.numberFormat(psPyHdr.change.toString())+ "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getPyDtls();
            
            return html;
        }
        
        public String getPyDtls(){
            String html = "";
            Sys system = new Sys();

            if(system.recordExists(this.comCode+".VIEWPSPYDTLS", "PYNO = '"+ this.pyNo+ "'")){

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

               html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Item</th>";
                html += "<th style = \"text-align: right;\">Quantity</th>";
                html += "<th style = \"text-align: right;\">Price</th>";
                html += "<th style = \"text-align: right;\">Tax</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                
//                html += "<th style = \"text-align: right;\">Receipt Total</th>";
//                html += "<th style = \"text-align: center;\">Tax Incl.</th>";
                html += "</tr>";
            
                Double sumAmount    = 0.0;
                Double sumTax       = 0.0;
                Double sumTotal     = 0.0;

                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    query = "SELECT * FROM "+this.comCode+".VIEWPSPYDTLS WHERE PYNO = '"+ this.pyNo+ "' ORDER BY ITEMCODE";

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

//                        String taxInclLbl   = taxIncl == 1? "Yes": "No";
                        
                        Double taxAmountAlt = taxIncl == 1? taxAmount: 0;

                        html += "<tr>";
                        html += "<td>"+ count +"</td>";
                        html += "<td>"+ itemName +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(qty.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(unitPrice.toString()) +"</td>";
//                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(taxAmount.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(taxAmountAlt.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(amount.toString()) +"</td>";
                        
//                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(total.toString()) +"</td>";
//                        html += "<td style = \"text-align: center;\">"+ taxInclLbl+"</td>";
                        html += "</tr>";

                        sumAmount   = sumAmount + amount;
//                        sumTax      = sumTax + taxAmount;
                        sumTax      = sumTax + taxAmountAlt;
                        sumTotal    = sumTotal + total;

                        count++;
                    }
                    
                    html += "<tr>";
                    html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"4\">Total</td>";
                    
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumTax.toString()) +"</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumAmount.toString()) +"</td>";
//                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumTotal.toString()) +"</td>";
//                    html += "<td colspan = \"2\">&nbsp;</td>";
                    html += "</tr>";
                    
                    html += "<table>";
                    
                    html += "<tr>";
                    html += "<td style = \"text-align: left; font-weight: bold;\" colspan = \"\">Till No:</td>";
                    html += "<td style = \"text-align: left; font-weight: bold;\" colspan = \"5\">510 6387</td>";
                    
                    html += "</table>";
                    
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
        <title>Fiscal Receipt</title>
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