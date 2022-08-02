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
    final class PrintRptP9{
        HttpSession session = request.getSession();
        String comCode       = session.getAttribute("comCode").toString();
        
        Integer pYear   = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth  = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
        String pfNo     = request.getParameter("staff");
        
        String rptName  = "P9";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
//                String comCode = sys.getOne(comCode+ ".CSCOPROFILE", "COMPANYCODE", "");

                if(comCode != null){

                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if(sys.getOne(comCode+ ".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+comCode;
                    }else{
                        imgLogoSrc = request.getContextPath()+"/images/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"module\" >";

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
            
            Sys sys = new Sys();
            StaffProfile staffProfile = new StaffProfile(this.pfNo, comCode);
            
//            String comCode = sys.getOne(comCode+ ".CSCOPROFILE", "COMPANYCODE", "");
            Company company = new Company(comCode);
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"module\">";

            html += "<tr>";
            html += "<td style = \"text-align: center;\">KENYA REVENUE AUTHORITY</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td style = \"text-align: center;\">DOMESTIC TAXES DEPARTMENT</td>";
            html += "</tr>";
            
            html += "</table>";
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"module\">";

            html += "<tr>";
            html += "<td width = \"50%\">";
                html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"module\">";
                
                html += "<tr>";
                html += "<td width = \"40%\">P9 Report :-</td>";
                html += "<td>January "+ this.pYear+ " TO DECEMBER "+ this.pYear+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Company's Name :</td>";
                html += "<td>"+ company.compName+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Employee Department :</td>";
                html += "<td>"+ staffProfile.deptName+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Employee's Name :</td>";
                html += "<td>"+ staffProfile.fullName+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Payroll Number</td>";
                html += "<td>"+ staffProfile.pfNo+ "</td>";
                html += "</tr>";
                
                html += "</table>";
            html += "</td>";
            
            html += "<td>";
                html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"module\">";
                
                html += "<tr>";
                html += "<td colspan = \"2\">&nbsp;</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td width = \"40%\">Company's No.</td>";
                html += "<td>"+ company.pinNo+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td colspan = \"2\">&nbsp;</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Employee's No.</td>";
                html += "<td>"+ staffProfile.pinNo+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td colspan = \"2\">&nbsp;</td>";
                html += "</tr>";
                
                html += "</table>";
            html += "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            html += "<hr>";
            
            html += this.getP9();
            
            return html;
        }
        
        public String getP9(){
            String html = "";

            Sys sys = new Sys();
            
            if(sys.recordExists(comCode+ ".VIEWPYSLIP", "PFNO = '"+ this.pfNo+ "' AND PYEAR = "+ this.pYear+ " ")){
                
                PyConfig pyConfig = new PyConfig(comCode);

                html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

                html += "<tr>";
                html += "<td width = \"8%\">&nbsp;</td>";
                html += "<td width = \"8%\">&nbsp;</td>";
                html += "<td width = \"8%\">A</td>";
                html += "<td width = \"8%\">B</td>";
                html += "<td width = \"8%\">C</td>";
                html += "<td width = \"8%\">D</td>";
                html += "<td width = \"8%\">E</td>";
                html += "<td width = \"8%\">F</td>";
                html += "<td width = \"8%\">G</td>";
                html += "<td width = \"8%\">H</td>";
                html += "<td width = \"8%\">I</td>";
                html += "<td>J</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>Gross Pay</td>";
                html += "<td>Contribution Benefit</td>";
                html += "<td>Chargeable Pay</td>";
                html += "<td>Value of Quarter</td>";
                html += "<td>Tax Charged</td>";
                html += "<td>Personal Relief</td>";
                html += "<td>Insurance Relief</td>";
                html += "<td>Unused B/F</td>";
                html += "<td>Unused C/F</td>";
                html += "<td>PAYE</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>Ksh</td>";
                html += "<td>Ksh</td>";
                html += "<td>Ksh</td>";
                html += "<td>Ksh</td>";
                html += "<td>Ksh</td>";
                html += "<td>Ksh</td>";
                html += "<td>Ksh</td>";
                html += "<td>Ksh</td>";
                html += "<td>Ksh</td>";
                html += "<td>Ksh</td>";
                html += "</tr>";
                
                Double gpTotal = 0.0;
                Double cbTotal = 0.0;
                Double cpTotal = 0.0;
                Double txTotal = 0.0;
                Double prTotal = 0.0;
                Double irTotal = 0.0;
                Double mbTotal = 0.0;
                Double mcTotal = 0.0;
                Double peTotal = 0.0;
                
                for(int i = 1; i <= 12; i++){
                    
                    String gp_  = sys.getOne(comCode+ ".PYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ pyConfig.gp+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ i);
                    Double gp   = gp_ != null? Double.parseDouble(gp_): 0.0;
                    
                    String cb_  = sys.getOne(comCode+ ".PYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ pyConfig.cb+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ i);
                    Double cb   = cb_ != null? Double.parseDouble(cb_): 0.0;
                    
                    String cp_  = sys.getOne(comCode+ ".PYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ pyConfig.cp+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ i);
                    Double cp   = cp_ != null? Double.parseDouble(cp_): 0.0;
                    
                    String tx_  = sys.getOne(comCode+ ".PYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ pyConfig.tx+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ i);
                    Double tx   = tx_ != null? Double.parseDouble(tx_): 0.0;
                    
                    String pr_  = sys.getOne(comCode+ ".PYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ pyConfig.pr+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ i);
                    Double pr   = pr_ != null? Double.parseDouble(pr_): 0.0;
                    
                    String ir_  = sys.getOne(comCode+ ".PYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ pyConfig.ir+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ i);
                    Double ir   = ir_ != null? Double.parseDouble(ir_): 0.0;
                    
                    String mb_  = sys.getOne(comCode+ ".PYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ pyConfig.mb+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ i);
                    Double mb   = mb_ != null? Double.parseDouble(mb_): 0.0;
                    
                    String mc_  = sys.getOne(comCode+ ".PYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ pyConfig.mc+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ i);
                    Double mc   = mc_ != null? Double.parseDouble(mc_): 0.0;
                    
                    String pe_  = sys.getOne(comCode+ ".PYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ pyConfig.pe+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ i);
                    Double pe   = pe_ != null? Double.parseDouble(pe_): 0.0;
                    
                    html += "<tr>";
                    html += "<td>"+ sys.getMonthName(i)+ "</td>";
                    html += "<td>"+ this.pYear+ "</td>";
                    html += "<td>"+ sys.numberFormat(gp.toString())+ "</td>";
                    html += "<td>"+ sys.numberFormat(cb.toString())+ "</td>";
                    html += "<td>"+ sys.numberFormat(cp.toString())+ "</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>"+ sys.numberFormat(tx.toString())+ "</td>";
                    html += "<td>"+ sys.numberFormat(pr.toString())+ "</td>";
                    html += "<td>"+ sys.numberFormat(ir.toString())+ "</td>";
                    html += "<td>"+ sys.numberFormat(mb.toString())+ "</td>";
                    html += "<td>"+ sys.numberFormat(mc.toString())+ "</td>";
                    html += "<td>"+ sys.numberFormat(pe.toString())+ "</td>";
                    html += "</tr>";
                    
                    gpTotal = gpTotal + gp;
                    cbTotal = cbTotal + cb;
                    cpTotal = cpTotal + cp;
                    txTotal = txTotal + tx;
                    prTotal = prTotal + pr;
                    irTotal = irTotal + ir;
                    mbTotal = mbTotal + mb;
                    mcTotal = mcTotal + mc;
                    peTotal = peTotal + pe;
                }
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "<td nowrap>- - - - - - -</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>"+ sys.numberFormat(gpTotal.toString())+ "</td>";
                html += "<td>"+ sys.numberFormat(cbTotal.toString())+ "</td>";
                html += "<td>"+ sys.numberFormat(cpTotal.toString())+ "</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>"+ sys.numberFormat(txTotal.toString())+ "</td>";
                html += "<td>"+ sys.numberFormat(prTotal.toString())+ "</td>";
                html += "<td>"+ sys.numberFormat(irTotal.toString())+ "</td>";
                html += "<td>"+ sys.numberFormat(mbTotal.toString())+ "</td>";
                html += "<td>"+ sys.numberFormat(mcTotal.toString())+ "</td>";
                html += "<td>"+ sys.numberFormat(peTotal.toString())+ "</td>";
                html += "</tr>";
                
                html += "</table>";
                
                html += this.getFooterDtls();
            }else{
                html += "No record found.";
            }

            return html;
        }
        
        public String getFooterDtls(){
            String html = "";
            
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<td width = \"33%\">&nbsp;</td>";
            html += "<td width = \"33%\">&nbsp;</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td colspan = \"3\">To be completed by Employer at end of year.</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td colspan = \"3\">&nbsp;</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td>Total Chargeable Pay (Col H) Kshs. 0.00</td>";
            html += "<td colspan = \"2\">Paye (Col m) Kshs. 0.00</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td colspan = \"3\">IMPORTANT</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td colspan = \"3\">&nbsp;</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td colspan = \"3\">For Official Use Only</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td>";
                html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" border = \"1\">";
                
                html += "<tr>";
                html += "<td width = \"33%\">Tax Due</td>";
                html += "<td width = \"33%\">&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td >Tax Paid</td>";
                html += "<td >&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td >Under Paid</td>";
                html += "<td >&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td >Over Paid</td>";
                html += "<td >&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "</tr>";
                
                html += "</table>";
                html += "<br>EMPLOYER'S CERTIFICATE OF PAY AND TAX  "
                        + "<br>DATE & STAMP _______________";
            html += "</td>";
            html += "<td valign = \"top\">";
                html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";
                
                html += "<tr>";
                html += "<td>1. Date employee commenced if during t________</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Name and adress of old employer________</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>2. Date left if during Year________</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>Name and adress of new employer________</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>3. Enter details of benefits overleaf.</td>";
                html += "</tr>";
                                
                html += "<tr>";
                html += "<td>4. Where housing is provided, state monthly rent</td>";
                html += "</tr>";                
                                
                html += "<tr>";
                html += "<td>Charged Kshs _________ per month.</td>";
                html += "</tr>";
                
                html += "</table>";
            html += "</td>";
            
            html += "<td valign = \"top\">";
                html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";
                
                html += "<tr>";
                html += "<td>5. Where any of the pay relates to a period other than this year e.g gratuity, give details of amount, Year and Total.</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>";
                    html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" border = \"1\">";

                    html += "<tr>";
                    html += "<td width = \"33%\">Year</td>";
                    html += "<td width = \"33%\">Amount</td>";
                    html += "<td>Tax (Shs.)</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>Tax Paid</td>";
                    html += "<td >&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td >Under Paid</td>";
                    html += "<td >&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td >Over Paid</td>";
                    html += "<td >&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "</table>";
                html += "</td>";
                html += "</tr>";
                
                html += "</table>";
            html += "</td>";
            html += "</tr>";
            
            html += "</table>";
            
            return html;
        }

        public String printRpt(){
            String html = "";
            
//            html += this.getReportHeader();
//            html += "<br>";
            html += this.getReportDetails();
            
            return html;
        }
    }
    
    PrintRptP9 printRptP9 = new PrintRptP9();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>P9</title>
        <% 
//            out.print(gui.loadCss(request.getContextPath(), "reports"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
        %>
    </head>
    <body>
        <%= printRptP9.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
