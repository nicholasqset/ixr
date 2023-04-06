<%-- 
    Document   : index
    Created on : Dec 23, 2019, 2:55:14 PM
    Author     : nicholas
--%>

<%@page import="com.qset.gui.Gui"%>
<%
    Gui gui = new Gui();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Customer Statement</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
        %>
    </head>
    <body>
        <div class="module-wrapper">
            <div class="module-header">
                <div class="module-header-row">
                    <div class="module-header-row-left">
                        <!--action buttons-->
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
        %>
        
        <script type="text/javascript">
            
            Event.observe(window,'load',function(){module.getModule();});
            
            var g = new Growler( {location : 'br' , width:'' });
            
            var stmt = {
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
                                afterUpdateElement : stmt.setCustomer
                            });
                    }
                },
                setCustomer: function(text, customer){
                    if(customer.id !== ''){
                        if($('customerNoHd')) $('customerNoHd').value = customer.id;
                        stmt.getCustomerProfile(customer.id);
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
                print: function(required){
                    if(module.validate(required)){
                        var data = Form.serialize('frmModule');
                        var printWindow = window.open(
                                './print/?'+ data, '', 'height=450, width=800, toolbar=no, menubar=no, directories=no, location=no, scrollbars=yes, status=no, resizable=no, fullscreen=no, top=200, left=200');
                        printWindow.focus();
                    }
                }
            };
            
        </script>
    </body>
</html>
