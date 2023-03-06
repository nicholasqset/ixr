<%-- 
    Document   : statement
    Created on : Dec 23, 2019, 2:55:27 PM
    Author     : nicholas
--%>

<%@page import="org.json.JSONObject"%>
<%@page import="bean.ap.APSupplierProfile"%>
<%@page import="bean.gui.Gui"%>
<% 
    final class Statement{
        HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        
        String supplierNo       = request.getParameter("supplierNo");
        
        public String getModule(){
            String html = "";
            
            Gui gui = new Gui();
            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
            html += "<table width = \"50%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
            
            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("supplierNo", " Supplier No.")+ " </td>";
            html += "<td>"+ gui.formAutoComplete("supplierNo", 13, "", "stmt.searchSupplier", "supplierNoHd", "")+ "</td>";
            
            html += "<td id = \"tdFullName\">&nbsp;</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td width = \"15%\">&nbsp;</td>";
            html += "<td colspan = \"2\">";
            html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"stmt.print('supplierNo');\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
            html += "</td>";
            html += "</tr>";
            
            html += "</table>";
            
            html += "</form>";
            
            return html;
        }
        
        public String searchSupplier(){
            String html = "";

            Gui gui = new Gui();

            this.supplierNo = request.getParameter("supplierNoHd");

            html += gui.getAutoColsSearch(comCode+".APSUPPLIERS", "SUPPLIERNO, SUPPLIERNAME", "", this.supplierNo);

            return html;
        }

        public Object getSupplierProfile() throws Exception{
            JSONObject obj = new JSONObject();

            if(this.supplierNo == null || this.supplierNo.equals("")){
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            }else{

                APSupplierProfile aPCustomerProfile = new APSupplierProfile(this.supplierNo, comCode);

                obj.put("fullName", aPCustomerProfile.supplierName);

                obj.put("success", new Integer(1));
                obj.put("message", "Supplier No '"+aPCustomerProfile.supplierName+"' successfully retrieved.");

            }

            return obj;
        }
    }

%>
