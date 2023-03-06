<%@page import="bean.po.PoPyHdr"%>
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
        String pyNo     = request.getParameter("pyNo") != null && ! request.getParameter("pyNo").trim().equals("")? request.getParameter("pyNo"): null;
    
        String rptName  = "Goods Received Note(GRN)";
        
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
            
            PoPyHdr poPyHdr = new PoPyHdr(pyNo, comCode);
            
            String entryDateLbl = "";
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

                java.util.Date entryDate = originalFormat.parse(poPyHdr.entryDate);
                entryDateLbl = targetFormat.format(entryDate);
            }catch(Exception e){
                html += e.getMessage();
            }
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\">PO No</td>";
            html += "<td>"+ this.pyNo +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Description</td>";
            html += "<td>"+ poPyHdr.pyDesc+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">PO Date</td>";
            html += "<td>"+ entryDateLbl+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Period</td>";
            html += "<td>"+ poPyHdr.pYear+ " - "+ poPyHdr.pMonth+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Supplier</td>";
            html += "<td>"+ poPyHdr.supplierName+ "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getPODtls();
            
            return html;
        }
        
        public String getPODtls(){
            String html = "";
            Sys sys = new Sys();

            if(sys.recordExists(comCode+".VIEWPOPYDTLS", "PYNO = '"+ this.pyNo+ "'")){

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

               html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Item</th>";
                html += "<th style = \"text-align: right;\">Quantity</th>";
                html += "<th style = \"text-align: right;\">Cost</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                html += "<th style = \"text-align: right;\">Tax</th>";
                html += "<th style = \"text-align: right;\">PO Total</th>";
                html += "<th style = \"text-align: center;\">Tax Incl.</th>";
                html += "</tr>";
            
                Double sumAmount    = 0.0;
                Double sumTax       = 0.0;
                Double sumTotal     = 0.0;

                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    query = "SELECT * FROM "+comCode+".VIEWPOPYDTLS WHERE PYNO = '"+ this.pyNo+ "' ORDER BY ITEMCODE";

                    ResultSet rs = stmt.executeQuery(query);

                    Integer count  = 1;
                    
                    while(rs.next()){
                        Integer id          = rs.getInt("ID");
                        String itemName     = rs.getString("ITEMNAME");
                        Double qty          = rs.getDouble("QTY");
                        Double unitCost     = rs.getDouble("UNITCOST");
                        Double taxAmount    = rs.getDouble("TAXAMOUNT");
                        Double amount       = rs.getDouble("AMOUNT");
                        Double total        = rs.getDouble("TOTAL");
                        Integer taxIncl     = rs.getInt("TAXINCL");

                        String taxInclLbl   = taxIncl == 1? "Yes": "No";

                        html += "<tr>";
                        html += "<td>"+ count +"</td>";
                        html += "<td>"+ itemName +"</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(qty.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(unitCost.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(amount.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(taxAmount.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(total.toString()) +"</td>";
                        html += "<td style = \"text-align: center;\">"+ taxInclLbl+"</td>";
                        html += "</tr>";

                        sumAmount   = sumAmount + amount;
                        sumTax      = sumTax + taxAmount;
                        sumTotal    = sumTotal + total;

                        count++;
                    }
                    
                    html += "<tr>";
                    html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"4\">Total</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumAmount.toString()) +"</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumTax.toString()) +"</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumTotal.toString()) +"</td>";
                    html += "<td colspan = \"2\">&nbsp;</td>";
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
        <title>Purchase Order</title>
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
