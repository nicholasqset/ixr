<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="bean.gl.GLPL"%>
<%@page import="bean.gl.GLBS"%>
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
    final class PrintRptBS{
        
        Integer pYear   = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth  = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
    
        String rptName  = "";
        
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
                
                this.rptName  = "Balance Sheet<br>As of "+ targetFormat2.format(c.getTime());

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
            
//            html += "<br>";
            
            html += this.getPLDetails();
            
            return html;
        }
        
        public String getPLDetails(){
            String html = "";
            Sys sys = new Sys();
            
            GLPL gLPL = new GLPL();
            GLBS gLBS = new GLBS();
            
            Double cashEquiv        = gLBS.getCE(this.pYear, this.pMonth);
            Double ar               = gLBS.getAR(this.pYear, this.pMonth);
            Double inventory        = gLBS.getInv(this.pYear, this.pMonth);
            Double oca              = gLBS.getOCA(this.pYear, this.pMonth);
            
            Double ca               = cashEquiv + ar + inventory + oca;
            
            Double fa               = gLBS.getFA(this.pYear, this.pMonth);
            Double acmDep           = gLBS.getAcmDep(this.pYear, this.pMonth);
            
            Double netFa            = fa - acmDep;
            
            Double oa               = gLBS.getOA(this.pYear, this.pMonth);
            
            Double ta               = ca + netFa + oa;
            
            Double ap               = gLBS.getAP(this.pYear, this.pMonth);
            Double pfIT             = gLBS.getPfIT(this.pYear, this.pMonth);
            Double oCL              = gLBS.getOCL(this.pYear, this.pMonth);
            
            Double cl               = ap + pfIT + oCL;
            
            Double lTL              = gLBS.getLTL(this.pYear, this.pMonth);
            Double dividends        = gLBS.getDividends(this.pYear, this.pMonth);
            
            Double tl               = cl + lTL + dividends;
            
            Double sC               = gLBS.getSC(this.pYear, this.pMonth);
            Double sE               = gLBS.getSE(this.pYear, this.pMonth);
            
            Double pL               = gLPL.getPL(this.pYear, this.pMonth);
            
            Double tse              = sC + sE + pL;
            Double tlse             = tl + tse;
            
            if(system.recordExists("VIEWGLTB", "PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ "")){

                html += "<table style = \"width: 100%;\" class = \"header\" cellpadding = \"3\" cellspacing = \"0\">";
                
                html += "<tr>";
                html += "<td width = \"90%\">Cash And Equivalent</td>";
                html += "<td width = \"10%\" style = \"text-align: right;\">"+ system.numberFormat(cashEquiv.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Accounts Receivable</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(ar.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Inventory</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(inventory.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Other Current Assets</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(oca.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Total Current Assets</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(ca.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Fixed Assets</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(fa.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Less Accumulated Depreciation</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(acmDep.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Net Fixed Assets</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(netFa.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Other Assets</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(oa.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td class = \"bold\" style = \"padding-left: 15px;\">Total Assets</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(ta.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td class = \"o\">&nbsp;</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Accounts Payables</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(ap.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Provision for Income Taxes</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(pfIT.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Other Current Liabilities</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(oCL.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Total Current Liabilities</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(cl.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Long Term Liabilities</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(lTL.toString())+ "</td>";
                html += "</tr>";
    
                html += "<tr>";
                html += "<td>Dividends</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(dividends.toString())+ "</td>";
                html += "</tr>";
    
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Total Liabilities</td>";
                html += "<td style = \"font-weight: bold; text-align: right;\">"+ system.numberFormat(tl.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Share Capital</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(sC.toString())+ "</td>";
                html += "</tr>";
    
                html += "<tr>";
                html += "<td>Shareholder's Equity</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(sE.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Profit (Loss) for period</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(pL.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Total Shareholder's Equity</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ system.numberFormat(tse.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td class = \"bold\" style = \"padding-left: 15px;\">Total Liabilities and Shareholder's Equity</td>";
                html += "<td class = \"u\" style = \"font-weight: bold; text-align: right;\">"+ system.numberFormat(tlse.toString())+ "</td>";
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
    
    PrintRptBS printRptBS = new PrintRptBS();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Balance Sheet</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptBS.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
