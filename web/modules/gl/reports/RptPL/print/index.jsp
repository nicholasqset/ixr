<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="bean.gl.GLPL"%>
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
    final class PrintRptPL{
        
        
        Integer pYear   = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth  = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
    
        String rptName = "";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat2  = new SimpleDateFormat("MMMMM dd, yyyy");
                
//                Date convertedDate = originalFormat.parse(system.getLogDate());
                Date convertedDate = originalFormat.parse(this.pYear+ "-"+ this.pMonth+ "-"+ "01");
                Calendar c = Calendar.getInstance();
                c.setTime(convertedDate);
                c.set(Calendar.DAY_OF_MONTH, c.getActualMaximum(Calendar.DAY_OF_MONTH));
                
                String s = this.pMonth != null && this.pMonth > 1? "s": "";
                this.rptName  = "Income Statement<br>For the "+ this.pMonth+ " Period"+ s+ " Ending "+ targetFormat2.format(c.getTime());

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
                    html += "<td colspan = \"3\"  align = \"center\">"+ this.rptName+ "</td>";
                    html += "</tr>";

                    java.util.Date reportDate = originalFormat.parse(system.getLogDate());
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
            
            html += this.getPLDetails();
            
            return html;
        }
        
        public String getPLDetails(){
            String html = "";
            Sys sys = new Sys();
            
            GLPL gLPL = new GLPL();
            
            Double revenue          = gLPL.getRevenue(this.pYear, this.pMonth);
            Double cos              = gLPL.getCOS(this.pYear, this.pMonth);
            Double gp               = revenue - cos;
            Double otherRev         = gLPL.getOtherRev(this.pYear, this.pMonth);
            Double fixedCharges     = gLPL.getFixedCharges(this.pYear, this.pMonth);
            Double otherExpenses    = gLPL.getOtherExpenses(this.pYear, this.pMonth);
            Double depExpense       = gLPL.getDepExpense(this.pYear, this.pMonth);
            Double elfo             = gp + otherRev - fixedCharges - otherExpenses - depExpense;
            Double intExpense       = gLPL.getIntExpense(this.pYear, this.pMonth);
            Double elbt             = elfo - intExpense;
            Double incTaxes         = gLPL.getIncomeTaxes(this.pYear, this.pMonth);
            
//            Double netIncome        = elbt - incTaxes;
            Double netIncome        = gLPL.getPL(this.pYear, this.pMonth);

            if(system.recordExists("VIEWGLTB", "PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ "")){

                html += "<table style = \"width: 100%;\" class = \"header\" cellpadding = \"3\" cellspacing = \"0\">";
                
                html += "<tr>";
                html += "<td width = \"90%\">Revenue</td>";
                html += "<td width = \"10%\" style = \"text-align: right;\">"+ system.numberFormat(revenue.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Cost of Sales</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(cos.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Gross Profit</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(gp.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Other Revenue</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(otherRev.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Other Expenses</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(otherExpenses.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Fixed Charges</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(fixedCharges.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Other</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(depExpense.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td class = \"bold\" style = \"padding-left: 15px;\">Earning (Loss) From Operation</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(elfo.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Interest Expense</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(intExpense.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td class = \"bold\" style = \"padding-left: 15px;\">Earning (Loss) Before Tax</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(elbt.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Income Taxes</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(incTaxes.toString())+ "</td>";
                html += "</tr>";
    
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td class = \"bold\" style = \"padding-left: 15px;\">Net Income (Loss)</td>";
                html += "<td class = \"u\" style = \"font-weight: bold; text-align: right;\">"+ system.numberFormat(netIncome.toString())+ "</td>";
                html += "</tr>";
    
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td class = \"o\">&nbsp;</td>";
                html += "</tr>";
    
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
    
    PrintRptPL printRptPL = new PrintRptPL();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Profit & Loss</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptPL.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
            
       </script>
    </body>
</html>
