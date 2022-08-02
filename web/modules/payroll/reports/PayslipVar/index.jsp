<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
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
        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
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
        <link rel="shortcut icon" href="<%= rootPath %>favicon.ico" />
        <title>Payslip Variance</title>
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
            div#dvPayslip{
                height: 336px;
                padding: 5px 2px;
                overflow: scroll;
                overflow-y: auto;
                overflow-x: hidden;
                border: 1px solid #808080;
            }
            div.dvSlipItems{
                padding-left: 5px;
            }
            button.smallButton{
                border: none;
                padding: 0;
            }
        </style>
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
            out.print(gui.loadJs(request.getContextPath(), "tinybox"));
            out.print(gui.loadJs(request.getContextPath(), "module"));
        %> 
        <script type="text/javascript">
            
            Event.observe(window,'load',function(){module.getModule();});
            
            var g = new Growler( {location : 'br' , width:'' });
            
            var payslip = {
                
                searchStaff: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'staffDiv';
                        new Ajax.Autocompleter(
                                'staff', getResultTo, module.ajaxUrl, {
                                    paramName  : 'pfNo',
                                    parameters : 'function=searchStaff',
                                    minChars   : 2,
                                    frequency  : 1.0,
                                    afterUpdateElement : payslip.setStaff
                                }
                            );
                    }
                },
                setStaff: function(text, staff){
                    if(staff.id !== ''){
                        if($('pfNo')) $('pfNo').value= staff.id;
                        payslip.getStaffDtls(staff.id);
                        payslip.getPayslipVar();
                    }
                },
                getStaffDtls: function(staff){
                    new Ajax.Request(module.ajaxUrl, {
                        method:'post',
                        parameters: 'function=getStaffDtls&staff='+ staff,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.staffName !== 'undefined' && $('spStaffName')) $('spStaffName').update(response.staffName);
                                
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
                getPayslipVar: function(){
                    module.execute('getPayslipVar', Form.serialize('frmModule'), 'dvPayslip');
                },
                print: function(required){
                    if(module.validate(required)){
                        var data = Form.serialize('frmModule');
                        var printWindow = window.open(
                                './print?'+ data, '', 'height=450, width=800, toolbar=no, menubar=no, directories=no, location=no, scrollbars=yes, status=no, resizable=no, fullscreen=no, top=200, left=200');
                        printWindow.focus();
                    }
                }
            };
            
        </script>
    </body>
</html>