<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="com.qset.gl.GLPL"%>
<%@page import="com.qset.gl.GLBS"%>
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
    final class PrintRptBS{
        
        HttpSession session = request.getSession();
        String comCode      = session.getAttribute("comCode").toString();
        
        Integer pYear   = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth  = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
        Integer cuml    = (request.getParameter("cuml") != null && request.getParameter("cuml").trim().equals("on"))? 1: 0;
        
        String rptName  = "";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat2  = new SimpleDateFormat("MMMMM dd, yyyy");
                
                Date convertedDate = originalFormat.parse(this.pYear+ "-"+ this.pMonth+ "-"+ "01");
                Calendar c = Calendar.getInstance();
                c.setTime(convertedDate);
                c.set(Calendar.DAY_OF_MONTH, c.getActualMaximum(Calendar.DAY_OF_MONTH));
                
                this.rptName  = "Balance Sheet<br>As of "+ targetFormat2.format(c.getTime());

                if(comCode != null){

                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if(sys.getOne(comCode+ ".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
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
            
//            html += "<br>";
            
            html += this.getPLDetails();
            
            return html;
        }
        
        public String getPLDetails(){
            String html = "";
            Sys sys = new Sys();
            
            GLPL gLPL = new GLPL(comCode, this.pYear, this.pMonth, this.cuml);
            GLBS gLBS = new GLBS(comCode, this.pYear, this.pMonth, this.cuml);
            
            Double cashEquiv        = gLBS.getCE();
            Double ar               = gLBS.getAR();
            Double inventory        = gLBS.getInv();
            Double oca              = gLBS.getOCA();
            
            Double ca               = cashEquiv + ar + inventory + oca;
            
            Double fa               = gLBS.getFA();
            Double acmDep           = gLBS.getAcmDep();
            
            Double netFa            = fa - acmDep;
            
            Double oa               = gLBS.getOA();
            
            Double ta               = ca + netFa + oa;
            
            Double ap               = gLBS.getAP();
            Double pfIT             = gLBS.getPfIT();
            Double oCL              = gLBS.getOCL();
            
            Double cl               = ap + pfIT + oCL;
            
            Double lTL              = gLBS.getLTL();
            Double dividends        = gLBS.getDividends();
            
            Double tl               = cl + lTL + dividends;
            
            Double sC               = gLBS.getSC();
            Double sE               = gLBS.getSE();
            
            Double pL               = gLPL.getPL();
            
            Double tse              = sC + sE + pL;
            Double tlse             = tl + tse;
            
//            if(sys.recordExists(comCode+".VIEWGLTB", "PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ "")){

                html += "<table style = \"width: 100%;\" class = \"header\" cellpadding = \"3\" cellspacing = \"0\">";
                
                html += "<tr>";
                html += "<td width = \"90%\">Cash And Equivalent</td>";
                html += "<td width = \"10%\" style = \"text-align: right;\">"+ sys.numberFormat(cashEquiv.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Accounts Receivable</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(ar.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Inventory</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(inventory.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Other Current Assets</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ sys.numberFormat(oca.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Total Current Assets</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(ca.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Fixed Assets</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(fa.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Less Accumulated Depreciation</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ sys.numberFormat(acmDep.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Net Fixed Assets</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(netFa.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Other Assets</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ sys.numberFormat(oa.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td class = \"bold\" style = \"padding-left: 15px;\">Total Assets</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ sys.numberFormat(ta.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td class = \"o\">&nbsp;</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Accounts Payables</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(ap.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Provision for Income Taxes</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(pfIT.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Other Current Liabilities</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ sys.numberFormat(oCL.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Total Current Liabilities</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(cl.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Long Term Liabilities</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(lTL.toString())+ "</td>";
                html += "</tr>";
    
                html += "<tr>";
                html += "<td>Dividends</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ sys.numberFormat(dividends.toString())+ "</td>";
                html += "</tr>";
    
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Total Liabilities</td>";
                html += "<td style = \"font-weight: bold; text-align: right;\">"+ sys.numberFormat(tl.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Share Capital</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(sC.toString())+ "</td>";
                html += "</tr>";
    
                html += "<tr>";
                html += "<td>Shareholder's Equity</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(sE.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Profit (Loss) for period</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ sys.numberFormat(pL.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td style = \"padding-left: 15px;\">Total Shareholder's Equity</td>";
                html += "<td class = \"u\" style = \"text-align: right;\">"+ sys.numberFormat(tse.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr bgcolor = \"#F7F7F7\">";
                html += "<td class = \"bold\" style = \"padding-left: 15px;\">Total Liabilities and Shareholder's Equity</td>";
                html += "<td class = \"u\" style = \"font-weight: bold; text-align: right;\">"+ sys.numberFormat(tlse.toString())+ "</td>";
                html += "</tr>";
    
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td class = \"o\">&nbsp;</td>";
                html += "</tr>";
    
                html += "</table>";
//            }else{
//                html += "No record found.";
//            }
        
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
