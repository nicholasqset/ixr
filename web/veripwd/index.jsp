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
    
    String cellphone  = request.getParameter("cellphone");
    
    if(cellphone == null){
        response.sendRedirect("../");
        return;
    }
    
    session.setAttribute("cellphone", cellphone);
    
    
//    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId") == "")) {
//        sessionExpired = true;
//    }
    
//    if(request.getParameter("n") == null){
//        session.setAttribute("userId", null);
//        sessionExpired = true;
//    }
//    
//    EncryptionUtil encryptionUtil = new EncryptionUtil();
//    Sys sys = new Sys();
//    
//    try{
//        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
//        if(! sys.userHasRight(user.userId, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
//            session.setAttribute("userId", null);
//            sessionExpired = true;
//        }
//    }catch(NullPointerException e){
//        
//    }
//    catch(Exception e){
//        
//    }
        
    Gui gui = new Gui();
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" href="<%= rootPath %>favicon.ico" />
        <title>Password Verify</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
            out.print(gui.loadCss(request.getContextPath(), "tab-view"));
            out.print(gui.loadCss(request.getContextPath(), "datepicker"));
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
                                        + "An SMS pin has been sent to your cellphone No. <b>"+ session.getAttribute("cellphone").toString()+ "</b> "
                                        + "for verification. Key in to verify password reset for your account."
                                        + "</p>";

                                html += "<div>";
                                html += gui.formIcon(request.getContextPath(),"pencil.png", "", "")+" "+gui.formLabel("pwdCode", "Password Pin")+"</td>";
                                html +="</div>";
                                html += "<div>";
                                html += "<input type=\"text\" value=\"\" id=\"pwdCode\"  name=\"pwdCode\" class=\"form-control\" style=\"height: 37px; font-size:14pt;  border: 1px solid #CED4DA; border-radius: 3px;\">";
                                html +="</div>";

                                html += "<div style=\"padding-left: 10px; padding-top: 20px; padding-bottom: 20px; border: 0;\" >";
                                html += gui.formButton(request.getContextPath(), "button", "btnSave", "Verify", "save.png","onclick = \"payment.save('pwdCode'); return false;\"", "btn-info");
                                html += "<span id = \"sp_save\" style = \"padding-left: 5px; color: blue; font-size: 11px;\"></span>";
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
            
            var g = new Growler( {location : 'br' , width:'' });
            
            var payment = {
                save: function(required){
                    var data = Form.serialize('frmModule');
                    if(module.validate(required)){
                        if($('frmModule'))  $('frmModule').disabled = true;  
                        if($('btnSave')) $('btnSave').disabled = true; 
                        
                        $('sp_save').update('verifying password..please wait...');
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=save&'+data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                  
                                    window.top.location  = '../confirmpwd/';
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