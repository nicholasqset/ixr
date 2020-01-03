<%@page import="java.util.Calendar"%>
<%@page import="com.africastalking.sms.Recipient"%>
<%@page import="java.util.List"%>
<%@page import="com.africastalking.SmsService"%>
<%@page import="com.africastalking.AfricasTalking"%>
<%@page import="java.io.IOException"%>
<%@page import="bean.user.User"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="bean.security.Security"%>
<%@page import="java.util.Random"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.commonsrv.Company"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
  
<%
final class Payment{
    HttpSession session = request.getSession();
    
    String compName     = session.getAttribute("compName").toString();
    String cellphone    = session.getAttribute("cellphone").toString();
    String email        = session.getAttribute("email").toString();
    String password     = session.getAttribute("password").toString();

    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();        
              
        return html;
    }
    
    public Object save(){
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        Security security = new Security();
        
        Boolean subscribed = sys.recordExists("sys.subscriptions", "py_active = 1 AND py_cellphone = '"+ this.cellphone+ "'");
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
    //      
    //        SimpleDateFormat formattedDate = new SimpleDateFormat("yyyyMMdd HH:mm:ss");            
    //        Calendar c = Calendar.getInstance();        
    //        c.add(Calendar.MONTH, 1);  // number of days to add      
    //        String endDate = (String)(formattedDate.format(c.getTime()));

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
                        + "'"+comCode+"', '"+this.compName+"', '"+this.cellphone+"',"
                        + "'"+this.email+"', 'now()', '"+security.md5(this.password)+"', '"+pinNo+"'"
                        + ")";

                Integer saved = stmt.executeUpdate(query);

                if(saved ==1){ 
                    sendSms(this.cellphone, pinNo);

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
    
        return obj;
    }
    
    public void sendSms(String phoneNo, String pinNo){
        try{
            String username = "qXR";
            String apiKey = "98e6dc9d6eb6659a384ed6734531f3123d65d4ef55e9fde4a15ab23ec5f1587d";
            AfricasTalking.initialize(username, apiKey);
            
            String sms = "Hi, your iXR verification code is "+ pinNo+ ".";

            //Initialize a service eg SMS
            SmsService smsService = AfricasTalking.getService(AfricasTalking.SERVICE_SMS);

            //Use the service
//            List<Recipient> response2 = smsService.send("Hi, iXR verification code is ", new String[]{"+"+ "254725999504"}, true);
//            List<Recipient> response2 = smsService.send(sms, new String[]{"+"+ phoneNo}, true);
            List<Recipient> response2 = smsService.send(sms, new String[]{"+"+ phoneNo}, true);
            
            System.out.println("response2===="+ response2);
            System.out.print(response2.get(0).status+".........hello............");
            System.out.println("inn");
        }catch (IOException e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }
}

%>

