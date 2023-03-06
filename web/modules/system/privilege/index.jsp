<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%
    
    String rootPath = "../../../";
//    Boolean sessionExpired = false;
//    
//    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId") == "")) {
//        sessionExpired = true;
//    }
//    
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
//        if(! system.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
//            session.setAttribute("userId", null);
//            sessionExpired = true;
//        }
//    }catch(NullPointerException e){
//        e.getMessage();
//    }
//    catch(Exception e){
//        e.getMessage();
//    }
        
    Gui gui = new Gui();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" href="<%= rootPath %>favicon.ico" />
        <title>System Rights</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
            out.print(gui.loadCss(request.getContextPath(), "menu"));
            
        %>
        <script type="text/javascript"> 
          
        </script>
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
            out.print(gui.loadJs(request.getContextPath(), "tinybox"));
            out.print(gui.loadJs(request.getContextPath(), "module"));
        %> 
        <script type="text/javascript">
            
            Event.observe(window,'load',function(){module.getModule();});
            
            var g = new Growler( {location : 'br' , width:'' });
            
            var rights = {
                
                getUserGrpRights: function(){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getUserGrpRights&'+Form.serialize('frmModule'),
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success==='number' && response.success===1){
                                module.execute('getMenu', Form.serialize('frmModule'), 'tdRightsUI');
                            }else{
                                if(typeof response.message !== 'undefined'){
                                    g.warn(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    module.getModule();
                                }else{
                                    g.error("Un-expected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                }
                            }
                        }
                    });
                },
                toggleMenu: function(menuCode){
                    var img         = $("img"+menuCode);
                    var imgCollapse = '<%= request.getContextPath() %>/assets/img/menu/minus.gif';
                    var imgExpand   = '<%= request.getContextPath() %>/assets/img/menu/plus.gif';
                    var curRow      = $('row'+menuCode);
                    var menu        = $("menu"+menuCode);
                    
                    if(menu.style.display === 'none'){
                        curRow.style.display = '';
                        new Effect.Appear(menu);
                        if(img)img.src = imgCollapse;
                    }else{
                        curRow.style.display = 'none';
                        menu.style.display = 'none';
                        if(img)img.src = imgExpand;
                    }
                },
                save: function(parentId, childId){
                    
                    var rightStatus = $('allowDeny['+childId+']').checked === true? 'on': null;
                    var data = 'rightStatus='+rightStatus+'&userRole='+$F('userRole')+'&parentId='+parentId+'&childId='+childId;
			
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=save&'+data,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success==='number' && response.success===1){
                                if(typeof response.allowDeny !=='undefined'){
                                    if(response.allowDeny === 'allow'){
                                        g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    }else{
                                        g.warn('Right Denied.', { header : ' ' ,life: 5, speedout: 2  });
                                    }
                                    if(typeof response.reloadMenu === 'number' && response.reloadMenu === 1){
                                        setTimeout("rights.reloadMenu();", 500);
                                    }
                                }else{
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                }
                                
                            }else{
                                if(typeof response.message !== 'undefined'){
                                    g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                }else{
                                    g.error("Un-expected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                }
                            }
                        }
                    });
                },
                reloadMenu: function(){
                    if(parent.top.location !== self.location){
                        parent.container.reloadMenu();
                    }
                }
                
            };
            
        </script>
    </body>
</html>