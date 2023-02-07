<%-- 
    Document   : Trending
    Created on : Feb 7, 2023, 10:47:39 AM
    Author     : nicholas
--%>
<%@page import="java.sql.SQLException"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.sys.Sys"%>
<%@page import="org.json.JSONArray"%>
<%
    final class Trending {
        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();

        public JSONObject getTrendProds() throws Exception {
            JSONObject jSONObject = new JSONObject();

            Sys sys = new Sys();

            try {
                Boolean recordExists = sys.recordExists("" + this.comCode + ".viewpspydtls", "");

                if (recordExists) {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "select qty, itemname from " + this.comCode + ".viewpspydtls "
                            + "where itemname is not null "
                            + "group by qty, itemname "
                            + "order by qty desc "
                            + "limit 5 "
                            + "";
                            
//                            sys.logV2(query);

                    ResultSet rs = stmt.executeQuery(query);

                    JSONArray jSONArray = new JSONArray();

                    while (rs.next()) {
                        Double qty = rs.getDouble("qty");
                        String itemname = rs.getString("itemname");

                        JSONObject jSONObject2 = new JSONObject();
                        jSONObject2.put("qty", qty);
                        jSONObject2.put("itemname", itemname);

                        jSONArray.put(jSONObject2);
                    }

                    jSONObject.put("data", jSONArray);

                    jSONObject.put("status", 1);
                    jSONObject.put("message", "success");
                } else {
                    jSONObject.put("status", 0);
                    jSONObject.put("message", "no record found ");
                }
            } catch (Exception e) {
                sys.log(e.getMessage());

                jSONObject.put("status", 0);
                jSONObject.put("message", "fail: " + e.getMessage());
            }

            return jSONObject;
        }
    }
%>

