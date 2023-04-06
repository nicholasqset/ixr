<%@page import="com.qset.gui.*"%>
<%
    String rootPath = "../../../";
    Boolean sessionExpired = false;
    
    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId").toString().trim().equals(""))) {
        sessionExpired = true;
    }
        
    Gui gui = new Gui();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" href="<%= rootPath %>favicon.ico" />
        <title>User Profile</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            
        %>
        <script type="text/javascript"> 
            <%
            if(sessionExpired){
                %>
                    window.top.location  = '<%= rootPath %>';
                <%
            }
            %>
        </script>
        <link href="../../assets/bootstrap/css/bootstrap.min.css" type="text/css" rel="stylesheet">
    </head>
    <body>
        <div class="module-wrapper">
            <div class="module-header">
                <div class="module-header-row">
                    <div class="module-header-row-left">
                        <%= gui.formHref("onclick = \"module.getModule();\"", request.getContextPath(), "reload.png", "", "Reload", "", "button button-rounded button-tiny") %>
                    </div>
                    <div class="module-header-row-right"></div>
                </div>
            </div>

            <div class="module-content">
                <div class="content-row">
                    <div class="content-cell">
                        <div id="module"><%=gui.formAjaxIcon(request.getContextPath(),"ajax-loader.gif") %></div>
                    </div>
                </div>
            </div>
        </div>
        
        <%
            out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype"));
            out.print(gui.loadJs(request.getContextPath(), "scriptaculous/src/scriptaculous"));
            out.print(gui.loadJs(request.getContextPath(), "Growler"));
            out.print(gui.loadJs(request.getContextPath(), "module"));
        %> 
        <script type="text/javascript">
            
            Event.observe(window,'load',function(){module.getModule();});
            
            var g = new Growler( {location : 'br' , width:'' });
            
            var profile = {
                save: function(required, user){
                    var data = Form.serialize('frmModule');
                    if(module.validate(required)){
                        if(confirm("Change password for '"+user+"'?")){
                            if($('frmModule'))  $('frmModule').disabled = true;  
                            if($('btnSave')) $('btnSave').disabled = true; 

                            new Ajax.Request(module.ajaxUrl ,{
                                method:'post',
                                parameters: 'function=save&'+data,
                                requestHeaders: { Accept: 'application/json'},
                                onSuccess: function(request) {
                                    response = request.responseText.evalJSON();
                                    if(typeof response.success==='number' && response.success===1){
                                        g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
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
                }
            };
            
        </script>
    </body>
</html>