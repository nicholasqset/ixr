<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%
    String rootPath = "../../../../../../../";
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
        if(! system.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
            session.setAttribute("userId", null);
            sessionExpired = true;
        }
    }catch(NullPointerException e){
        
    }
    catch(Exception e){
        
    }
        
    Gui gui = new Gui();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Student Inquiry</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
            out.print(gui.loadCss(request.getContextPath(), "tab-view"));
            
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
            div#dvStatement{
                height: 290px;
                padding: 1px;
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
                        &nbsp;
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
            out.print(gui.loadJs(request.getContextPath(), "comet"));
        %> 
        <script type="text/javascript">
            
            Event.observe(window,'load',function(){module.getModule();});
            
            var g = new Growler( {location: 'br' ,width: ''});
            
            var studentInquiry = {
                searchStudent: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'studentNoDiv';
                        new Ajax.Autocompleter(
                                'studentNo', getResultTo, module.ajaxUrl,{
                                paramName  : 'studentNoHd',
                                parameters : 'function=searchStudent',
                                minChars   : 2,
                                frequency  : 1.0,
                                afterUpdateElement : studentInquiry.setStudent
                            });
                    }
                },
                setStudent: function(text, student){
                    if(student.id !== ''){
                        if($('studentNoHd')) $('studentNoHd').value= student.id;
                        studentInquiry.getStudentProfile(student.id);
                        studentInquiry.getStatement();
                    }
                },
                loadStudmanually: function(){
                    var studentNo = $F('studentNo');
                    if(studentNo.trim() !== ''){
                        studentInquiry.getStudentProfile(studentNo);
                        studentInquiry.getStatement();
                    }else{
                        alert('Search student first');
                    }
                },
                getStudentProfile: function(studentNo){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getStudentProfile&studentNo='+studentNo,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.fullName !== 'undefined' && $('tdFullName')) $('tdFullName').update(response.fullName);
                                if(typeof response.studentPeriod !== 'undefined' && $('tdStudentPeriod')) $('tdStudentPeriod').update(response.studentPeriod);
                                if(typeof response.studentType !== 'undefined' && $('tdStudentType')) $('tdStudentType').update(response.studentType);
                                
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
                getStatement: function(){
                    module.execute('getStatement', Form.serialize('frmModule'), 'dvStatement');
                },
                print: function(required){
                    if(module.validate(required)){
                        var printWindow = window.open('./print?studentNo='+$F('studentNo'), '', 'height=450,width=800,toolbar=no,menubar=no,directories=no,location=no,scrollbars=yes,status=no,resizable=no,fullscreen=no,top=200,left=200');
                        printWindow.focus();
                    }
                }
            };
            
        </script>
    </body>
</html>