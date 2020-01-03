<%@page import="bean.gui.Gui"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
<%
    String rootPath = "../";
    Boolean sessionExpired = false;
    
    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId") == "")) {
        sessionExpired = true;
    }
    
    if(request.getParameter("n") == null){
        session.setAttribute("userId", null);
        sessionExpired = true;
    }
    
    EncryptionUtil encryptionUtil = new EncryptionUtil();
    Sys sys = new Sys();
    
    try{
        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
        if(! sys.userHasRight(user.userId, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
            session.setAttribute("userId", null);
            sessionExpired = true;
        }
    }catch(NullPointerException e){
        
    }
    catch(Exception e){
        
    }
        
    Gui gui = new Gui();
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" href="<%= rootPath %>favicon.ico" />
        <title>Register</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
            out.print(gui.loadCss(request.getContextPath(), "tab-view"));
            out.print(gui.loadCss(request.getContextPath(), "datepicker"));
            out.print(gui.loadCss(request.getContextPath(), "bootstrap"));
        %>
        <script type="text/javascript"> 
            <%
            if(sessionExpired){
                %>
                //    window.top.location  = '<%= rootPath %>';
                <%
            }
            %>
                </script>
     
        <script type="text/javascript"> var rootPath = '<%= request.getContextPath() %>';</script>
    </head>
    <body>
        <div class="module-wrapper">
<!--            <div class="module-header">
                <div class="module-header-row">
                    <div class="module-header-row-left">
                        
                        <%--<%= gui.formHref("onclick = \"module.getModule();\"", request.getContextPath(), "reload.png", "", "Reload", "", "button button-rounded button-tiny") %>--%>
                        
                    </div>
                    <div class="module-header-row-right"></div>
                </div>
            </div>-->

            <div class="module-content">
                <div class="content-row">
                    <div class="content-cell">
                        <div id="module">
                            <%--<%= //gui.formAjaxIcon(request.getContextPath(),"ajax-loader.gif") %>--%>
                            <%
                                String html = "";
                                
                                html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
               
                                html += "<div class=\"container\" style = \"\">"; 
                                html += "<div class=\"row\" style=\"margin-top: 10%\">";

                                html += "<div class=\"offset-md-3 col-md-5 card card-footer\" style=\"background-color:#eceff1; border-radius: 5px;\">";

                                html += " <div id = \"dv_err\" style=\"padding: 3px; text-align: center; color: red;\"></div>";

//                                html += "<div class=\"row\">";
                                html += "<div >";
                                html += ""+gui.formIcon(request.getContextPath(),"company.png", "", "")+" "+gui.formLabel("compName", "Company Name")+"";
                                html +="</div>";
                                html += "<div >";
                                html += "<input type=\"text\" id=\"compName\" name=\"compName\" class = \"form-control\" style=\"height: 37px; font-size:14pt;  border: 1px solid #CED4DA; border-radius: 3px; \">";
                                html += "</div>";
//                                html += "</div>";

//                                html += " <div class=\"row\">";
                                html += "<div >";
                                html += ""+gui.formIcon(request.getContextPath(),"email.png", "", "")+" "+gui.formLabel("email", "Email")+"";
                                html +="</div>";
                                html += "<div >";
                                html += "<input type=\"text\" id=\"email\" name=\"email\" class = \"form-control\" style=\"height: 37px; font-size:14pt;  border: 1px solid #CED4DA; border-radius: 3px; \">";
                                html +="</div>";
//                                html +="</div>";

//                                html += " <div class=\"row\">";
                                html += "<div >";
                                html += ""+gui.formIcon(request.getContextPath(),"mobile-phone.png", "", "")+" "+gui.formLabel("cellphone", "Cell Phone")+"";
                                html +="</div>";
                                html += "<div >";
                                html += "<input type=\"text\" id=\"cellphone\" name=\"cellphone\" placeholder = \"254712345678\" class = \"form-control\" style=\"height: 37px; font-size:14pt;  border: 1px solid #CED4DA; border-radius: 3px; \">";
                                html +="</div>";
//                                html +="</div>";

//                                html += " <div class=\"row\">";
                                html += "<div >";
                                html += ""+gui.formIcon(request.getContextPath(),"lock.png", "", "")+" "+gui.formLabel("password", "Password")+"</td>";
                                html +="</div>";
                                html += "<div >";
                                html += "<input type=\"password\" id=\"password\" name=\"password\" class = \"form-control\" style=\"height: 37px; font-size:14pt;  border: 1px solid #CED4DA; border-radius: 3px; \">";
                                html +="</div>";
//                                html +="</div>";

//                                html += " <div class=\"row\">";
                                html += "<div >";
                                html += ""+gui.formIcon(request.getContextPath(),"lock.png", "", "")+" "+gui.formLabel("confPassword", "Confirm Password")+"</td>";
                                html +="</div>";
                                html += "<div >";
                                html += "<input type=\"password\" id=\"confPassword\" name=\"confPassword\" class = \"form-control\" style=\"height: 37px; font-size:14pt;  border: 1px solid #CED4DA; border-radius: 3px;\">";
                                html +="</div>";
//                                html +="</div>";

                                html += "<div style=\"padding-left: 10px; padding-top: 20px; padding-bottom: 20px; border: 0;\" >";
                                html += gui.formButton(request.getContextPath(), "button", "btnSave", "Register", "sign-up.png", "onclick = \"reg.save('compName email cellphone password confPassword'); return false;\"", "btn-info");
                                
                                html += "</div>";

                                html += "</div>";
                                html += "</div>";
                                html += "</div>";
                                
                                html += gui.formEnd();
                                
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
            
            var reg = {
                save: function(required){
                    var frmModule    = $('frmModule');
                    var data = Form.serialize('frmModule');
                    if(module.validate(required)){
//                        frmModule.action = "../payment/?"+ data;

//                        var password        = $F('password');
//                        var confPassword    = $F('confPassword');
//                        
//                        if(password !== confPassword){
//                            $('dv_err').update('Invalid password');
//                            return;
//                        }
                        
//                        frmModule.action = "../payment/";
//                        frmModule.submit();
                        
                        if($('frmModule'))  $('frmModule').disabled = true;  
                        if($('btnSave')) $('btnSave').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=save&'+ data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    
                                    frmModule.action = "../payment/";
                                    frmModule.submit();
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                        
                                        $('dv_err').update(response.message);
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