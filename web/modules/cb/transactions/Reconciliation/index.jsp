<%-- 
    Document   : index
    Created on : Aug 30, 2016, 12:19:59 PM
    Author     : nicholas
--%>

<%@page import="java.net.URLDecoder"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.user.User"%>
<%@page import="com.qset.security.EncryptionUtil"%>
<%
    String rootPath = "../../../../";
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
        if(! system.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
            session.setAttribute("userId", null);
            sessionExpired = true;
        }
    }catch(NullPointerException e){
        e.getMessage();
    }
    catch(Exception e){
        e.getMessage();
    }
        
    Gui gui = new Gui();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Bank Reconciliation</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tab-view"));
            
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
        <script type="text/javascript"> var rootPath = '<%= request.getContextPath() %>';</script>
        <style>
            div#dvRcn{
                height: 297px;
                padding: 5px 2px;
                overflow: scroll;
                overflow-y: auto;
                overflow-x: hidden;
                border: 1px solid #919B9C;
            }
        </style>
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
            out.print(gui.loadJs(request.getContextPath(), "tab-view/ajax"));
            out.print(gui.loadJs(request.getContextPath(), "tab-view/tab-view"));
        %>
        <script type="text/javascript">
            Event.observe(window,'load',function(){module.getModule();});
            
            var g = new Growler( {location: 'br' ,width: ''});
            
            var rcn = {
                getBatchUi: function(){
                    module.execute('getBatchUi', Form.serialize('frmModule'), 'tdBatchUi');
                },
                getEntryUi: function(){
                    module.execute('getEntryUi', Form.serialize('frmModule'), 'tdEntryUi');
                },
                getReferenceUi: function(){
                    module.execute('getReferenceUi', Form.serialize('frmModule'), 'tdReferenceUi');
                },
                getRcnEntries: function(){
                    module.execute('getRcnEntries', Form.serialize('frmModule'), 'dvRcn');
                },
                save: function(id){
                    var amount  = $F("amount["+ id+ "]");
                    var rcn     = $F("rcn["+ id+ "]");
                    if(! isNaN(rcn)){
                        var data = "id="+ id+ "&amount="+ amount+ "&rcn="+ rcn;
                        if($('frmModule'))  $('frmModule').disabled = true;  

                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=save&'+ data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    if(typeof response.var !== 'undefined'){
                                        if($("var["+ id+ "]")) $("var["+ id+ "]").value = response.var;
                                    }
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("Oops! An unexpected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
                        });

                        if($('frmModule')) { $('frmModule').disabled = false; }
                    }else{
                        g.error("Invalid input. Numeric values only.", { header : ' ' ,life: 5, speedout: 2 });
                    }
                }
            };
        </script>
    </body>
</html>
