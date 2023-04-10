<%-- 
    Document   : Jobs
    Created on : Apr 10, 2023, 1:03:07 PM
    Author     : nicholas
--%>

<%@page import="com.africastalking.sms.Recipient"%>
<%@page import="java.util.List"%>
<%@page import="com.africastalking.SmsService"%>
<%@page import="com.africastalking.AfricasTalking"%>
<%@page import="okhttp3.Response"%>
<%@page import="okhttp3.Request"%>
<%@page import="okhttp3.RequestBody"%>
<%@page import="okhttp3.MediaType"%>
<%@page import="okhttp3.OkHttpClient"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.sys.Sys"%>
<%

    final class Jobs {

        public void send() {
            Sys sys = new Sys();

            String schema = request.getParameter("schema");

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query = "SELECT * FROM " + schema + ".cm_queue WHERE (sent is null OR sent = 0)";

                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {

                    String id = rs.getString("id");
                    String to_email = rs.getString("to_email");
                    String subject = rs.getString("subject");
                    String message = rs.getString("message");
                    String replyTo = rs.getString("reply_to");
                    String msgType = rs.getString("msg_type");

                    if (msgType.equalsIgnoreCase("SMS")) {
                        String username = "qXR";
                        String apiKey = "98e6dc9d6eb6659a384ed6734531f3123d65d4ef55e9fde4a15ab23ec5f1587d";
                        AfricasTalking.initialize(username, apiKey);


                        //Initialize a service eg SMS
                        SmsService smsService = AfricasTalking.getService(AfricasTalking.SERVICE_SMS);

                        //Use the service
                        List<Recipient> response2 = smsService.send(message, new String[]{"+" + to_email}, true);

                        System.out.println("response2====" + response2);
                        System.out.print(response2.get(0).status + ".........hello............");
                        System.out.println("inn");
                    } else {
                        OkHttpClient client = new OkHttpClient().newBuilder()
                                .build();
                        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
                        RequestBody body = RequestBody.create(mediaType, "function=sendEmail&"
                                + "email=" + to_email + "&"
                                + "subject=" + subject + "&"
                                + "message=" + message
                        );
                        Request request = new Request.Builder()
                                .url("https://api.goqset.com/")
                                .method("POST", body)
                                .addHeader("Content-Type", "application/x-www-form-urlencoded")
                                .build();
                        Response response = client.newCall(request).execute();

//                    sys.logV2("response=" + response);
                    }
                    Integer sent = sys.executeSql("UPDATE " + schema + ".cm_queue SET sent = 1 WHERE id = " + id);
                }

            } catch (Exception e) {
                sys.logV2(e.getMessage());
            }
        }
    }
%>
