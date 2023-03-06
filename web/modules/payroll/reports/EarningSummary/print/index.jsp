<%@page import="bean.payroll.PyConfig"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="bean.hr.StaffProfile"%>
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
    final class PrintRptEarningSmr{
        HttpSession session = request.getSession();
        String comCode       = session.getAttribute("comCode").toString();
        
        Integer pYear   = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth  = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
        
        String rptName  = "Earning Summary";
        
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

                    if(sys.getOne("CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
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
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"20%\" class = \"bold\">Payroll Year</td>";
            html += "<td>"+ this.pYear+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Payroll Month</td>";
            html += "<td>"+ this.pMonth+ "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getEarningSummary();
            
            return html;
        }
        
        public String getEarningSummary(){
            String html = "";

            Sys sys = new Sys();
            
            if(sys.recordExists(comCode+ ".VIEWPYSLIP", "PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND HDRTYPE = 'EN'")){
                
                PyConfig pyConfig = new PyConfig(comCode);

                html += "<table width = \"100%\" class = \"header\" cellpadding = \"2\" cellspacing = \"0\" >";

                html += "<tr>";
                html += "<th width = \"12.5%\" nowrap>Staff No</th>";
                html += "<th width = \"12.5%\" nowrap>Name</th>";
                html += "<th width = \"12.5%\" style = \"text-align: right;\" nowrap>Basic Pay</th>";
                html += "<th width = \"12.5%\" style = \"text-align: right;\" nowrap>House Allowance</th>";
                html += "<th width = \"12.5%\" style = \"text-align: right;\" nowrap>Commuter Allowance</th>";
                html += "<th width = \"12.5%\" style = \"text-align: right;\" nowrap>Car Allowance</th>";
                html += "<th width = \"12.5%\" style = \"text-align: right;\" nowrap>Other</th>";
                html += "<th style = \"text-align: right;\" nowrap>Gross Pay</th>";
                html += "</tr>";
                
                Double bpTotal = 0.0;
                Double hsTotal = 0.0;
                Double cmTotal = 0.0;
                Double crTotal = 0.0;
                Double otTotal = 0.0;
                Double gpTotal = 0.0;
                
                try{                    
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "SELECT DISTINCT PFNO, FULLNAME FROM "+comCode+".VIEWPYSLIP WHERE PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND HDRTYPE = 'EN' ORDER BY PFNO";

                    ResultSet rs = stmt.executeQuery(query);

                    while(rs.next()){
                        
                        String pfNo     = rs.getString("PFNO");
                        String fullName = rs.getString("FULLNAME");

                        String bp_  = sys.getOne(comCode+".PYSLIP", "AMOUNT", "PFNO = '"+ pfNo+ "' AND ITEMCODE = '"+ pyConfig.bp+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth);
                        Double bp   = bp_ != null? Double.parseDouble(bp_): 0.0;

                        String hs_  = sys.getOne(comCode+".PYSLIP", "AMOUNT", "PFNO = '"+ pfNo+ "' AND ITEMCODE = '"+ pyConfig.hs+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth);
                        Double hs   = hs_ != null? Double.parseDouble(hs_): 0.0;

                        String cm_  = sys.getOne(comCode+".PYSLIP", "AMOUNT", "PFNO = '"+ pfNo+ "' AND ITEMCODE = '"+ pyConfig.cm+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth);
                        Double cm   = cm_ != null? Double.parseDouble(cm_): 0.0;

                        String cr_  = sys.getOne(comCode+".PYSLIP", "AMOUNT", "PFNO = '"+ pfNo+ "' AND ITEMCODE = '"+ pyConfig.cr+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth);
                        Double cr   = cr_ != null? Double.parseDouble(cr_): 0.0;
                        
                        String ot_  = sys.getOneAgt(comCode+".VIEWPYSLIP", "SUM", "AMOUNT", "SM", " HDRTYPE = 'EN' AND PFNO = '"+ pfNo+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND ITEMCODE NOT IN ('"+ pyConfig.bp+ "', '"+ pyConfig.hs+ "', '"+ pyConfig.cm+ "', '"+ pyConfig.cr+ "', '"+ pyConfig.gp+ "')");
                        Double ot   = ot_ != null? Double.parseDouble(ot_): 0.0;

                        String gp_  = sys.getOne(comCode+".PYSLIP", "AMOUNT", "PFNO = '"+ pfNo+ "' AND ITEMCODE = '"+ pyConfig.gp+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth);
                        Double gp   = gp_ != null? Double.parseDouble(gp_): 0.0;

                        html += "<tr>";
                        html += "<td nowrap>"+ pfNo+ "</td>";
                        html += "<td nowrap>"+ fullName+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(bp.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(hs.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(cm.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(cr.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(ot.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(gp.toString())+ "</td>";
                        html += "</tr>";

                        bpTotal = bpTotal + bp;
                        hsTotal = hsTotal + hs;
                        cmTotal = cmTotal + cm;
                        crTotal = crTotal + cr;
                        otTotal = otTotal + ot;
                        gpTotal = gpTotal + gp;
                    }
                    
                }catch(Exception e){
                    html += e.getMessage();
                }
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td style = \"text-align: right;\" nowrap>- - - - - - -</td>";
                html += "<td style = \"text-align: right;\" nowrap>- - - - - - -</td>";
                html += "<td style = \"text-align: right;\" nowrap>- - - - - - -</td>";
                html += "<td style = \"text-align: right;\" nowrap>- - - - - - -</td>";
                html += "<td style = \"text-align: right;\" nowrap>- - - - - - -</td>";
                html += "<td style = \"text-align: right;\" nowrap>- - - - - - -</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(bpTotal.toString())+ "</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(hsTotal.toString())+ "</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(cmTotal.toString())+ "</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(crTotal.toString())+ "</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(otTotal.toString())+ "</td>";
                html += "<td style = \"text-align: right;\">"+ sys.numberFormat(gpTotal.toString())+ "</td>";
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
    
    PrintRptEarningSmr printRptEarningSmr = new PrintRptEarningSmr();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Earning Summary</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptEarningSmr.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
