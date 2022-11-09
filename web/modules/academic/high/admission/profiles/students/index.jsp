<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%
    String rootPath = "../../../../../../";
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
//        if(! system.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
//            session.setAttribute("userId", null);
//            sessionExpired = true;
//        }
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
        <title>Student Profile</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
            out.print(gui.loadCss(request.getContextPath(), "tab-view"));
            out.print(gui.loadCss(request.getContextPath(), "datepicker"));
        %>
        <style>
            iframe#upload_iframe{
                width: 0;
                height: 0;
                border: 0;
            }
            div.divPhoto{
                display: table;
            }
            div.divPhoto img{
                height: 128px;
                width: 128px;
                border: 1px solid #919B9C;
            }
            div#divPhotoOptions a{                           
                text-decoration: none;
                color: #9999F8;
            }
        </style>
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
            
            Event.observe(window, 'load', function(){module.getGrid();});
            
            var g = new Growler( {location : 'br' , width:'' });
            
            var students = {
                
                toggleStudentNo: function(){
                    if($('autoStudentNo').checked === true){
                        if($('studentNo')) $('studentNo').disabled = true;
                    }else{
                        if($('studentNo')) $('studentNo').disabled = false;
                    }
                },
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
                                afterUpdateElement : students.setStudent
                            });
                    }
                },
                setStudent: function(text, student){
                    if(student.id !== ''){
                        if($('studentNoHd')) $('studentNoHd').value= student.id;
                        students.getStudentProfile(student.id);
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
                                
                                if(typeof response.id !== 'undefined' && $('id')) $('id').value = response.id;
                                if(typeof response.firstName !== 'undefined' && $('firstName')) $('firstName').value = response.firstName;
                                if(typeof response.middleName !== 'undefined' && $('middleName')) $('middleName').value = response.middleName;
                                if(typeof response.lastName !== 'undefined' && $('lastName')) $('lastName').value = response.lastName;
                                if(typeof response.gender !== 'undefined' && $('gender')) $('gender').value = response.gender;
                                if(typeof response.dob !== 'undefined' && $('dob')) $('dob').value = response.dob;
                                if(typeof response.country !== 'undefined' && $('country')) $('country').value = response.country;
                                if(typeof response.disability !== 'undefined' && $('disability')) $('disability').value = response.disability;
                                
                                if(typeof response.physChald !== 'undefined' && response.physChald === 1 && $('physChald') ){
                                    $('physChald').checked = true;
                                    $('disability').disabled = false;
                                }else{
                                    $('physChald').checked = false;
                                    $('disability').disabled = true;
                                }
                                if(typeof response.postalAdr !== 'undefined' && $('postalAdr')) $('postalAdr').value = response.postalAdr;
                                if(typeof response.postalCode !== 'undefined' && $('postalCode')) $('postalCode').value = response.postalCode;
                                if(typeof response.physicalAdr !== 'undefined' && $('physicalAdr')) $('physicalAdr').value = response.physicalAdr;
                                if(typeof response.telephone !== 'undefined' && $('telephone')) $('telephone').value = response.telephone;
                                if(typeof response.cellphone !== 'undefined' && $('cellphone')) $('cellphone').value = response.cellphone;
                                if(typeof response.email !== 'undefined' && $('email')) $('email').value = response.email;
                                
                                if(typeof response.stream !== 'undefined' && $('stream')) $('stream').value = response.stream;
                                students.getStudPrdsUi();
                                if(typeof response.studentPeriod !== 'undefined' && $('studentPeriod')) $('studentPeriod').value = response.studentPeriod;
                                if(typeof response.studentType !== 'undefined' && $('studentType')) $('studentType').value = response.studentType;
                                if(typeof response.studentStatus !== 'undefined' && $('studentStatus')) $('studentStatus').value = response.studentStatus;
                                
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
                hidePhotoOptions: function(){
                    if($('divPhotoOptions')) $('divPhotoOptions').setStyle({display:'none'});
                },
                uploadPhoto: function(required){
                    if(module.validate(required)){
                        var frmModule = $('frmModule')
                        var data = frmModule.serialize();
                        frmModule.action = "./upload/?"+data;
                        frmModule.submit();
                        /*frmModule.disable();*/
                    }
                },
                getUploadResponse: function(errorCount, errorMsg){
                    if(typeof errorCount !== 'undefined' && errorCount > 0){
                        g.error(errorMsg, { header : ' ' , life: 5, speedout: 2 });
                    }else{
                        g.info("Photo successfully uploaded", { header : ' ' ,life: 5, speedout: 2  });
                    }
                    students.reloadPhoto();
                    /*module.getGrid();*/
                },
                reloadPhoto: function(){
                    var studentNo = $('studentNo')? $F('studentNo'): '';
                    if(studentNo != ''){
                        $('imgPhoto').setAttribute('src', 'photo.jsp?studentNo='+studentNo);
                        students.hidePhotoOptions();
                    }else{
                        $('imgPhoto').setAttribute('src', rootPath+'/images/emblems/places-user-identity.png');
                    }
                },
                purgePhoto: function(studentNo, lastName){
                    if(confirm("Delete '"+lastName+"' photo?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=purgePhoto&studentNo='+studentNo,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    $('imgPhoto').setAttribute('src', rootPath+'/images/emblems/places-user-identity.png');
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
                toggleDisab: function(){
                    if($('physChald').checked === true){
                        $('disability').disabled = false;
                    }else{
                        $('disability').value = '';
                        $('disability').disabled = true;
                    }
                },
                getStudPrdsUi: function(){
                    var data = Form.serialize('frmModule');
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getStudPrdsUi&'+ data,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success==='number' && response.success===1){
                                if(typeof response.studPrdUi !== 'undefined' && $('tdStudentPeriod')) $('tdStudentPeriod').update(response.studPrdUi);
                                /*g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });*/
                            }else{
                                if(typeof response.message !== 'undefined'){
                                    g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                }else{
                                    g.error("Oops! An un-expected error occured.", { header : ' ' ,life: 5, speedout: 2 });
                                }
                            }
                        }
                    });
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
                                    if(typeof response.studentNo !== 'undefined' && response.studentNo !== '' && $('autoStudentNo').checked === true){
                                        if($('studentNo')) $('studentNo').value = response.studentNo;
                                        if($('btnSave')) $('btnSave').disabled = true;
                                    }
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
                }
            };
            
        </script>
    </body>
</html>