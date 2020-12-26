<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.commonsrv.Company"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Profile{
    
    HttpSession session=request.getSession();
    
//    String table            = session.getAttribute("comCode")+".CSCOPROFILE";
    String table            = "sys.coms";
    String view             = "";
        
    String comCode          = session.getAttribute("comCode").toString();
    String compName         = request.getParameter("name");
    String postalAdr        = request.getParameter("postalAdr");
    String postalCode       = request.getParameter("postalCode");
    String physicalAdr      = request.getParameter("physicalAdr");
    String telephone        = request.getParameter("telephone");
    String cellphone        = request.getParameter("cellphone");
    String email            = request.getParameter("email");
    String website          = request.getParameter("website");
    String optFld1          = request.getParameter("optFld1");
    
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
//        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";
        
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getProfileTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"profile.save('code name'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Profile\'), 0, 625, 350, Array(false));";
        html += "</script>";
        
        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        
        return html;
    }
    
    public String getProfileTab(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
//        this.comCode = sys.getOne(this.table, "COMPANYCODE", "");
        
//        if(this.comCode != null){
           
        Company company = new Company(this.comCode);

        this.compName        = company.compName;
        this.postalAdr          = company.postalAdr;
        this.postalCode         = company.postalCode;
        this.physicalAdr        = company.physicalAdr;
        this.telephone          = company.telephone;
        this.cellphone          = company.cellphone;
        this.email              = company.email;
        this.website            = company.website;
        this.optFld1            = company.optFld1;
            
//        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"building.png", "", "")+" "+gui.formLabel("code", "Company Code")+"</td>";
        html += "<td colspan = \"3\">"+ gui.formInput("text", "code", 15, this.comCode != null? this.comCode: "" , "", "readonly") +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td >"+gui.formIcon(request.getContextPath(),"building-edit.png", "", "")+" "+gui.formLabel("name", "Company Name")+"</td>";
	html += "<td colspan = \"2\">"+ gui.formInput("text", "name", 25, this.comCode != null? this.compName: "", "", "") +"</td>";
        if(this.comCode != null){
            String imgLogoSrc;
            if(this.hasLogo(this.comCode)){
                imgLogoSrc = "logo.jsp?code="+ this.comCode;
            }else{
                imgLogoSrc = request.getContextPath()+"/images/logo/default-logo.png";
            }
            
            html += "<td rowspan = \"5\">";
            html += "<div class = \"divLogo\"><img id = \"imgLogo\" src=\""+ imgLogoSrc+ "\"></div>";
            html += "</td>";
        }
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"email-open.png", "", "")+" "+gui.formLabel("postalAdr", "Postal Address")+"</td>";
	html += "<td colspan = \"2\">"+gui.formInput("text", "postalAdr", 25, this.comCode != null? this.postalAdr: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("postalCode", "Postal Code")+"</td>";
	html += "<td colspan = \"2\">"+gui.formInput("text", "postalCode", 15, this.comCode != null? this.postalCode: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("physicalAdr", "Physical Address")+"</td>";
	html += "<td colspan = \"2\">"+gui.formInput("textarea", "physicalAdr", 30, this.comCode != null? this.physicalAdr: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"telephone.png", "", "")+" "+gui.formLabel("telephone", "Telephone")+"</td>";
	html += "<td colspan = \"2\">"+gui.formInput("text", "telephone", 15, this.comCode != null? this.telephone: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"mobile-phone.png", "", "")+" "+gui.formLabel("cellphone", "Cell Phone")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "cellphone", 15, this.comCode != null? this.cellphone: "", "", "readonly")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"email.png", "", "")+" "+gui.formLabel("email", "Email")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "email", 25, this.comCode != null? this.email: "", "", "readonly")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("website", "Website")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "website", 25, this.comCode != null? this.website: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+" "+ gui.formLabel("optFld1", "KRA Pin No")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "optFld1", 25, this.comCode != null? this.optFld1: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "</table>";
        
        if(this.comCode != null){
            html += " <script type=\"text/javascript\">"
                    +   "Event.observe(\'imgLogo\', \'mouseover\', function(){"
                    +       "if($(\'divLogoOptions\')){"
                    +           "$(\'divLogoOptions\')"
                    +           ".absolutize()"
                    +           ".setStyle({display:\'table-cell\'})"
                    +           ".clonePosition($(\'imgLogo\'));"
                    +       "}"
                    +   "});"
                    + "</script>";
                        
            html += "<div id = \"divLogoOptions\" onmouseout = \"profile.hideLogoOptions();\" style = \"display: none; background-color: #000000; opacity: 0.4; text-align: center;\">";
            html += "<input name = \"logo\" id = \"logo\" type = \"file\" onchange = \"profile.uploadLogo();\" style = \"display: none;\">";
            html += "<div style = \"padding-top: 50px;\">";
            html += "<a href = \"javascript:;\" onclick = \"$('logo').click();\">upload</a>";
            html += "</div>";
            if(this.hasLogo(this.comCode)){
                html += "<div >";
                html += gui.formHref("onclick = \"profile.purgeLogo('"+ this.comCode+ "', '"+ this.compName+ "')\"", request.getContextPath(), "", "remove", "remove", "", "");
                html += "</div>";
            }
            html += "</div>";
        }
        
        return html;
    }
    
    public Boolean hasLogo(String comCode){
        Boolean hasLogo = false;
        
        Sys sys = new Sys();
        
        if(this.comCode != null){
            if(sys.getOne(session.getAttribute("comCode")+".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode+ "'") != null){
                hasLogo = true;
            }
        }
        
        return hasLogo;
    }
    
    
    public Object save() throws Exception{
        
        JSONObject obj      = new JSONObject();
        Sys sys       = new Sys();
        HttpSession session = request.getSession();
        
//        sys.delete(this.table, "");
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
	    String query = "";
            
            query += "UPDATE "+this.table+" SET "
                    + "COMPNAME     = '"+ this.compName +"', "
                    
                    + "POSTALADR    = '"+ this.postalAdr +"', "
                    + "POSTALCODE   = '"+ this.postalCode +"', "
                    + "PHYSICALADR  = '"+ this.physicalAdr +"', "
                    + "TELEPHONE    = '"+ this.telephone +"', "
//                    + "CELLPHONE    = '"+ this.cellphone +"', "
//                    + "EMAIL        = '"+ this.email +"', "
                    + "WEBSITE      = '"+ this.website +"', "
                    
                    + "OPTFLD1      = '"+ this.optFld1 +"', "
                    
                    + "AUDITUSER    = '"+ sys.getLogUser(session) +"', "
                    + "AUDITDATE    = '"+ sys.getLogDate() +"', "
                    + "AUDITTIME    = '"+ sys.getLogTime() +"', "
                    + "AUDITIPADR   = '"+ sys.getClientIpAdr(request) +"' "
                    + "WHERE COMCODE = '"+ this.comCode+ "'";
            
            Integer saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public Object purgeLogo() throws Exception{
        
         Connection conn = ConnectionProvider.getConnection();
         Statement stmt = null;
         
         JSONObject obj = new JSONObject();
         
         try{
            stmt = conn.createStatement();
            
            if(this.comCode != null && ! this.comCode.trim().equals("")){
                String query = "DELETE FROM "+session.getAttribute("comCode")+".CSCOLOGO WHERE COMPANYCODE = '"+this.comCode+"'";
            
                Integer purged = stmt.executeUpdate(query);
                if(purged == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully deleted.");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured while deleting record.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "An error occured while deleting record.");
            }
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
         return obj;
        
    } 
    
}

%>