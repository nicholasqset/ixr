<%@page import="bean.gui.Gui"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
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
//        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
//        if(! system.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
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
        <title>PO Receipts</title>
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
//                    window.top.location  = '<%= rootPath %>';
                <%
            }
            %>
        </script>
        <script type="text/javascript"> var rootPath = '<%= request.getContextPath() %>';</script>
        <style>
            div#dvPyEntries{
                height: 151px;
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
            
            Event.observe(window,'load',function(){module.getGrid();});
            
            var g = new Growler( {location: 'br', width: ''});
            
            var receipt = {
                searchSupplier: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'supplierNoDiv';
                        new Ajax.Autocompleter(
                                'supplierNo', getResultTo, module.ajaxUrl,{
                                paramName  : 'supplierNoHd',
                                parameters : 'function=searchSupplier',
                                minChars   : 2,
                                frequency  : 1.0,
                                afterUpdateElement : receipt.setSupplier
                            });
                    }
                },
                setSupplier: function(text, customer){
                    if(customer.id !== ''){
                        if($('supplierNoHd')) $('supplierNoHd').value= customer.id;
                        receipt.getSupplierProfile(customer.id);
                        receipt.getPoNoUi();
                        /*
                         * receipt.getPyEntries();
                         */
                    }
                },
                getSupplierProfile: function(supplierNo){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getSupplierProfile&supplierNo='+supplierNo,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.fullName !== 'undefined' && $('tdFullName')) $('tdFullName').update(response.fullName);
                                
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
                getPoNoUi: function(){
                    module.execute('getPoNoUi', Form.serialize('frmModule'), 'tdPoNo');
                },
                loadPoItems: function(required){
                    if(module.validate(required)){
                        new Ajax.Request(module.ajaxUrl, {
                            method:'post',
                            parameters: 'function=loadPoItems&'+ Form.serialize('frmModule'),
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    receipt.getPyEntries();
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("Oops! An unexpected error occured while loading PO items.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
                        });
                    }
                },
                getPoItems: function(){
                    module.execute('getPoItems', Form.serialize('frmModule'), 'tdItems');
                },
                getItemPoDtls: function(){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getItemPoDtls&'+ Form.serialize('frmModule'),
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            
                            if(typeof response.quantity !== 'undefined' && $('quantity')) $('quantity').value = response.quantity;
                            if(typeof response.cost !== 'undefined' && $('cost')) $('cost').value = response.cost;
                            if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                        }
                    });
                },
                getItemTotalAmount: function(){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getItemTotalAmount&'+ Form.serialize('frmModule'),
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            
                            if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                            
                        }
                    });
                },
                getPyEntries: function(){
                    module.execute('getPyEntries', Form.serialize('frmModule'), 'dvPyEntries');
                },
                save: function(required){
                    var data = Form.serialize('frmModule');
                    var amount = $('amount')? $F('amount'): '';
                    data = data+ '&amount='+ amount;
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
                                    
                                    if(typeof response.pyNo !== 'undefined'){
                                        if($('pyNo')) $('pyNo').value = response.pyNo;
                                        if($('pyNoHd')) $('pyNoHd').value = response.pyNo;
                                    }
                                    
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    if($('dvPyEntries')) receipt.getPyEntries();
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
                 editPoDtls: function(sid){
                    new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=editPoDtls&sid='+ sid,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success === 'number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  }); 
                                    
                                    if(typeof response.sidUi !== 'undefined' && $('dvPyEntrySid')) $('dvPyEntrySid').update(response.sidUi);
                                    if(typeof response.item !== 'undefined' && $('item')) $('item').value = response.item;
                                    if(typeof response.quantity !== 'undefined' && $('quantity')) $('quantity').value = response.quantity;
                                    if(typeof response.cost !== 'undefined' && $('cost')) $('cost').value = response.cost;
                                    if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                                    
                                    if(typeof response.taxInclusive !== 'undefined' && $('taxInclusive')){
                                        if(response.taxInclusive === 1){
                                            $('taxInclusive').checked = true;
                                        }else{
                                            $('taxInclusive').checked = false;
                                        }
                                    }
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
                                   if($('dvPyEntries')) receipt.getPyEntries();
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
                },
                post: function(id, pyNo, desc){
                    if($('posted_'+ id)){
                        if($('posted_'+ id).checked === true){
                            if(confirm("Post Receipt '"+ desc+ "'?")){
                                new Ajax.Request(module.ajaxUrl, {
                                    method:'post',
                                    parameters: 'function=post&id='+ id+ "&pyNoHd="+ pyNo,
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
                                                g.error("Oops! An unexpected error occured while posting record.", { header : ' ' ,life: 5, speedout: 2 });
                                            }
                                        }
                                    }
                                });
                            }else{
                                module.getGrid();
                            }
                        }
                    }
                },
                print: function(required){
                    if(module.validate(required)){
                        var pyNo = $('pyNo')? $F('pyNo'): '';
                        var printWindow = window.open(
                                './print?pyNo='+ pyNo, '', 'height=450, width=800, toolbar=no, menubar=no, directories=no, location=no, scrollbars=yes, status=no, resizable=no, fullscreen=no, top=200, left=200');
                        printWindow.focus();
                    }
                }
            };
            
        </script>
    </body>
</html>