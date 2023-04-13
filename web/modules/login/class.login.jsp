<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.qset.security.Security"%>
<%@page import="java.util.Random"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.commonsrv.Company"%>
<%@page import="com.qset.hr.StaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

    final class Userlogin {

        public String getModule() {
            String html = "";

            Gui gui = new Gui();

//        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            html += "<br>";
            html += "<br>";
            html += "<br>";
            html += "<div class=\"container\">";
            html += "<div class=\"row\">";

            html += "<div class=\"offset-md-4 col-md-4 card card-foote\" style=\"background-color:#eceff1\">";

            html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";

            // html += gui.formEnd();
            html += "<script type = \"text/javascript\">";
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Profile\'), 0, 625, 350, Array(false));";
            html += "</script>";

            html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";

            html += "" + gui.formIcon(request.getContextPath(), "building.png", "", "") + " " + gui.formLabel("code", "Username") + "";
            html += "<input type=\"text\" name=\"username\"class=\"form-control\">";

            html += "" + gui.formIcon(request.getContextPath(), "building.png", "", "") + " " + gui.formLabel("code", "Password") + "</td>";
            html += "<input type=\"password\" name=\"password\"class=\"form-control\">";

            html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Login", "save.png", "onclick = \"profile.save('code name'); return false;\"", "");
            html += gui.formEnd();
            html += "</div>";
            html += "</div>";
            html += "</div>";
            html += "</div>";
            return html;
        }

        public JSONObject save() throws Exception {

            JSONObject obj = new JSONObject();

            String username = request.getParameter("username");
            String password = request.getParameter("password");

            if (username == null || username.equals("")) {
                obj.put("success", new Integer(0));
                obj.put("message", "Please enter a username");
                return obj;
            }
            try {

                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "";
                query = "SELECT * FROM sys.sysregistration WHERE username='" + username + "' AND password='" + password + "'";

                Integer get = stmt.executeUpdate(query);
                ResultSet rs = stmt.executeQuery(query);

                if (get == 1) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Login successfu");
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! Failed to login. Confirm your username and password");
                }

            } catch (SQLException e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

    }

%>