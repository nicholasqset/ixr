<%-- 
    Document   : class.subscription
    Created on : Nov 14, 2019, 7:41:15 PM
    Author     : nicholas
--%>

<%@page import="okhttp3.Response"%>
<%@page import="okhttp3.Request"%>
<%@page import="okhttp3.RequestBody"%>
<%@page import="okhttp3.MediaType"%>
<%@page import="okhttp3.OkHttpClient"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.util.Base64"%>
<%@page import="java.util.Random"%>
<%@page import="bean.security.Security"%>
<%@page import="java.util.Enumeration"%>
<%@page import="bean.sys.Sys"%>
<%@page import="com.africastalking.sms.Recipient"%>
<%@page import="java.util.List"%>
<%@page import="com.africastalking.SmsService"%>
<%@page import="com.africastalking.AfricasTalking"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%
    
    final class Subscription{
        String table        = "sys.subscriptions";
        
        String phoneNo      = request.getParameter("phoneNo");
        String refNo        = request.getParameter("refNo");
        String transDate    = request.getParameter("transDate");
        Double amount       = (request.getParameter("amount") != null && !request.getParameter("amount").trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
        String accNo        = request.getParameter("accNo");
        
        Double amountUSD    = (request.getParameter("amountUSD") != null && !request.getParameter("amountUSD").trim().equals(""))? Double.parseDouble(request.getParameter("amountUSD")): 0.0;
        
        String comName      = request.getParameter("comName");
        String password     = request.getParameter("password");
        String email        = request.getParameter("email");
        
        String data         = request.getParameter("data");
        String holdAcc      = request.getParameter("holdAcc");
        
        public JSONObject subscribe(){
            JSONObject jSONObject = new JSONObject();
            Sys sys = new Sys();
            try{
                try{
                    Double setAmount = 1000.0;

                    Double bal = amount - setAmount;

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt  = conn.createStatement();

                    Integer pyActive = bal >= 0? 1: null;

                    SimpleDateFormat  simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); 
                    Calendar calendar = Calendar.getInstance();
                    calendar.add(Calendar.MONTH, 1);
                    String endDate = (String)(simpleDateFormat.format(calendar.getTime()));
                    
                    String paybillNo = "939537";

                    String query = ""
                            + "INSERT INTO "+ this.table+ " "
                            + "("
                            + "py_ref_no, py_date, py_cellphone, py_amount, py_active,"
                            + "py_start_date, py_end_date, py_opt_fld4"
                            + ")"
                            + "VALUES"
                            + "("
                            + "'"+this.refNo+"', "
                            + "now(), "
                            + "'"+this.phoneNo+"', "
                            + this.amount+", "
                            + pyActive+", "
                            + "now(), "
                            + "'"+ endDate+ "', "
                            + "'"+ paybillNo+ "' "
                            + ")";

                    Integer  saved = stmt.executeUpdate(query);

                    if(saved == 1){
                        jSONObject.put("success", new Integer(1));
                        jSONObject.put("message", "Entry successfully made.");

                        sendSubscriptionSms(this.phoneNo, sys.numberFormat(this.amount.toString()), pyActive);
                        
//                        ==
                        
                        OkHttpClient client = new OkHttpClient().newBuilder()
                            .build();
                          MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
                          RequestBody body = RequestBody.create(mediaType, "function=sendEmail&"
                                  + "email=nicholasgakumo@gmail.com&"
                                  + "cc=info@goqset.com&"
                                  + "bcc=nicholasqset@gmail.com&"
                                  + "subject="+paybillNo+" - "+this.phoneNo+ "&"
                                  + "message= Hi, "+ this.refNo + " - "+ this.amount+ " paid."
                          );
                          Request request = new Request.Builder()
                            .url("https://api.goqset.com/")
                            .method("POST", body)
                            .addHeader("Content-Type", "application/x-www-form-urlencoded")
                            .build();
                          Response response = client.newCall(request).execute();

                          sys.log("response="+ response);
    //                        ==

                    }else{
                        jSONObject.put("success", new Integer(0));
                        jSONObject.put("message", "Oops! An Un-expected error occured while saving record.");
                    }

                }catch(Exception e){
                    jSONObject.put("success", new Integer(0));
                    jSONObject.put("message", e.getMessage());
                }
            }catch(Exception  e){
                System.out.println(e.getMessage());
            }
            
            return jSONObject;
        }
        
        public void sendSubscriptionSms(String phoneNo, String amount, Integer acStatus){
            try{
                String username = "qXR";
                String apiKey = "98e6dc9d6eb6659a384ed6734531f3123d65d4ef55e9fde4a15ab23ec5f1587d";
                AfricasTalking.initialize(username, apiKey);

                String sms;
                if(acStatus == 1){
                    sms = "Hi, we have received KES."+ amount+ " for your iXR subsrcription. Continue to verify your user account. Thank you!";                    
                }else{
                    sms = "Hi, we have received KES."+ amount+ " for your iXR subsrcription. However the amount was not enough. Thank you!";
                }
                
                //Initialize a service eg SMS
                SmsService smsService = AfricasTalking.getService(AfricasTalking.SERVICE_SMS);
                
                phoneNo = phoneNo+ ",254725999504";

                //Use the service
                List<Recipient> response2 = smsService.send(sms, new String[]{"+"+ phoneNo}, true);

                System.out.println("response2===="+ response2);
                System.out.print(response2.get(0).status+".........hello............");
                System.out.println("inn");
            }catch (Exception e) {
                e.printStackTrace();
                System.out.println(e.getMessage());
            }
        }
        
        public JSONObject ppSubscribe(){
            Enumeration params = request.getParameterNames(); 
            while(params.hasMoreElements()){
                String paramName = (String)params.nextElement();
                System.out.println("Attribute Name = "+paramName+", Value = "+request.getParameter(paramName));
            }
            
            JSONObject jSONObject = new JSONObject();
            Sys sys = new Sys();
            
            try{
                byte[] actualByte = Base64.getDecoder().decode(this.data); 
                String data_ = new String(actualByte); 
                System.out.println("data_..."+data_);

                JSONObject jSONData = new JSONObject(data_);
//                JSONArray jSONArray = jSONData.getJSONArray(data_);
                
//                for(int i = 0; i < jSONArray.length(); i++){
//                    JSONObject dataObj = jSONArray.getJSONObject(i);
//                    this.comName    = dataObj.getString("compName");
//                    this.phoneNo    = dataObj.getString("cellphone");
//                    this.email      = dataObj.getString("email");
//                    this.password   = dataObj.getString("password");
//                }

                this.comName    = jSONData.getString("compName");
                this.phoneNo    = jSONData.getString("cellphone");
                this.email      = jSONData.getString("email");
                this.password   = jSONData.getString("password");

                System.out.println("...paypal dins...");

                try{
                    Double setAmount = 1000.0;

                    Double bal = amount - setAmount;

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt  = conn.createStatement();

                    Integer pyActive = bal >= 0? 1: null;

                    SimpleDateFormat  simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); 
                    Calendar calendar = Calendar.getInstance();
                    calendar.add(Calendar.MONTH, 1);
                    String endDate = (String)(simpleDateFormat.format(calendar.getTime()));

                    String query = ""
                            + "INSERT INTO "+ this.table+ " "
                            + "("
                            + "py_ref_no, py_date, py_cellphone, py_amount, py_active,"
                            + "py_start_date, py_end_date, py_amt_usd"
                            + ")"
                            + "VALUES"
                            + "("
                            + "'"+this.refNo+"', "
                            + "now(), "
                            + "'"+this.phoneNo+"', "
                            + this.amount+", "
                            + pyActive+", "
                            + "now(), "
                            + "'"+ endDate+ "', "
                            + this.amountUSD+" "
                            + ")";

                    Integer  saved = stmt.executeUpdate(query);

                    if(saved == 1){
                        jSONObject.put("success", new Integer(1));
                        jSONObject.put("message", "Entry successfully made.");

                        sendSubscriptionSms(this.phoneNo, sys.numberFormat(this.amount.toString()), pyActive);
                        
                        this.createPpAc();


                    }else{
                        jSONObject.put("success", new Integer(0));
                        jSONObject.put("message", "Oops! An Un-expected error occured while saving record.");
                    }

                }catch(Exception e){
                    jSONObject.put("success", new Integer(0));
                    jSONObject.put("message", e.getMessage());
                }
            }catch(Exception e){
                System.out.println(e.getMessage());
            }
            
            return jSONObject;
        }
        
        public Object createPpAc(){
            JSONObject obj = new JSONObject();

            Sys sys = new Sys();
            Security security = new Security();

            try{
                Boolean subscribed = sys.recordExists("sys.subscriptions", "py_active = 1 AND py_cellphone = '"+ phoneNo+ "'");
                if(subscribed){

                // get a random id number 
                    Random rand = new Random();
                    int num     = rand.nextInt(1000000);
                // get a random letter
                    Random rnd = new Random();
                    char ltr = (char) (rnd.nextInt(26) + 'a');

                   //concat to get company code
                    String  comCode=""+ ltr+ num ;
                   // generate a random pin number
                    Random pn = new Random();
                    String pinNo = String.format("%04d", pn.nextInt(10000));

                    try{
                        Connection conn = ConnectionProvider.getConnection();
                        Statement stmt = conn.createStatement();
                        String query = "";

                        query = "INSERT INTO sys.coms"
                                + "("
                                + "comcode, compname, cellphone, "
                                + "email, create_date, password, pinno"
                                + ")"
                                + "VALUES"
                                + "("
                                + "'"+comCode+"', '"+this.comName+"', '"+this.phoneNo+"',"
                                + "'"+this.email+"', 'now()', '"+security.md5(this.password)+"', '"+pinNo+"'"
                                + ")";

                        Integer saved = stmt.executeUpdate(query);

                        if(saved ==1){ 
                            sendPpVeriSms(phoneNo, pinNo);

                     // create sessions
                            HttpSession session = request.getSession();

                            session.setAttribute("comCode", comCode);
                            session.setAttribute("pinNo", pinNo);

                            obj.put("success", new Integer(1));
                            obj.put("message", "Entry successfully made.");
                        }else{
                            obj.put("success", new Integer(0));
                            obj.put("message", "Oops! An Un-expected error occured while saving record.");
                        }           
                    }catch(Exception e){
                        obj.put("success", new Integer(0));
                        obj.put("message", e.getMessage());
                        System.out.println(e.getMessage());
                    }
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }
            }catch(Exception e){
                System.out.println(e.getMessage());
            }

            return obj;
        }
        
        public void sendPpVeriSms(String phoneNo, String pinNo){
            try{
                String username = "qXR";
                String apiKey = "98e6dc9d6eb6659a384ed6734531f3123d65d4ef55e9fde4a15ab23ec5f1587d";
                AfricasTalking.initialize(username, apiKey);

                String sms = "Hi, your iXR verification code is "+ pinNo+ ".";

                //Initialize a service eg SMS
                SmsService smsService = AfricasTalking.getService(AfricasTalking.SERVICE_SMS);

                //Use the service
                List<Recipient> response2 = smsService.send(sms, new String[]{"+"+ phoneNo}, true);

                System.out.println("response2===="+ response2);
                System.out.print(response2.get(0).status+".........hello............");
                System.out.println("inn");
            }catch (Exception e) {
                e.printStackTrace();
                System.out.println(e.getMessage());
            }
        }
        
        public JSONObject logMpesaTrans() throws Exception{
            JSONObject jSONObject = new JSONObject();
            Sys sys = new Sys();
            try{
                Double setAmount = 1000.0;

                Double bal = amount - setAmount;

                Connection conn = ConnectionProvider.getConnection();
                Statement stmt  = conn.createStatement();

                Integer pyActive = bal >= 0? 1: null;

                SimpleDateFormat  simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); 
                Calendar calendar = Calendar.getInstance();
                calendar.add(Calendar.MONTH, 1);
                String endDate = (String)(simpleDateFormat.format(calendar.getTime()));
                
//                String paybillNo = "4042017";
                String paybillNo = holdAcc;

                String query = ""
                        + "INSERT INTO "+ this.table+ " "
                        + "("
                        + "py_ref_no, py_date, py_cellphone, py_amount, py_active,"
                        + "py_start_date, py_end_date, py_opt_fld4"
                        + ")"
                        + "VALUES"
                        + "("
                        + "'"+this.refNo+"', "
                        + "now(), "
                        + "'"+this.phoneNo+"', "
                        + this.amount+", "
                        + pyActive+", "
                        + "now(), "
                        + "'"+ endDate+ "', "
                        + "'"+ paybillNo+ "' "
                        + ")";

                Integer  saved = stmt.executeUpdate(query);

                if(saved == 1){
                    jSONObject.put("success", new Integer(1));
                    jSONObject.put("message", "Entry successfully made.");

//                    sendSubscriptionSms(this.phoneNo, sys.numberFormat(this.amount.toString()), pyActive);

                

                    OkHttpClient client = new OkHttpClient().newBuilder()
                        .build();
                      MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
                      RequestBody body = RequestBody.create(mediaType, "function=sendEmail&"
                              + "email=nicholasgakumo@gmail.com&"
                              + "cc=info@goqset.com&"
                              + "bcc=nicholasqset@gmail.com&"
                              + "subject="+paybillNo+" - "+this.phoneNo+ "&"
                              + "message= Hi, "+ this.refNo + " - "+ this.amount+ " paid."
                      );
                      Request request = new Request.Builder()
                        .url("https://api.goqset.com/")
                        .method("POST", body)
                        .addHeader("Content-Type", "application/x-www-form-urlencoded")
                        .build();
                      Response response = client.newCall(request).execute();
                      
                      sys.log("response="+ response);

                }else{
                    jSONObject.put("success", new Integer(0));
                    jSONObject.put("message", "Oops! An Un-expected error occured while saving record.");
                }

            }catch(Exception e){
                jSONObject.put("success", new Integer(0));
                jSONObject.put("message", e.getMessage());
            }
          
            return jSONObject;
        }
        
    }
    
%>
