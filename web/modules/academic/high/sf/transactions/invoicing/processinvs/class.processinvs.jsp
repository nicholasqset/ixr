<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.high.HGStudentProfile"%>
<%@page import="com.qset.high.HighCalendar"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class ProcessInvs{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".HGFSHDR";
    String view             = comCode+".VIEWHGFSHEADER";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String formCode         = request.getParameter("studentForm");
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getInvsTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Process", "cog.png", "onclick = \"procInvs.process('academicYear term studentForm studentType item amount'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Invoices\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getInvsTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        HighCalendar highCalendar = new HighCalendar(this.comCode);
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("academicYear", " Academic Year")+ "</td>";
        html += "<td>"+ gui.formSelect("academicYear", ""+this.comCode+".HGACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", ""+ highCalendar.academicYear, "onchange = \"procInvs.getInvHdr();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("term", " Term")+ "</td>";
	html += "<td>"+ gui.formSelect("term", ""+this.comCode+".HGTERMS", "TERMCODE", "TERMNAME", "", "", highCalendar.termCode, "onchange = \"procInvs.getInvHdr();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("studentForm", " Student Form")+ "</td>";
	html += "<td>"+ gui.formSelect("studentForm", ""+this.comCode+".HGFORMS", "FORMCODE", "FORMNAME", "", "", "", "onchange = \"procInvs.getInvHdr();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td colspan = \"2\"><div class = \"hr\"></div></td>";
//	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\" style = \"vertical-align: top;\"><div id = \"dvInvsHdr\">"+ this.getInvHdr()+ "</div></td>";
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getInvHdr(){
        String html = "";
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        if(sys.recordExists(""+this.comCode+".HGINVSHDR", "ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND STUDENTNO IN (SELECT STUDENTNO FROM "+this.comCode+".VIEWHGSTUDENTPROFILE WHERE FORMCODE = '"+ this.formCode+ "') AND (PROCESSED IS NULL OR PROCESSED = 0) ")){
            
            String checkAll = gui.formCheckBox("checkall", "", "", "onchange = \"procInvs.checkAll();\"", "", "");
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>"+ checkAll+ "</th>";
            html += "<th>Invoice No</th>";
            html += "<th>Student No</th>";
            html += "<th>Name</th>";
            html += "<th>Description</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "</tr>";
            
            Double total   = 0.0;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+this.comCode+".HGINVSHDR WHERE ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND STUDENTNO IN (SELECT STUDENTNO FROM "+this.comCode+".VIEWHGSTUDENTPROFILE WHERE FORMCODE = '"+ this.formCode+ "') AND (PROCESSED IS NULL OR PROCESSED = 0)  ORDER BY STUDENTNO";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String studentNo    = rs.getString("STUDENTNO");
                    String invNo        = rs.getString("INVNO");
                    String invDesc      = rs.getString("INVDESC");
                    
                    HGStudentProfile hGStudentProfile = new HGStudentProfile(studentNo, this.comCode);
                    
//                    Double amount = Double.parseDouble(sys.getOne("HGINVSDTLS", "SUM(AMOUNT)", "INVNO = '"+ invNo+ "'"));
                    Double amount = Double.parseDouble(sys.getOneAgt(""+this.comCode+".HGINVSDTLS", "SUM", "AMOUNT", "SM", "INVNO = '"+ invNo+ "'"));
                    
                    String amountLbl = sys.numberFormat(amount.toString());
                    
                    String checkEach = gui.formArrayCheckBox("checkEach", "", invNo, "", "", "");
                    
                    html += "<tr>";
                    html += "<td>"+ checkEach+ "</td>";
                    html += "<td>"+ invNo+ "</td>";
                    html += "<td>"+ studentNo+ "</td>";
                    html += "<td>"+ hGStudentProfile.fullName+ "</td>";
                    html += "<td>"+ invDesc+ "</td>";
                    html += "<td style = \"text-align: right;\">"+ amountLbl +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;
                    
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"5\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ sys.numberFormat(total.toString()) +"</td>";
            html += "</tr>";
            
            html += "</table>";
        }else{
            html += "No invoices record found.";
        }
        
        return html;
    }
    
    
    
}

%>