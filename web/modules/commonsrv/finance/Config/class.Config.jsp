<%@page import="bean.finance.FinConfig"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class Config{
    HttpSession session=request.getSession();
    String table = ""+session.getAttribute("comCode")+".FNCONFIG";

    Integer id;
    String taxAth       = request.getParameter("taxAuthority");
    String taxLbAcc     = request.getParameter("taxLbAcc");
    String vatRate      = request.getParameter("vatRate");
    
    public String getModule(){

        Gui gui = new Gui();
        
        FinConfig finConfig = new FinConfig();
        
        String html = "";

        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(),"building.png", "", "")+" "+gui.formLabel("taxAuthority", "Tax Authority")+"</td>";
	html += "<td>"+gui.formInput("text", "taxAuthority", 25, finConfig.taxAth , "", "")+"</td>";
	html += "</tr>";

        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+ gui.formLabel("taxLbAcc", " Tax Liability Account")+"</td>";
	html += "<td>"+ gui.formSelect("taxLbAcc", "qset.GLACCOUNTS", "ACCOUNTCODE", "ACCOUNTNAME", "", "", finConfig.taxLbAcc, "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("vatRate", "Vat Rate")+"</td>";
	html += "<td>"+gui.formInput("text", "vatRate", 10, ""+ finConfig.vatRate , "", "")+"<span class = \"fade\"> %</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"config.save('taxAuthority taxLbAcc vatRate');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
        html += gui.formEnd();

        return html;
    }
    
    public Object save(){
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query;
            if(!sys.recordExists(this.table, "")){
            
                Integer id = sys.generateId(this.table, "ID");
                
                query = "INSERT INTO "+this.table+" "
                        + "(ID, TAXATH, TAXLBACC, VATRATE)"
                        + "VALUES"
                        + "("
                        + id+","
                        + "'"+ this.taxAth+ "', "
                        + "'"+ this.taxLbAcc+ "', "
                        + "'"+ this.vatRate+ "' "
                        + ")";
                
            }else{
                query = "UPDATE "+this.table+" SET "
                        + "TAXATH       = '"+this.taxAth+"', "
                        + "TAXLBACC     = '"+this.taxLbAcc+"', "
                        + "VATRATE      = "+ this.vatRate+ "";
                
//                obj.put("message", query);
            }
            
            Integer saved = stmt.executeUpdate(query);
            
            if(saved > 0){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oopss! An Un-expected error occured while saving record.");
            }
            
        }
        catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }

}

%>