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
        <title>AR Receipts Entry</title>
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
            div#dvPyEntries{
                height: 133px;
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
            
            var receipt = {
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
                                    afterUpdateElement : receipt.setBatch
                                }
                            );
                    }
                },
                setBatch: function(text, batch){
                    if(batch.id !== ''){
                        if($('batchNoHd')) $('batchNoHd').value= batch.id;
                        receipt.getBatchProfile(batch.id);
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
                searchCustomer: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'customerNoDiv';
                        new Ajax.Autocompleter(
                                'customerNo', getResultTo, module.ajaxUrl,{
                                paramName  : 'customerNoHd',
                                parameters : 'function=searchCustomer',
                                minChars   : 2,
                                frequency  : 1.0,
                                afterUpdateElement : receipt.setCustomer
                            });
                    }
                },
                setCustomer: function(text, customer){
                    if(customer.id !== ''){
                        if($('customerNoHd')) $('customerNoHd').value = customer.id;
                        receipt.getCustomerProfile(customer.id);
                        receipt.getSrcBatch(customer.id);
                        receipt.getPyEntries();
                    }
                },
                getCustomerProfile: function(customerNo){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getCustomerProfile&customerNo='+customerNo,
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
                getSrcBatch: function(customerNo){
                    new Ajax.Request(module.ajaxUrl, {
                        method:'post',
                        parameters: 'function=getSrcBatch&customerNo='+ customerNo,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.srcBatchUi !== 'undefined' && $('tdSrcBatch')) $('tdSrcBatch').update(response.srcBatchUi);
                                
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
                getInBatchDocs: function(){
                    new Ajax.Request(module.ajaxUrl, {
                        method:'post',
                        parameters: 'function=getInBatchDocs&'+ Form.serialize('frmModule'),
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.documentNoUi !== 'undefined' && $('tdDocumentNo')) $('tdDocumentNo').update(response.documentNoUi);
                                
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
                getPyUnAplAmount: function(){
                    new Ajax.Request(module.ajaxUrl, {
                        method:'post',
                        parameters: 'function=getPyUnAplAmount&'+ Form.serialize('frmModule'),
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.appliedAmount !== 'undefined' && $('appliedAmount')) $('appliedAmount').value = response.appliedAmount;
                                /*
                                 * g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                 */
                                
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
                getPyEntries: function(){
                    module.execute('getPyEntries', Form.serialize('frmModule'), 'dvPyEntries');
                },
                save: function(required){
                    var data = Form.serialize('frmModule');
                    if(module.validate(required)){
                        if($('frmModule'))  $('frmModule').disabled = true;  
                        if($('btnSave')) $('btnSave').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl, {
                            method: 'post',
                            parameters: 'function=save&'+data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    
                                    if(typeof response.receiptNo !== 'undefined'){
                                        if($('receiptNo')) $('receiptNo').value = response.receiptNo;
                                        if($('receiptNoHd')) $('receiptNoHd').value = response.receiptNo;
                                    }
                                    
                                    if($('dvPyEntries')) receipt.getPyEntries();
                                    
                                    g.info(response.message, { header : ' ', life: 5, speedout: 2  });
                                    
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
                 editReceiptDtls: function(sid){
                    new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=editReceiptDtls&sid='+ sid,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success === 'number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  }); 
                                    
                                    if(typeof response.sidUi !== 'undefined' && $('dvPyEntrySid')) $('dvPyEntrySid').update(response.sidUi);
                                    if(typeof response.srcBatch !== 'undefined' && $('srcBatch')) $('srcBatch').value = response.srcBatch;
                                    if(typeof response.documentNo !== 'undefined' && $('documentNo')) $('documentNo').value = response.documentNo;
                                    if(typeof response.appliedAmount !== 'undefined' && $('appliedAmount')) $('appliedAmount').value = response.appliedAmount;
                                    
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
                print: function(required){
                    if(module.validate(required)){
                        var batchNo = $('batchNo')? $F('batchNo'): '';
                        var receiptNo = $('receiptNo')? $F('receiptNo'): '';
                        var printWindow = window.open(
                                './print?batchNo='+ batchNo+ '&receiptNo='+ receiptNo, '', 'height=450, width=634, toolbar=no, menubar=no, directories=no, location=no, scrollbars=yes, status=no, resizable=no, fullscreen=no, top=200, left=200');
                        printWindow.focus();
                    }
                }
            };
            
        </script>
    </body>
</html>