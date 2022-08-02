<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%
    String rootPath = "../../../../../../../";
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
        <title>Invoice Processing</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
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
            div#dvInvsHdr{
                height: 316px;
                padding: 1px;
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
                        <%= gui.formHref("onclick = \"module.getModule();\"", request.getContextPath(), "cog.png", "", "New Process", "", "button button-rounded button-tiny") %>
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
            out.print(gui.loadJs(request.getContextPath(), "tinybox"));
            out.print(gui.loadJs(request.getContextPath(), "module"));
            out.print(gui.loadJs(request.getContextPath(), "tab-view/ajax"));
            out.print(gui.loadJs(request.getContextPath(), "tab-view/tab-view"));
            out.print(gui.loadJs(request.getContextPath(), "comet"));
        %> 
        <script type="text/javascript">
            
            Event.observe(window,'load',function(){module.getModule();});
            
            var g = new Growler( {location: 'br' ,width: ''});
            
            var procInvs = {
                getInvHdr: function(){
                    module.execute('getInvHdr', Form.serialize('frmModule'), 'dvInvsHdr');
                },
                checkAll: function(){
                    var form = $('frmModule');
                    if($('checkall').checked === true){
                            checkboxes = form.getInputs('checkbox');
                            checkboxes.each(function(e){ e.checked = 1; });
                    }else{
                            checkboxes = form.getInputs('checkbox');
                            checkboxes.each(function(e){ e.checked = 0; });
                    }
                },
                getFSDtls: function(){
                    module.execute('getFSDtls', Form.serialize('frmModule'), 'dvFSDtls');
                },
                process: function(required){
                    if(module.validate(required)){
                        if(confirm('Process?')){
                            var checks = 0;
                            var form = $('frmModule');
                            checkboxes = form.getInputs('checkbox');

                            checkboxes.each(function(e){ 
                                    if(e.checked == 1){
                                            checks++;
                                    }
                            });
                            if(checks > 0){
                                var data = Form.serialize('frmModule');
                                comet.initialize(data);
                                if($('btnProcess')) $('btnProcess').disabled = true;
                            }else{
                                alert('Tick at least one invoice');
				return false;
                            }
                        }
                    }
                }
                
            };
            
        </script>
    </body>
</html>