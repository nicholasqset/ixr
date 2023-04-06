<%@page import="java.net.URLDecoder"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.user.User"%>
<%@page import="com.qset.security.EncryptionUtil"%>
<%@page import="com.qset.sys.Sys"%>
<%
    String rootPath = "../../../../";
    Boolean sessionExpired = false;
    
//    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId") == "")) {
//        sessionExpired = true;
//    }
//    
//    if(request.getParameter("n") == null){
//        session.setAttribute("userId", null);
////        sessionExpired = true;
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
        <title>Invoice/Order Entry</title>
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
                    window.top.location  = '<%= rootPath %>';
                <%
            }
            %>
        </script>
        <script type="text/javascript"> var rootPath = '<%= request.getContextPath() %>';</script>
        <style>
            div#dvPyEntries{
                height: 158px;
                padding: 2px;
                overflow: scroll;
                overflow-y: auto;
                overflow-x: hidden;
                border: 1px solid #919B9C;
            }
            div#dvPyEntries-a{
                height: 103px;
                padding: 2px;
                overflow: scroll;
                overflow-y: auto;
                overflow-x: hidden;
            }
            div#dvPyEntries-b{
                height: 30px;
                padding-top: 4px;
                padding-right: 2px;
                padding-bottom: 2px;
                padding-left: 2px;
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
            
            var invoice = {
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
                                afterUpdateElement : invoice.setCustomer
                            });
                    }
                },
                setCustomer: function(text, customer){
                    if(customer.id !== ''){
                        if($('customerNoHd')) $('customerNoHd').value= customer.id;
                        invoice.getCustomerProfile(customer.id);
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
                                afterUpdateElement : invoice.setItem
                            });
                    }
                },
                setItem: function(text, item){
                    if(item.id !== ''){
                        if($('itemNoHd')) $('itemNoHd').value= item.id;
                        invoice.getItemProfile(item.id);                        
                    }
                },
                getItemProfile: function(){
                    var itemNo = $('itemNo')? $F('itemNo'): '';
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getItemProfile&itemNo='+ itemNo,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.itemName !== 'undefined' && $('tdItemName')) $('tdItemName').update(response.itemName);
                                if(typeof response.quantity !== 'undefined' && $('quantity')) $('quantity').value = response.quantity;
                                if(typeof response.price !== 'undefined' && $('price')) $('price').value = response.price;
                                if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                                
                                invoice.getItemPhoto(itemNo);
                                
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
//                    alert(itemCode);
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
                                    
                                    if(typeof response.invoiceNo !== 'undefined'){
                                        if($('invoiceNo')) $('invoiceNo').value = response.invoiceNo;
                                        if($('receiptNoHd')) $('receiptNoHd').value = response.invoiceNo;
                                    }
                                    
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    if($('dvPyEntries')) invoice.getPyEntries();
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
                purge: function(id, name, code, quantity){
                    if(confirm("Delete '"+name+"'?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=purge&id='+ id+ '&itemNo='+ code+ '&quantity='+ quantity,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    if($('dvPyEntries')) invoice.getPyEntries();
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
                        var invoiceNo = $('invoiceNo')? $F('invoiceNo'): '';
                        var printWindow = window.open(
                                './print?invoiceNo='+ invoiceNo, '', 'height=464, width=525, toolbar=no, menubar=no, directories=no, location=no, scrollbars=yes, status=no, resizable=no, fullscreen=no, top=200, left=200');
                        printWindow.focus();
                    }
                }
            };
        </script>
    </body>
</html>
