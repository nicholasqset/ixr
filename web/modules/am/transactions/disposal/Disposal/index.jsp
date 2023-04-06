<%@page import="com.qset.gui.Gui"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="com.qset.user.User"%>
<%@page import="com.qset.security.EncryptionUtil"%>
<%@page import="com.qset.sys.Sys"%>
<%
    String rootPath = "../../../../../";
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
//        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
//        if(! sys.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
//            session.setAttribute("userId", null);
//            sessionExpired = true;
//        }
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
        <title>AM Disposal</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
            out.print(gui.loadCss(request.getContextPath(), "tab-view"));
            out.print(gui.loadCss(request.getContextPath(), "datepicker"));
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
            div#dvDiEntries{
                font-size: 12px;
                height: 138px;
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
            out.print(gui.loadJs(request.getContextPath(), "tab-view/ajax"));
            out.print(gui.loadJs(request.getContextPath(), "tab-view/tab-view"));
            out.print(gui.loadJs(request.getContextPath(), "prototype-date-extensions"));
            out.print(gui.loadJs(request.getContextPath(), "datepicker"));
        %> 
        <script type="text/javascript">
            
            Event.observe(window,'load',function(){module.getModule();});
            
            var g = new Growler( {location: 'br', width: ''});
            
            var disposal = {
                searchBatch: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'batchNoDiv';
                        new Ajax.Autocompleter(
                                'batchNo', getResultTo, module.ajaxUrl,{
                                    
                                    paramName  : 'batchNoHd',
                                    parameters : 'function=searchBatch',
                                    minChars   : 2,
                                    frequency  : 1.0,
                                    afterUpdateElement : disposal.setBatch
                                }
                            );
                    }
                },
                setBatch: function(text, batch){
                    if(batch.id !== ''){
                        if($('batchNoHd')) $('batchNoHd').value= batch.id;
                        disposal.getBatchProfile(batch.id);
                    }
                },
                getBatchProfile: function(batchNo){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getBatchProfile&batchNo='+ batchNo,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.batchDesc !== 'undefined' && $('tdBatchDesc')) $('tdBatchDesc').update(response.batchDesc);
                                
                                g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                            }else{
                                if(typeof response.message !== 'undefined'){
                                    g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                }else{
                                    g.error("Un-expected error occured while retrieving record.", { header : ' ' ,life: 5, speedout: 2 });
                                }
                            }
                        }
                    });
                },
                searchAsset: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'assetNoDiv';
                        new Ajax.Autocompleter(
                                'assetNo', getResultTo, module.ajaxUrl,{
                                paramName  : 'assetNoHd',
                                parameters : 'function=searchAsset',
                                minChars   : 2,
                                frequency  : 1.0,
                                afterUpdateElement : disposal.setAsset
                            });
                    }
                },
                setAsset: function(text, ast){
                    if(ast.id !== ''){
                        if($('assetNoHd')) $('assetNoHd').value= ast.id;
                        disposal.getAssetProfile(ast.id);
                    }
                },
                getAssetProfile: function(assetNo){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getAssetProfile&assetNo='+ assetNo,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.assetDesc !== 'undefined' && $('tdAstDesc')) $('tdAstDesc').update(response.assetDesc);
                                if(typeof response.opc !== 'undefined' && $('opc')) $('opc').value = response.opc;
                                if(typeof response.acmDepV !== 'undefined' && $('acmDepV')) $('acmDepV').value = response.acmDepV;
                                if(typeof response.nbv !== 'undefined' && $('nbv')) $('nbv').value = response.nbv;
                                if(typeof response.salv !== 'undefined' && $('salv')) $('salv').value = response.salv;
                                
                                g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                            }else{
                                if(typeof response.message !== 'undefined'){
                                    g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                }else{
                                    g.error("Un-expected error occured while retrieving record.", { header : ' ' ,life: 5, speedout: 2 });
                                }
                            }
                        }
                    });
                },
                getDiEntries: function(){
                    module.execute('getDiEntries', Form.serialize('frmModule'), 'dvDiEntries');
                },
                save: function(required){
                    var data = Form.serialize('frmModule');
                    
                    var opc         = $('opc')? $F('opc'): '';
                    var acmDepV     = $('acmDepV')? $F('acmDepV'): '';
                    var nbv         = $('nbv')? $F('nbv'): '';
                    var salv        = $('salv')? $F('salv'): '';
                    
                    var addData = '&opc='+ opc+ '&acmDepV='+ acmDepV+ '&nbv='+ nbv+ '&salv='+ salv;
                    
                    data = data + addData;
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
                                    
                                    if(typeof response.entryNo !== 'undefined'){
                                        if($('entryNo')) $('entryNo').value = response.entryNo;
                                        if($('entryNoHd')) $('entryNoHd').value = response.entryNo;
                                    }
                                    
                                    if(typeof response.assetNo !== 'undefined'){
                                        if($('assetNo')) $('assetNo').value = response.assetNo;
                                        if($('assetNoHd')) $('assetNoHd').value = response.assetNo;
                                    }
                                    
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    if($('dvDiEntries')) disposal.getDiEntries();
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
                        if($('btnSave')) { $('btnSave').disabled = false;}
                    }
                },
                 editDiDtls: function(sid){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=editDiDtls&sid='+ sid,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success===1){
                                g.info(response.message, { header : ' ' ,life: 5, speedout: 2  }); 

                                if(typeof response.sidUi !== 'undefined' && $('dvDiEntrySid')) $('dvDiEntrySid').update(response.sidUi);
                                if(typeof response.assetNo !== 'undefined'){
                                    if($('assetNo')) $('assetNo').value = response.assetNo;
                                    if($('assetNoHd')) $('assetNoHd').value = response.assetNo;
                                }
                                if(typeof response.assetDesc !== 'undefined' && $('tdAstDesc')) $('tdAstDesc').update(response.assetDesc);
                                if(typeof response.opc !== 'undefined' && $('opc')) $('opc').value = response.opc;
                                if(typeof response.acmDepV !== 'undefined' && $('acmDepV')) $('acmDepV').value = response.acmDepV;
                                if(typeof response.nbv !== 'undefined' && $('nbv')) $('nbv').value = response.nbv;
                                if(typeof response.salv !== 'undefined' && $('salv')) $('salv').value = response.salv;
                                if(typeof response.diClrAcc !== 'undefined' && $('diClrAcc')) $('diClrAcc').value = response.diClrAcc;
                                if(typeof response.div !== 'undefined' && $('div')) $('div').value = response.div;
                                if(typeof response.adic !== 'undefined' && $('adic')) $('adic').value = response.adic;

                            }else{
                                if(typeof response.message !== 'undefined'){
                                    g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                }else{
                                    g.error("An un-expected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                }
                            }
                        }
                    });
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
                                   if($('dvDiEntries')) disposal.getDiEntries();
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("Oops! An unexpected error occured while deleting record.", { header : ' ' ,life: 5, speedout: 2 });
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