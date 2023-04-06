<%@page import="com.qset.gui.Gui"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="com.qset.user.User"%>
<%@page import="com.qset.security.EncryptionUtil"%>
<%@page import="com.qset.sys.Sys"%>
<%
    
    String rootPath = "../../../../";
    
    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId") == "")) {
        response.sendRedirect(rootPath);
    }
    
    if(request.getParameter("n") == null){
        session.setAttribute("userId", null);
        response.sendRedirect(rootPath);
    }
    
    EncryptionUtil encryptionUtil = new EncryptionUtil();
    
    Sys sys = new Sys();
    
    try{
        
//        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
//        
//        if(! system.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
//            session.setAttribute("userId", null);
//            response.sendRedirect(rootPath);
//        }
        
    }catch(NullPointerException e){
        
    }
        
    Gui gui = new Gui();
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Subscribers</title>
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
            
            var staffs = {
                
                toggleStaffNo: function(){
                    if($('autoStaffNo').checked === true){
                        if($('staffNo')) $('staffNo').disabled = true;
                    }else{
                        if($('staffNo')) $('staffNo').disabled = false;
                    }
                },
                searchStaff: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'staffNoDiv';
                        new Ajax.Autocompleter(
                                'staffNo', getResultTo, module.ajaxUrl,{
                                paramName  : 'staffNoHd',
                                parameters : 'function=searchStaff',
                                minChars   : 2,
                                frequency  : 1.0,
                                afterUpdateElement : staffs.setStaff
                            });
                    }
                },
                setStaff: function(text, staff){
                    if(staff.id !== ''){
                        if($('staffNoHd')) $('staffNoHd').value= staff.id;
                        staffs.getStaffProfile(staff.id);
                    }
                },
                getStaffProfile: function(staffNo){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getStaffProfile&staffNo='+staffNo,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.salutation !== 'undefined' && $('salutation')) $('salutation').value = response.salutation;
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
                                    $('physChald').checked = true;
                                    $('disability').disabled = true;
                                }
                                if(typeof response.postalAddr !== 'undefined' && $('postalAddr')) $('postalAddr').value = response.postalAddr;
                                if(typeof response.postalCode !== 'undefined' && $('postalCode')) $('postalCode').value = response.postalCode;
                                if(typeof response.physicalAddr !== 'undefined' && $('physicalAddr')) $('physicalAddr').value = response.physicalAddr;
                                if(typeof response.telephone !== 'undefined' && $('telephone')) $('telephone').value = response.telephone;
                                if(typeof response.cellphone !== 'undefined' && $('cellphone')) $('cellphone').value = response.cellphone;
                                if(typeof response.email !== 'undefined' && $('email')) $('email').value = response.email;
                                
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
                    staffs.reloadPhoto();
                    /*module.getGrid();*/
                },
                reloadPhoto: function(){
                    var staffNo = $('staffNo')? $F('staffNo'): '';
                    if(staffNo != ''){
                        $('imgPhoto').setAttribute('src', 'photo.jsp?staffNo='+staffNo);
                        staffs.hidePhotoOptions();
                    }else{
                        $('imgPhoto').setAttribute('src', rootPath+'/assets/img/emblems/places-user-identity.png');
                    }
                },
                purgePhoto: function(staffNo, lastName){
                    if(confirm("Delete '"+lastName+"' photo?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=purgePhoto&staffNo='+staffNo,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    $('imgPhoto').setAttribute('src', rootPath+'/assets/img/emblems/places-user-identity.png');
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
                save: function(required){
//                    var data = Form.serialize('frmModule');
                    var data = Form.serialize('frmModule') + '&'+ Form.serialize('frmContact') + '&'+ Form.serialize('frmEmployment') ;
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
                                    if(typeof response.staffNo !== 'undefined' && response.staffNo !== '' && $('autoStaffNo').checked === true){
                                        if($('staffNo')) $('staffNo').value = response.staffNo;
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
                },
                addSpecialisation: function(staffNo){
                    module.execute('addSpecialisation', "staffNo="+staffNo, 'divSpecialisation');
                },
                saveSpecialisation: function(required){
                    if(module.validate(required)){
                        if($('frmSpecialisation'))  $('frmSpecialisation').disabled = true;  
                        if($('btnSaveSpecialisation')) $('btnSaveSpecialisation').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=saveSpecialisation&'+ Form.serialize("frmSpecialisation"),
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success === 'number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  }); 
                                    staffs.getSpecialisation($F('staffNo'));
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("An un-expected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
			});
                        if($('frmSpecialisation')) { $('frmSpecialisation').disabled = false; }
                        if($('btnSaveSpecialisation')) { $('btnSaveSpecialisation').disabled = false;}
                    }
                },
                getSpecialisation: function(staffNo){
                    module.execute('getSpecialisation', "staffNo="+staffNo, 'divSpecialisation');
                },
                editSpecialisation: function(id){
                    module.execute('addSpecialisation', "rid="+id, 'divSpecialisation');
                },
                delSpecialisation: function(id, name, staffNo){
                    if(confirm("Delete '"+name+"'?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=delSpecialisation&rid='+ id,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    staffs.getSpecialisation(staffNo);
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("An un-expected error occured while deleting record.", { header : ' ' ,life: 5, speedout: 2 });
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