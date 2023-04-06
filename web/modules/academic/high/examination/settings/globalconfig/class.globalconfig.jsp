<%@page import="org.json.JSONObject"%>
<%@page import="com.qset.high.HGExamConfig"%>
<%@page import="java.util.*"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%@page import="java.sql.*"%>
<%

    final class GlobalConfig {

        HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".HGEXAMCONFIG";

        Integer id;
        Integer minSbjs = (request.getParameter("minSubjects") != null && ! request.getParameter("minSubjects").trim().equals(""))? Integer.parseInt(request.getParameter("minSubjects")): null;

        public String getModule() {

            Gui gui = new Gui();

            HGExamConfig hGExamConfig = new HGExamConfig();

            String html = "";

            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"15%\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("minSubjects", "Minimum Subjects") + "</td>";
            html += "<td>" + gui.formInput("text", "minSubjects", 10, "" + hGExamConfig.minSbjs, "", "") + "<span class = \"fade\"> minimum subjects a student should do</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"globalConfig.save('minSbjs');\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";
            html += gui.formEnd();

            return html;
        }

        public Object save() throws Exception{
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;
                Integer saved = 0;
                if (!sys.recordExists(this.table, "")) {

                    Integer id = sys.generateId(this.table, "ID");

                    query = "INSERT INTO " + this.table + " "
                            + "(ID, MINSBJS)"
                            + "VALUES"
                            + "("
                            + id+ ", "
                            + this.minSbjs
                            + ")";

                } else {
                    query = "UPDATE " + this.table + " SET "
                            + "MINSBJS     = " + this.minSbjs + "";
                    obj.put("message", query);
                }

                saved = stmt.executeUpdate(query);

                if (saved == 1) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }
            } catch (SQLException e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

    }

%>