<%@page import="java.util.Base64"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Enumeration"%>
<%@page import="bean.gui.Gui"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
<%
//    Enumeration params = request.getParameterNames(); 
//    while(params.hasMoreElements()){
//        String paramName = (String)params.nextElement();
//        out.print("Attribute Name = "+paramName+", Value = "+request.getParameter(paramName)+"<br>");
//    }
    
    String rootPath = "../";
    
    String compName   = request.getParameter("compName");
    String cellphone  = request.getParameter("cellphone");
    String email      = request.getParameter("email");
    String password   = request.getParameter("password");
    
    if(compName == null){
        response.sendRedirect("../");
        return;
    }
    
    if(cellphone == null){
        response.sendRedirect("../");
        return;
    }
    
    
    if(email == null){
        response.sendRedirect("../");
        return;
    }
    
    
    if(password == null){
        response.sendRedirect("../");
        return;
    }
    
    session.setAttribute("compName", compName);
    session.setAttribute("cellphone", cellphone);
    session.setAttribute("email", email);
    session.setAttribute("password", password);
    
    
    JSONObject jSONObject = new JSONObject();
    jSONObject.put("compName", compName);
    jSONObject.put("cellphone", cellphone);
    jSONObject.put("email", email);
    jSONObject.put("password", password);
                        
    String data_ = Base64.getEncoder().encodeToString(jSONObject.toJSONString().getBytes()); 
    
    Gui gui = new Gui();
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" href="<%= rootPath %>favicon.ico" />
        <title>Payment</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCssFeLibs(request.getContextPath(), "felibs/fontawesome/css/all.min"));
//            out.print(gui.loadCss(request.getContextPath(), "buttons"));
//            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
//            out.print(gui.loadCss(request.getContextPath(), "tab-view"));
//            out.print(gui.loadCss(request.getContextPath(), "datepicker"));
             out.print(gui.loadCss(request.getContextPath(), "bootstrap"));
        %>
        
        <style>
            iframe#upload_iframe{
                width: 0;
                height: 0;
                border: 0;
            }
            div.divLogo{
                display: table;
            }
            div.divLogo img{
                height: 128px;
                width: 128px;
                border: 1px solid #919B9C;
            }
            div#divLogoOptions a{                           
                text-decoration: none;
                color: #9999F8;
            }
        </style>
        <script type="text/javascript"> var rootPath = '<%= request.getContextPath() %>';</script>
    </head>
    <body>
        <div class="module-wrapper">
            <div class="module-content">
                <div class="content-row">
                    <div class="content-cell">
                        <div id="module">
                            <%
                                String html = "";
                                
                                html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
                                
                                html += "<div class=\"container\">"; 
                                html += "<div class=\"row\" style=\"margin-top: 10%\">";

                                html += "<div class=\"offset-md-3 col-md-5 card card-footer\" style=\"background-color:#eceff1; border-radius: 5px;\">";

                                html +="<p>"
                                        + "To pay use the following <b>MPesa</b> details;"
                                        + "<div style = \"text-align: left;\">"
                                        + "<div style = \"padding: 2px;\">Paybill #: <b>939537</b></div>"
                                        + "<div style = \"padding: 2px;\">Account #: <b>"+ session.getAttribute("cellphone").toString()+ "</b></div>"
                                        + "<div style = \"padding: 2px;\">Amount: KES. <b>1, 000</b></div>"
                                        + "<div style = \"padding: 2px;\">Pin: <b>****</b></div>"
                                        + "<div style = \"padding: 2px;\"><b>Send</b></div>"
                                        + "</div>"
                                        + "</p>";

                                html += "<div>";
                                html += gui.formIcon(request.getContextPath(),"pencil.png", "", "")+" "+gui.formLabel("mpesaCode", "MPesa Code")+"</td>";
                                html +="</div>";
                                html += "<div>";
                                html += "<input type=\"text\" value=\"\" id=\"mpesaCode\"  name=\"mpesaCode\" class=\"form-control\" style=\"height: 37px; font-size:14pt;  border: 1px solid #CED4DA; border-radius: 3px;\">";
                                html +="</div>";

                                html += "<div style=\"padding-left: 10px; padding-top: 20px; padding-bottom: 20px; border: 0;\" >";
                                html += gui.formButton(request.getContextPath(), "button", "btnSave", "Confirm", "save.png","onclick = \"payment.save('mpesaCode'); return false;\"", "btn-info");
                                html += "<span id = \"sp_save\" style = \"padding-left: 5px; color: blue; font-size: 11px;\"></span>";
                                html += "</div>";
                                
                                 html += gui.formEnd();
                                 
                                html += "<div style = \"text-align: center; font-weight: bold;\">OR</div>";
                                html += "<div style = \"text-align: left;\">Pay using PayPal;</div>";
                                
                                html += "<p>";
                                
                                html += "<form action=\"https://www.paypal.com/cgi-bin/webscr\"";
                                    html += "method=\"post\" target=\"_top\">";
                                    html += "<input type='hidden' name='business' value='finance@qset.co.ke'> ";
                                    html += "<input type='hidden' name='item_no' value='"+cellphone+"'>";
                                    html += "<input type='hidden' name='item_name' value='iXR Registration - "+data_+"'> ";
                                    html += "<input type='hidden' name='CustomerId' value='"+cellphone+"'> ";
                                    html += "<input type='hidden' name='amount' value='10'> ";
                                    html += "<input type='hidden' name='no_shipping' value='1'> ";
                                    html += "<input type='hidden' name='currency_code' value='USD'> ";
                                    html += "<input type='hidden' name='notify_url' value='https://api.p.qset.co.ke/ixr/payment/register/notify.php'>";
                                    html += "<input type='hidden' name='cancel_return' value='https://api.p.qset.co.ke/ixr/payment/register/cancel.php'>";
                                    html += "<input type='hidden' name='return'  value='https://api.p.qset.co.ke/ixr/payment/register/return.php?invoiceno="+cellphone+"&&customerno="+cellphone+"&&invoiceamount=10'>";
                                    html += "<input type=\"hidden\" name=\"cmd\" value=\"_xclick\"> ";
                                    html += "<button  type=\"submit\"  class=\"btn btn-info\"><i class=\"fa fa-bars\"></i> Pay using PayPal</button>";
                                html += "</form>";
                                            
                                html += "</p>";
                                
                                html += "</div>";
                                html += "</div>";
                                html += "</div>";
                                                          
                                out.print(html);
                            %>
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <%
            out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype"));
            out.print(gui.loadJs(request.getContextPath(), "scriptaculous/src/scriptaculous"));
            out.print(gui.loadJs(request.getContextPath(), "Growler"));
            out.print(gui.loadJs(request.getContextPath(), "tinybox"));
            out.print(gui.loadJs(request.getContextPath(), "module"));
            out.print(gui.loadJs(request.getContextPath(), "tab-view/ajax"));
            out.print(gui.loadJs(request.getContextPath(), "tab-view/tab-view"));
            out.print(gui.loadJs(request.getContextPath(), "prototype-date-extensions"));
            out.print(gui.loadJs(request.getContextPath(), "datepicker"));
        %> 
        <script type="text/javascript">
            
//            Event.observe(window, 'load', function(){module.getModule();});
            
            var g = new Growler( {location : 'br' , width:'' });
            
            var payment = {
                save: function(required){
                    var data = Form.serialize('frmModule');
                    if(module.validate(required)){
                        if($('frmModule'))  $('frmModule').disabled = true;  
                        if($('btnSave')) $('btnSave').disabled = true; 
                        
                        $('sp_save').update('confirming payment..please wait...');
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=save&'+data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                  
                                    window.top.location  = '../verification';
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                        
                                                 
                               }else{
                                        g.error("Un-expected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
			});
                        if($('frmModule')) { $('frmModule').disabled = false; }
                        if($('btnSave')) { $('btnSave').disabled = false;}
                    }
                }
            };
            
        </script>
    </body>
</html>