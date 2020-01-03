<%--<%@page import="java.net.URLDecoder"%>--%>
<%@page import="bean.gui.Gui"%>
<%--<%@page import="com.qset.system.User"%>
<%@page import="com.qset.system.Sys"%>
<%@page import="com.qset.security.EncryptionUtil"%>--%>
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
//        if(! sys.userHasRight(user.userId, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
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
        <title>User Rights</title>
        <link rel="shortcut icon" href="<%=request.getContextPath()%>/favicon.ico" type="image/x-icon"/>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        
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
        <div id="module">
            <i class="fa fa-circle-notch fa-spin"></i>
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
            
            var userRight = {
                getUserGrpRights: function(){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getUserGrpRights&'+Form.serialize('frmModule'),
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success==='number' && response.success===1){
                                module.execute('getSystemRoles', Form.serialize('frmModule'), 'tdRightsUI');
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
                save: function(roleCode){
//                    alert();
//                    var rightStatus;
//                    if($('allowDeny\\['+ roleCode+ '\\]').is(":checked")){
//                        rightStatus = 'on';
//                    }else{
//                        rightStatus = null;
//                    }
                    
                    var rightStatus = $('allowDeny['+roleCode+']').checked === true? 'on': null;
//                    alert(rightStatus);
                    
                    var data = 'rightStatus='+ rightStatus+ '&userId='+ $F('userId')+ '&roleCode='+ roleCode;
                    
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
			
//                    $.ajax({
//                        type: "POST",
//                        url: module.ajaxUrl,
//                        data: 'function=save&'+ data,
//                        dataType: 'json',
//                        success: function(response){
//                            if(typeof response.success==='number' && response.success===1){
//                                if(typeof response.message !== 'undefined'){
//                                    if(typeof response.allowDeny !=='undefined'){
//                                        if(response.allowDeny === 'allow'){
//                                            $.growl.notice({ title: " ", message: response.message });
//                                        }else{
//                                            $.growl.warning({ title: " ", message: 'Privilege denied' });
//                                        }  
//                                    }else{
//                                         $.growl.growl({ title: " ", message: response.message });
//                                    }
//                                    
//                                    if(typeof response.reloadMenu === 'number' && response.reloadMenu === 1){
//                                        setTimeout("userRight.reloadMenu();", 500);
//                                    }
//                                }else{
//                                     $.growl.error({ title: " ", message: 'Un-expected error occured while saving record' });
//                                }
//                            }else{
//                                $.growl.error({ title: " ", message: 'Un-expected error occured while saving record' });
//                            }
//                        },
//                        error: function (xhr, status) {
//                            alert("Sorry, there was a problem!");
//                        }
//                    });
                },
                reloadMenu: function(){
                    if(parent.top.location !== self.location){
                        parent.container.reloadMenu();
                    }
                }
                
            };
            
//            $( document ).ready( module.getModule());
            
        </script>
    </body>
</html>