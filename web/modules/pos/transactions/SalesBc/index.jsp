<%-- 
    Document   : index
    Created on : Aug 21, 2016, 12:47:20 PM
    Author     : nicholas
--%>
<%@page import="java.net.URLDecoder"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
<%
    String rootPath = "../../../../";
    Boolean sessionExpired = false;
    
    if ((session.getAttribute("userid") == null) || (session.getAttribute("userid") == "")) {
//        sessionExpired = true;
    }
    
    if(request.getParameter("n") == null){
        session.setAttribute("userid", null);
//        sessionExpired = true;
    }
    
    EncryptionUtil encryptionUtil = new EncryptionUtil();
    Sys system = new Sys();
    
    try{
//        User user = new User(session.getAttribute("userid").toString());
//        if(! system.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
//            session.setAttribute("userid", null);
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
        <title>Sales</title>
        <link rel="shortcut icon" href="<%= rootPath %>favicon.ico" />
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
            out.print(gui.loadCss(request.getContextPath(), "tab-view"));
            out.print(gui.loadCss(request.getContextPath(), "datepicker"));
            out.print(gui.loadCss(request.getContextPath(), "qset"));
            
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
                height: 157px;
                padding: 2px;
                overflow: scroll;
                overflow-y: auto;
                overflow-x: hidden;
                border: 1px solid #919B9C;
            }
            div#dvPyEntries-a{
                height: 100px;
                padding: 2px;
                overflow: scroll;
                overflow-y: auto;
                overflow-x: hidden;
            }
            div#dvPyEntries-b{
                height: 34px;
                padding: 4px 2px 2px;
                overflow: scroll;
                overflow-y: auto;
                overflow-x: hidden;
            }
            div#dv_itm_img{
                /*border: 1px solid #919B9C;*/
                /*margin:  0px 50px 0 0;*/
                /*margin-top: 1%;*/
                margin-right: 50%;
                margin-left: 3%;
                padding-top:  0;
                width: 256px;
                height: 256px;
            }
            div.divPhoto img{
                height: 256px;
                width: 256px;
                border: 1px solid #919B9C;
            }
            .sPay{
                display: block;
                width: 100px;
                height: 13px;
                /*line-height: 10px;*/
                background: #0069D9;
                padding: 5px 7px 13px 7px;
                text-align: center;
                border-radius: 3px;
                color: white;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="module-wrapper">
            <div class="module-header">
                <div class="module-header-row">
                    <div class="module-header-row-left">
                        
                        <%= gui.formHref("onclick = \"module.getModule();\"", request.getContextPath(), "math-add.png", "", "New Sale", "", "button button-rounded button-tiny") %>
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
            
            var g = new Growler( {location : 'br' , width:'' });
            
            var sales = {
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
                                afterUpdateElement : sales.setCustomer
                            });
                    }
                },
                setCustomer: function(text, customer){
                    if(customer.id !== ''){
                        if($('customerNoHd')) $('customerNoHd').value= customer.id;
                        sales.getCustomerProfile(customer.id);
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
                searchItem: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'itemNoDiv';
                        new Ajax.Autocompleter(
                                'itemNo', getResultTo, module.ajaxUrl,{
                                paramName  : 'itemNoHd',
                                parameters : 'function=searchItem',
                                minChars   : 2,
                                frequency  : 1.0,
                                afterUpdateElement : sales.setItem
                            });
                    }
                },
                setItem: function(text, item){
                    if(item.id !== ''){
                        if($('itemNoHd')) $('itemNoHd').value= item.id;
                        sales.getItemProfile(item.id);
                    }
                },
                getItemProfile: function(itemNo){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getItemProfile&itemNo='+ itemNo,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.itemName !== 'undefined' && $('tdItemName')) $('tdItemName').update(response.itemName);
                                if(typeof response.quantity !== 'undefined' && $('quantity')) $('quantity').value = response.quantity;
                                if(typeof response.cost !== 'undefined' && $('tdCost')) $('tdCost').update(response.cost);
                                if(typeof response.price !== 'undefined' && $('price')) $('price').value = response.price;
                                if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                                
                                sales.getItemPhoto(itemNo);
                                
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
                getItemPhoto: function(itemCode){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=hasPhoto&itemNo='+ itemCode,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                $('imgPhoto').setAttribute('src', 'photo.jsp?itemCode='+ itemCode);                                
                                                                
                                g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                            }else{
                                if(typeof response.message !== 'undefined'){
                                    g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                }else{
                                    g.error("Un-expected error occured while retrieving record.", { header : ' ' ,life: 5, speedout: 2 });
                                }
                                
                                $('imgPhoto').setAttribute('src', rootPath+'/assets/img/emblems/no-image.gif');
                            }
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
                                    
                                    if(typeof response.receiptNo !== 'undefined'){
                                        if($('receiptNo')) $('receiptNo').value = response.receiptNo;
                                        if($('receiptNoHd')) $('receiptNoHd').value = response.receiptNo;
                                    }
                                    
                                    if($('itemNo')) $('itemNo').value = '';
                                    
                                    if(typeof response.itemName !== 'undefined'){
//                                        if($('tdItemName')) $('tdItemName').update(response.itemName);
                                    }
                                    
                                    if(typeof response.qty !== 'undefined'){
//                                        if($('quantity')) $('quantity').value = response.qty;
                                    }
                                    
                                    if(typeof response.unitPrice !== 'undefined'){
//                                        if($('price')) $('price').value = response.unitPrice;
                                    }
                                    
                                    if(typeof response.amount !== 'undefined'){
//                                        if($('amount')) $('amount').value = response.amount;
                                    }
                                    
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    if($('dvPyEntries')) sales.getPyEntries();
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
                                    if(typeof response.itemNo !== 'undefined' && $('itemNo')) $('itemNo').value = response.itemNo;
                                    if(typeof response.itemName !== 'undefined' && $('tdItemName')) $('tdItemName').update(response.itemName);
                                    if(typeof response.quantity !== 'undefined' && $('quantity')) $('quantity').value = response.quantity;
                                    if(typeof response.price !== 'undefined' && $('price')) $('price').value = response.price;
                                    if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                                    
                                    
                                    if(typeof response.taxInclusive !== 'undefined' && $('taxInclusive')){
                                        if(response.taxInclusive === 1){
                                            $('taxInclusive').checked = true;
                                        }else{
                                            $('taxInclusive').checked = false;
                                        }
                                    }
                                    
                                    if(typeof response.discount !== 'undefined' && $('discount')) $('discount').value = response.discount;
                                    
                                    sales.getItemPhoto(response.itemNo);
                                    
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
                                    if($('dvPyEntries')) sales.getPyEntries();
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
                getPaymentUi: function(receiptNo){
                    var params = 'function=getPaymentUi&receiptNoHd='+ receiptNo;
                    TINY.box.show({url: 'parser.jsp', post: params, width: 320, height: 208});
                },
                getChange: function(){
                    var bill    = $('bill')? $F('bill'): 0;
                    var tender  = $('tender')? $F('tender'): 0;
                    var change  = tender - bill;
                    
                    $('change').value = change;
                },
                savePayment: function(required){
                    var bill    = $('bill')? $F('bill'): 0;
                    var change  = $('change')? $F('change'): 0;
                    
                    var data    = Form.serialize('frmPayment');
                    data = data+ '&bill='+ bill+ '&change='+ change;
                    if(module.validate(required)){
                        new Ajax.Request(module.ajaxUrl, {
                            method:'post',
                            parameters: 'function=savePayment&'+ data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    if($('dvPyEntries')) sales.getPyEntries();
                                    TINY.box.hide();
                                    
                                    sales.print('receiptNo');
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{                                        
                                        g.error("Oops! An unexpected error occured while posting record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
                        });
                    }
                },
                post: function(id, receiptNo, desc){
                    if($('posted_'+ id)){
                        if($('posted_'+ id).checked === true){
                            if(confirm("Post Receipt '"+ receiptNo+ "'?")){
                                new Ajax.Request(module.ajaxUrl, {
                                    method:'post',
                                    parameters: 'function=post&id='+ id+ "&receiptNoHd="+ receiptNo,
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
                        var receiptNo = $('receiptNo')? $F('receiptNo'): '';
                        var printWindow = window.open(
                                './print?receiptNo='+ receiptNo, '', 'height=464, width=525, toolbar=no, menubar=no, directories=no, location=no, scrollbars=yes, status=no, resizable=no, fullscreen=no, top=200, left=200');
                        printWindow.focus();
                    }
                }
            };
        </script>
    </body>
</html>
