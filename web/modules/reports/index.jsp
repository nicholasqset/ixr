<%@page import="com.qset.user.User"%>
<%@page import="com.qset.security.EncryptionUtil"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.util.Enumeration"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%
    String rootPath = "../../";
    
    Boolean sessionExpired = false;
    
    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId") == "")) {
        sessionExpired = true;
    }
    
    if(request.getParameter("n") == null){
        session.setAttribute("userId", null);
        sessionExpired = true;
    }else{
        session.setAttribute("n", request.getParameter("n"));
    }
    
    EncryptionUtil encryptionUtil = new EncryptionUtil();
    Sys sys = new Sys();
    
    try{
        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
//        if(! sys.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
//            session.setAttribute("userId", null);
//            sessionExpired = true;
//        }
    }catch(NullPointerException e){
//        out.print(e.getMessage());
    }
    catch(Exception e){
//        out.print(e.getMessage());
    }
        
    Gui gui = new Gui();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Module Reports</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
            
        %>
        <script type="text/javascript"> 
            <%
//            if(sessionExpired){
                %>
//                    window.top.location  = '<%= rootPath %>';
                <%
//            }
            %>
        </script>
        <style>
            iframe#upload_iframe{
                width: 0;
                height: 0;
                border: 0;
            }
        </style>
    </head>
    <body>
        <div class="module-wrapper">
            <div class="module-header">
                <div class="module-header-row">
                    <div class="module-header-row-left">
                        
                        <%= gui.formHref("onclick = \"module.getModule();\"", request.getContextPath(), "math-add.png", "", "Add", "", "button button-rounded button-tiny") %>
                        <%= gui.formHref("onclick = \"module.getGrid();\"", request.getContextPath(), "application-view-columns.png", "", "List", "", "button button-rounded button-tiny") %>
                        <%= gui.formHref("onclick = \"TINY.box.show({url:'"+request.getContextPath()+"/index/finder.jsp', width:300, height:40})\"", request.getContextPath(), "magnifier.png", "", "Find", "", "button button-rounded button-tiny") %>
                        
                        <%= gui.formHref("onclick = \"module.gridFirst();\"", request.getContextPath(), "go-first-view.png", "", "First", "", "button button-rounded button-tiny") %>
                        <%= gui.formHref("onclick = \"module.gridPrevious();\"", request.getContextPath(), "go-previous-view.png", "", "Previous", "", "button button-rounded button-tiny") %>
                        <%= gui.formHref("onclick = \"module.gridNext();\"", request.getContextPath(), "go-next-view.png", "", "Next", "", "button button-rounded button-tiny") %>
                        <%= gui.formHref("onclick = \"module.gridLast();\"", request.getContextPath(), "go-last-view.png", "", "Last", "", "button button-rounded button-tiny") %>
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
            
            Event.observe(window,'load',function(){module.getGrid();});
            
            var g = new Growler( {location : 'br' , width:'' });
            
            var reports = {
                
                upload: function(required, reportType){
                    if(module.validate(required)){
                        var frmModule = $('frmModule')
                        var data = frmModule.serialize();
                        frmModule.action = "./upload/?reportType="+reportType+"&"+data;
                        frmModule.submit();
                        frmModule.disable();
                    }
                },
                getUploadResponse: function(errorCount, errorMsg, rptId){
                    if(typeof errorCount !== 'undefined' && errorCount > 0){
                        g.error(errorMsg, { header : ' ' , life: 5, speedout: 2 });
                    }else{
                        g.info("Report successfully uploaded", { header : ' ' ,life: 5, speedout: 2  });
                    }
                    if(typeof rptId !== 'undefined'){
                        reports.getSubReports(rptId);
                    }else{
                        module.getGrid();
                    }
                    
                },
                getSubReports: function(id){
                    module.execute('getSubReports', 'id='+id, 'module');
                },
                addSubReport: function(id){
                    module.execute('addSubReport', 'id='+id, 'module');
                },
                getReportFilter: function(id){
                    module.execute('getReportFilter', 'id='+id, 'module');
                },
                openReport: function(id){
                    module.execute('openReport', 'id='+id, 'module');
                },
                delSubReport: function(id, name){
                    if(confirm("Delete '"+name+"' Sub Report?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=delSubReport&id='+id,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    if(typeof response.mId !== 'undefined'){
                                        reports.getSubReports(response.mId);
                                    }
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("Oops! An un-expected error occured while deleting record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
                        });
                    }
                },
                viewReport: function(required){
                    if(module.validate(required)){
                        var frmModule = $('frmModule')
                        var data = frmModule.serialize();
                        frmModule.action = "./view/?"+data;
                        frmModule.submit();
                        
//                        var new_window = window.open("./view/?"+data, 'report', 'height=400,width=600,toolbar=no,menubar=no,directories=no,location=no,scrollbars=yes,status=no,resizable=no,fullscreen=no,top=0,left=0');
//                        new_window.focus();
                        
                    }
                },
                toggleColAlias: function(checkbox, colName){
                    if($(checkbox).checked === true){
			$('colAlias['+colName+']').disabled = false;
			$('colAlias['+colName+']').value = colName;
                    }else{
                        $('colAlias['+colName+']').value = '';
                        $('colAlias['+colName+']').disabled = true;
                        
                        if($('colText['+colName+']')){
                            $('colHasText['+colName+']').checked = false;
                            $('colText['+colName+']').value = '';
                            $('colText['+colName+']').disabled = true;
                        }
                    }
                },
                toggleColText: function(checkbox, colName){
                    if($(checkbox).checked === true){
			$('colText['+colName+']').disabled = false;
                    }else{
                        $('colText['+colName+']').value = '';
                        $('colText['+colName+']').disabled = true;
                    }
                },
                save: function(required){
                    var data = Form.serialize('frmModule');
                    if(module.validate(required)){
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
                },
                purge: function(id, name){
                    if(confirm("Delete '"+name+"'?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=purge&id='+id,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    module.getGrid();
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("Oops! An un-expected error occured while deleting record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
                        });
                    }
                }
            };
            
        </script>
    </body>
</html>