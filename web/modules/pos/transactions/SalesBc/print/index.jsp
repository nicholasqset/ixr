<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.pos.PsPyHdr"%>
<%@page import="com.qset.commonsrv.Company"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%
    final class PrintRptInvoice{
        HttpSession session = request.getSession();
        String comCode      = session.getAttribute("comCode").toString();
        
        String pyNo     = request.getParameter("receiptNo") != null && ! request.getParameter("receiptNo").trim().equals("")? request.getParameter("receiptNo"): null;
    
        String rptName  = "Official Receipt";
        
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

                    html += "<tr>";
                    html += "<td style = \"text-align: center;\">"+ company.postalAdr +" - "+ company.postalCode +"</td>";
                    html += "</tr>";

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
        
        public String getReportDetails(){
            String html = "";
            
            Sys system = new Sys();
            
            PsPyHdr psPyHdr = new PsPyHdr(this.pyNo, comCode);
            
            String entryDateLbl = "";
            String tillNoLbl = psPyHdr.tillNo == null? "": psPyHdr.tillNo;
            
            String formattedDate = null;
            
            try{
//                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd ");
//                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
//                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss.SSS");
                
//                Date date = parser.parse(input);

                java.util.Date entryDate = originalFormat.parse(psPyHdr.entryDate);
                entryDateLbl = targetFormat.format(entryDate);
                
//                String input = "Thu Jun 18 20:56:02 EDT 2009";
//                String input = psPyHdr.entryDate;
////                SimpleDateFormat parser = new SimpleDateFormat("EEE MMM d HH:mm:ss zzz yyyy");
//                SimpleDateFormat parser = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
//                Date date = parser.parse(input);
//                SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
//                formattedDate = formatter.format(date);
            }catch(Exception e){
                html += e.getMessage();
            }
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\" nowrap>Receipt #</td>";
            html += "<td>"+ this.pyNo +"</td>";
            html += "</tr>";

//            html += "<tr>";
//            html += "<td class = \"bold\">Description</td>";
//            html += "<td>"+ psPyHdr.pyDesc+ "</td>";
//            html += "</tr>";

    

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>Date</td>";
//            html += "<td>"+ system.getLogDate()+ "</td>";
            html += "<td>"+ entryDateLbl+ "</td>";
//            html += "<td>"+ formattedDate+ "</td>";
            html += "</tr>";

//            html += "<tr>";
//            html += "<td class = \"bold\">Period</td>";
//            html += "<td>"+ psPyHdr.pYear+ " - "+ psPyHdr.pMonth+ "</td>";
//            html += "</tr>";

//            html += "<tr>";
//            html += "<td class = \"bold\">Customer</td>";
//            html += "<td>"+ psPyHdr.fullName+ "</td>";
//            html += "</tr>";

//            html += "<tr>";
//            html += "<td class = \"bold\">Till #</td>";
//            html += "<td>"+ tillNoLbl+ "</td>";
//            html += "</tr>";
//
            html += "<tr>";
            html += "<td class = \"bold\">Tendered</td>";
            html += "<td>"+ system.numberFormat(psPyHdr.tender.toString())+ "</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td class = \"bold\">Change</td>";
            html += "<td>"+ system.numberFormat(psPyHdr.change.toString())+ "</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td class = \"bold\">Served By:</td>";
//            html += "<td>"+ psPyHdr.auditUser+ " - "+ psPyHdr.userName+ "</td>";
            html += "<td>"+ psPyHdr.userName+ "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getPyDtls();
            
            return html;
        }
        
        public String getPyDtls(){
            String html = "";
            Sys system = new Sys();

            if(system.recordExists(comCode+".VIEWPSPYDTLS", "PYNO = '"+ this.pyNo+ "'")){

                html += "<table style = \"width: 100%;\" class = \"header\" cellpadding = \"2\" cellspacing = \"0\">";

               html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Item</th>";
//                html += "<th>Attribute</th>";
//                html += "<th style = \"text-align: right;\">Quantity</th>";
//                html += "<th style = \"text-align: right;\">Price</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                
                html += "</tr>";
            
                Double sumAmount    = 0.0;
                Double sumTax       = 0.0;
                Double sumTotal     = 0.0;
                Double sumDiscount  = 0.0;

                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    query = "SELECT * FROM "+comCode+".VIEWPSPYDTLS WHERE PYNO = '"+ this.pyNo+ "' ORDER BY ITEMCODE";
                    
//                    html += query;

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
                        Double discount     = rs.getDouble("DISCOUNT");
                        
//                        String dOptFld4     = rs.getString("DOPTFLD4");
//                        dOptFld4 = dOptFld4 == null? "": dOptFld4;
                        Double taxAmountAlt = taxIncl == 1? taxAmount: 0;

                        html += "<tr>";
                        html += "<td>"+ count +"</td>";
                        html += "<td>"+ itemName +"</td>";
//                        html += "<td>"+ dOptFld4+ "</td>";
//                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(qty.toString()) +"</td>";
//                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(unitPrice.toString()) +"</td>";                        
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(amount.toString()) +"</td>";
                        
                        html += "</tr>";

                        sumAmount   = sumAmount + amount;
                        sumTax      = sumTax + taxAmountAlt;
                        sumTotal    = sumTotal + total;
                        sumDiscount = sumDiscount + discount;

                        count++;
                    }
                    
                    html += "<tr>";
                    html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"2\">Total</td>";
                    
//                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumTax.toString()) +"</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumAmount.toString()) +"</td>";
                    html += "</tr>";
                    
                    html += "<tr>";
                    html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"2\">Total Discount</td>";
                    
//                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumTax.toString()) +"</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumDiscount.toString()) +"</td>";
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
            html += "<td style = \"font-size: 8px; text-align: center;\">Powered by: <span style = \"font-style: italic;\">http://www.qset.co.ke</span></td>";
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
        
        public String markBilled(){
            String html = "";
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "UPDATE "+comCode+".PSPYHDR SET "
                                        + "OPTFLD3      = '"+ this.pyNo+ "' "
                                        + "WHERE PYNO   = '"+ this.pyNo+ "'";
                
//                html += query;
                
//                stmt.executeUpdate(query);
            }catch(Exception e){
                html = e.getMessage();
            }
            
            return html;
        }
    }
    
    PrintRptInvoice printRptInvoice = new PrintRptInvoice();
    out.print(printRptInvoice.markBilled());
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Receipt</title>
        <!--<link rel="stylesheet" href="../css/reports.css">-->
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptInvoice.printRpt()%>
        
        <script language="javascript">
            setTimeout('window.print();', '1000');
//            window.location.replace('../');
       </script>
       <%
//        response.sendRedirect("../?act=logout");
        %>
    </body>
</html>