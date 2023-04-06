<%@page import="com.qset.high.HighCalendar"%>
<%@page import="java.util.*"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class ProcessRcpts{
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
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getReceiptsTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Process", "cog.png", "onclick = \"procRcpts.process('academicYear term studentForm studentType item amount'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Receipts\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getReceiptsTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        HighCalendar highCalendar = new HighCalendar(this.comCode);
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("academicYear", " Academic Year")+ "</td>";
        html += "<td>"+ gui.formSelect("academicYear", ""+this.comCode+".HGACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", ""+ highCalendar.academicYear, "onchange = \"procRcpts.getReceipts();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("term", " Term")+ "</td>";
	html += "<td>"+ gui.formSelect("term", ""+this.comCode+".HGTERMS", "TERMCODE", "TERMNAME", "", "", highCalendar.termCode, "onchange = \"procRcpts.getReceipts();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("studentForm", " Student Form")+ "</td>";
	html += "<td>"+ gui.formSelect("studentForm", ""+this.comCode+".HGFORMS", "FORMCODE", "FORMNAME", "", "", "", "onchange = \"procRcpts.getReceipts();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td colspan = \"2\"><div class = \"hr\"></div></td>";
//	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\" style = \"vertical-align: top;\"><div id = \"dvReceipts\">"+ this.getReceipts()+ "</div></td>";
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getReceipts(){
        String html = "";
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        if(sys.recordExists(""+this.comCode+".VIEWHGVERFDRCPTS", "ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND STUDENTNO IN (SELECT STUDENTNO FROM "+this.comCode+".VIEWHGSTUDENTPROFILE WHERE FORMCODE = '"+ this.formCode+ "') ")){
            
            String checkAll = gui.formCheckBox("checkall", "", "", "onchange = \"procRcpts.checkAll();\"", "", "");
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>"+ checkAll+ "</th>";
            html += "<th>Receipt No</th>";
            html += "<th>Student No</th>";
            html += "<th>Name</th>";
            html += "<th>Description</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "</tr>";
            
            Double total   = 0.0;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+this.comCode+".VIEWHGVERFDRCPTS WHERE ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND STUDENTNO IN (SELECT STUDENTNO FROM "+this.comCode+".VIEWHGSTUDENTPROFILE WHERE FORMCODE = '"+ this.formCode+ "')  ORDER BY STUDENTNO";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String rcptNo       = rs.getString("RCPTNO");
                    String studentNo    = rs.getString("STUDENTNO");
                    String fullName     = rs.getString("FULLNAME");
                    String rcptDesc     = rs.getString("RCPTDESC");
                    Double amount       = rs.getDouble("AMOUNT");
                    
                    String amountLbl = sys.numberFormat(amount.toString());
                    
                    String checkEach = gui.formArrayCheckBox("checkEach", "", rcptNo, "", "", "");
                    
                    html += "<tr>";
                    html += "<td>"+ checkEach+ "</td>";
                    html += "<td>"+ rcptNo+ "</td>";
                    html += "<td>"+ studentNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ rcptDesc+ "</td>";
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
            html += "No receipts record found.";
        }
        
        return html;
    }
    
    
    
}

%>