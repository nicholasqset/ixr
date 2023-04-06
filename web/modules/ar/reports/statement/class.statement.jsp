<%-- 
    Document   : statement
    Created on : Dec 23, 2019, 2:55:27 PM
    Author     : nicholas
--%>

<%@page import="org.json.JSONObject"%>
<%@page import="com.qset.ar.ARCustomerProfile"%>
<%@page import="com.qset.gui.Gui"%>
<% 
    final class Statement{
        HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        
        String customerNo       = request.getParameter("customerNo");
        
        public String getModule(){
            String html = "";
            
            Gui gui = new Gui();
            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
            html += "<table width = \"50%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
            
            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("customerNo", " Customer No.")+ " </td>";
            html += "<td>"+ gui.formAutoComplete("customerNo", 13, "", "stmt.searchCustomer", "customerNoHd", "")+ "</td>";
            
            html += "<td id = \"tdFullName\">&nbsp;</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td width = \"15%\">&nbsp;</td>";
            html += "<td colspan = \"2\">";
            html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"stmt.print('customerNo');\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
            html += "</td>";
            html += "</tr>";
            
            html += "</table>";
            
            html += "</form>";
            
            return html;
        }
        
        public String searchCustomer(){
            String html = "";

            Gui gui = new Gui();

            this.customerNo = request.getParameter("customerNoHd");

            html += gui.getAutoColsSearch(comCode+".ARCUSTOMERS", "CUSTOMERNO, CUSTOMERNAME", "", this.customerNo);

            return html;
        }

        public Object getCustomerProfile() throws Exception{
            JSONObject obj = new JSONObject();

            if(this.customerNo == null || this.customerNo.equals("")){
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            }else{

                ARCustomerProfile aRCustomerProfile = new ARCustomerProfile(this.customerNo, comCode);

                obj.put("fullName", aRCustomerProfile.customerName);

                obj.put("success", new Integer(1));
                obj.put("message", "Customer No '"+aRCustomerProfile.customerNo+"' successfully retrieved.");

            }

            return obj;
        }
    }

%>
