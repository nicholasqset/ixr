<%@page import="com.qset.gui.Gui"%>
<%

    final class Home {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();

        public String view() {
            String html = "";

            return html;
        }

        public String manage() {
            String html = "";

//        Gui gui = new Gui();
            String img_alt = "";

            html += "<div class = \"home\" >";
            if (this.comCode.equalsIgnoreCase("shang_sheng")) {

            } else {
                html += "<img src = \"../../../assets/img/tm/tm.png\" title=\"iXR\" width = \"170\" height = \"170\" alt = \"" + img_alt + "\" longdesc = \"" + img_alt + "\" loading=\"lazy\"/>";
            }

            html += "</div>";

            return html;
        }

        public String save() {
            String html = "";

            return html;
        }

        public String purge() {
            String html = "";

            return html;
        }

    }

%>
