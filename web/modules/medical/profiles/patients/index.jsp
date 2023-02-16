<%@page import="bean.gui.Gui"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="bean.sys.Sys"%>
<%

    String rootPath = "../../../../";

    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId") == "")) {
        response.sendRedirect(rootPath);
    }

    if (request.getParameter("n") == null) {
        session.setAttribute("userId", null);
        response.sendRedirect(rootPath);
    }

    EncryptionUtil encryptionUtil = new EncryptionUtil();

    Sys sys = new Sys();

    try {
//        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
//        
//        if(! system.userHasRight(user.roleCode, Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(request.getParameter("n"), "UTF-8"))))){
//            session.setAttribute("userId", null);
//            response.sendRedirect(rootPath);
//        }

    } catch (NullPointerException e) {

    }

    Gui gui = new Gui();
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Patients Profile</title>
        <%
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "module"));
            out.print(gui.loadCss(request.getContextPath(), "buttons"));
            out.print(gui.loadCss(request.getContextPath(), "tinybox"));
            out.print(gui.loadCss(request.getContextPath(), "tab-view"));
            out.print(gui.loadCss(request.getContextPath(), "datepicker"));
        %>
        <link rel="stylesheet" href="../../../../assets/bootstrap/css/bootstrap.min.css">
        <link rel="stylesheet" href="../../../../assets/fontawesome/css/all.css">
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
                margin-right: 50%;
                margin-left: 3%;
                padding-top:  0;
                width: 256px;
                height: 256px;
            }
           
        </style>
        <script type="text/javascript"> var rootPath = '<%= request.getContextPath()%>';</script>
    </head>
    <body>
        <div class="module-wrapper">
            <div class="module-header">
                <div class="module-header-row">
                    <div class="module-header-row-left">

                        <%= gui.formHref("onclick = \"module.getModule();\"", request.getContextPath(), "math-add.png", "", "Add", "", "button button-rounded button-tiny")%>
                        <%= gui.formHref("onclick = \"module.getGrid();\"", request.getContextPath(), "application-view-columns.png", "", "List", "", "button button-rounded button-tiny")%>
                        <%= gui.formHref("onclick = \"TINY.box.show({url:'" + request.getContextPath() + "/index/finder.jsp', width:300, height:40})\"", request.getContextPath(), "magnifier.png", "", "Find", "", "button button-rounded button-tiny")%>

                        <%= gui.formHref("onclick = \"module.gridFirst();\"", request.getContextPath(), "go-first-view.png", "", "First", "", "button button-rounded button-tiny")%>
                        <%= gui.formHref("onclick = \"module.gridPrevious();\"", request.getContextPath(), "go-previous-view.png", "", "Previous", "", "button button-rounded button-tiny")%>
                        <%= gui.formHref("onclick = \"module.gridNext();\"", request.getContextPath(), "go-next-view.png", "", "Next", "", "button button-rounded button-tiny")%>
                        <%= gui.formHref("onclick = \"module.gridLast();\"", request.getContextPath(), "go-last-view.png", "", "Last", "", "button button-rounded button-tiny")%>
                    </div>
                    <div class="module-header-row-right"></div>
                </div>
            </div>

            <div class="module-content">
                <div class="content-row">
                    <div class="content-cell">
                        <div id="module"><%=gui.formAjaxIcon(request.getContextPath(), "ajax-loader.gif")%></div>
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

            Event.observe(window, 'load', function () {
                module.getGrid();
            });

            var g = new Growler({location: 'br', width: ''});

            var patients = {

                togglePtNo: function () {
                    if ($('autoPtNo').checked === true) {
                        if ($('ptNo'))
                            $('ptNo').disabled = true;
                    } else {
                        if ($('ptNo'))
                            $('ptNo').disabled = false;
                    }
                },
                searchPatient: function () {
                    var count = Ajax.activeRequestCount;
                    if (count <= 0) {
                        var getResultTo = 'ptNoDiv';
                        new Ajax.Autocompleter(
                                'ptNo', getResultTo, module.ajaxUrl, {
                                    paramName: 'ptNoHd',
                                    parameters: 'function=searchPatient',
                                    minChars: 2,
                                    frequency: 1.0,
                                    afterUpdateElement: patients.setPatient
                                });
                    }
                },
                setPatient: function (text, staff) {
                    if (staff.id !== '') {
                        if ($('ptNoHd'))
                            $('ptNoHd').value = staff.id;
                        patients.getPatientProfile(staff.id);
                    }
                },
                getPatientProfile: function (ptNo) {
                    new Ajax.Request(module.ajaxUrl, {
                        method: 'post',
                        parameters: 'function=getPatientProfile&ptNo=' + ptNo,
                        requestHeaders: {Accept: 'application/json'},
                        onSuccess: function (request) {
                            response = request.responseText.evalJSON();
                            if (typeof response.success === 'number' && response.success === 1) {

                                if (typeof response.salutation !== 'undefined' && $('salutation'))
                                    $('salutation').value = response.salutation;
                                if (typeof response.firstName !== 'undefined' && $('firstName'))
                                    $('firstName').value = response.firstName;
                                if (typeof response.middleName !== 'undefined' && $('middleName'))
                                    $('middleName').value = response.middleName;
                                if (typeof response.lastName !== 'undefined' && $('lastName'))
                                    $('lastName').value = response.lastName;
                                if (typeof response.gender !== 'undefined' && $('gender'))
                                    $('gender').value = response.gender;
                                if (typeof response.dob !== 'undefined' && $('dob'))
                                    $('dob').value = response.dob;
                                if (typeof response.country !== 'undefined' && $('country'))
                                    $('country').value = response.country;
                                if (typeof response.disability !== 'undefined' && $('disability'))
                                    $('disability').value = response.disability;

                                if (typeof response.physChald !== 'undefined' && response.physChald === 1 && $('physChald')) {
                                    $('physChald').checked = true;
                                    $('disability').disabled = false;
                                } else {
                                    $('physChald').checked = true;
                                    $('disability').disabled = true;
                                }
                                if (typeof response.postalAddr !== 'undefined' && $('postalAddr'))
                                    $('postalAddr').value = response.postalAddr;
                                if (typeof response.postalCode !== 'undefined' && $('postalCode'))
                                    $('postalCode').value = response.postalCode;
                                if (typeof response.physicalAddr !== 'undefined' && $('physicalAddr'))
                                    $('physicalAddr').value = response.physicalAddr;
                                if (typeof response.telephone !== 'undefined' && $('telephone'))
                                    $('telephone').value = response.telephone;
                                if (typeof response.cellphone !== 'undefined' && $('cellphone'))
                                    $('cellphone').value = response.cellphone;
                                if (typeof response.email !== 'undefined' && $('email'))
                                    $('email').value = response.email;

                                g.info(response.message, {header: ' ', life: 5, speedout: 2});
                            } else {
                                if (typeof response.message !== 'undefined') {
                                    g.error(response.message, {header: ' ', life: 5, speedout: 2});
                                } else {
                                    g.error("Un-expected error occured while retrieving record.", {header: ' ', life: 5, speedout: 2});
                                }
                            }
                        }
                    });
                },
                hidePhotoOptions: function () {
                    if ($('divPhotoOptions'))
                        $('divPhotoOptions').setStyle({display: 'none'});

                },
                uploadPhoto: function (required) {
                    if (module.validate(required)) {
                        var frmModule = $('frmModule');
                        var data = frmModule.serialize();
                        frmModule.action = "./upload/?" + data;
                        frmModule.submit();
                        /*frmModule.disable();*/
                    }
                },
                getUploadResponse: function (errorCount, errorMsg) {
                    if (typeof errorCount !== 'undefined' && errorCount > 0) {
                        g.error(errorMsg, {header: ' ', life: 5, speedout: 2});
                    } else {
                        g.info("Photo successfully uploaded", {header: ' ', life: 5, speedout: 2});
                    }
                    patients.reloadPhoto();
                    /*module.getGrid();*/
                },
                reloadPhoto: function () {
                    var ptNo = $('ptNo') ? $F('ptNo') : '';
                    if (ptNo !== '') {
                        $('imgPhoto').setAttribute('src', 'photo.jsp?ptNo=' + ptNo);
                        patients.hidePhotoOptions();
                    } else {
                        $('imgPhoto').setAttribute('src', rootPath + '/images/emblems/places-user-identity.png');
                    }
                },
                purgePhoto: function (ptNo, lastName) {
                    if (confirm("Delete '" + lastName + "' photo?")) {
                        new Ajax.Request(module.ajaxUrl, {
                            method: 'post',
                            parameters: 'function=purgePhoto&ptNo=' + ptNo,
                            requestHeaders: {Accept: 'application/json'},
                            onSuccess: function (request) {
                                response = request.responseText.evalJSON();
                                if (typeof response.success === 'number' && response.success === 1) {
                                    g.info(response.message, {header: ' ', life: 5, speedout: 2});
                                    $('imgPhoto').setAttribute('src', rootPath + '/images/emblems/places-user-identity.png');
                                } else {
                                    if (typeof response.message !== 'undefined') {
                                        g.error(response.message, {header: ' ', life: 5, speedout: 2});
                                    } else {
                                        g.error("Oops! An un-expected error occured while deleting record.", {header: ' ', life: 5, speedout: 2});
                                    }
                                }
                            }
                        });
                    }
                },
                toggleDisab: function () {
                    if ($('physChald').checked === true) {
                        $('disability').disabled = false;
                    } else {
                        $('disability').value = '';
                        $('disability').disabled = true;
                    }
                },
                save: function (required) {
                    var data = Form.serialize('frmModule');
                    if (module.validate(required)) {
//                        if($('frmModule'))  $('frmModule').disabled = true;  
//                        if($('btnSave')) $('btnSave').disabled = true; 

                        new Ajax.Request(module.ajaxUrl, {
                            method: 'post',
                            parameters: 'function=save&' + data,
                            requestHeaders: {Accept: 'application/json'},
                            onSuccess: function (request) {
                                response = request.responseText.evalJSON();
                                if (typeof response.success === 'number' && response.success === 1) {
                                    if (typeof response.ptNo !== 'undefined' && response.ptNo !== '' && $('autoPtNo').checked === true) {
                                        if ($('ptNo'))
                                            $('ptNo').value = response.ptNo;
//                                        if($('id')) $('id').value = response.id;
                                        module.editModule(response.id)
//                                        if($('btnSave')) $('btnSave').disabled = true;
//                                        module.getGrid();
                                    }
                                    g.info(response.message, {header: ' ', life: 5, speedout: 2});
                                } else {
                                    if (typeof response.message !== 'undefined') {
                                        g.error(response.message, {header: ' ', life: 5, speedout: 2});
                                    } else {
                                        g.error("Un-expected error occured while saving record.", {header: ' ', life: 5, speedout: 2});
                                    }
                                }
                            }
                        });
//                        if($('frmModule')) { $('frmModule').disabled = false; }
//                        if($('btnSave')) { $('btnSave').disabled = false;}
                    }
                },
                addRegistration: function (id, ptNo) {
                    module.execute('addRegistration', "id=" + id + "&ptNo=" + ptNo, 'divRegistrations');
                },
                getRegistrations: function (id) {
                    module.execute('getRegistrations', "id=" + id, 'divRegistrations');
                },
                saveRegistration: function (required) {
                    if (module.validate(required)) {
                        if ($('frmRegistration'))
                            $('frmRegistration').disabled = true;
                        if ($('btnSaveRegistration'))
                            $('btnSaveRegistration').disabled = true;

                        new Ajax.Request(module.ajaxUrl, {
                            method: 'post',
                            parameters: 'function=saveRegistration&' + Form.serialize("frmRegistration") + '&' + Form.serialize("frmModule"),
                            requestHeaders: {Accept: 'application/json'},
                            onSuccess: function (request) {
                                response = request.responseText.evalJSON();
                                if (typeof response.success === 'number' && response.success === 1) {
                                    g.info(response.message, {header: ' ', life: 5, speedout: 2});
//                                    console.log($F('id'));
                                    patients.getRegistrations($F('id'));
                                } else {
                                    if (typeof response.message !== 'undefined') {
                                        g.error(response.message, {header: ' ', life: 5, speedout: 2});
                                    } else {
                                        g.error("An un-expected error occured while saving record.", {header: ' ', life: 5, speedout: 2});
                                    }
                                }
                            }
                        });
                        if ($('frmRegistration')) {
                            $('frmRegistration').disabled = false;
                        }
                        if ($('btnSaveRegistration')) {
                            $('btnSaveRegistration').disabled = false;
                        }
                    }
                },
                editRegistration: function (rid, id, ptNo) {
                    module.execute('addRegistration', "rid=" + rid + '&id=' + id + '&ptNo=' + ptNo, 'divRegistrations');
                },
                delRegistration: function (rid, id, regNo) {
                    if (confirm("Delete '" + regNo + "'?")) {
                        new Ajax.Request(module.ajaxUrl, {
                            method: 'post',
                            parameters: 'function=delRegistration&rid=' + rid,
                            requestHeaders: {Accept: 'application/json'},
                            onSuccess: function (request) {
                                response = request.responseText.evalJSON();
                                if (typeof response.success === 'number' && response.success === 1) {
                                    g.info(response.message, {header: ' ', life: 5, speedout: 2});
                                    patients.getRegistrations(id);
                                } else {
                                    if (typeof response.message !== 'undefined') {
                                        g.error(response.message, {header: ' ', life: 5, speedout: 2});
                                    } else {
                                        g.error("An un-expected error occured while deleting record.", {header: ' ', life: 5, speedout: 2});
                                    }
                                }
                            }
                        });
                    }
                },
                manageRegistration: function (rid, id, ptNo) {
                    module.execute('manageRegistration', "rid=" + rid + '&id=' + id + '&ptNo=' + ptNo, 'divRegistrations');
                }
            };

            var registration = {
                manageBill: function (rid, id, regNo, ptNo) {
                    module.execute('manageBill', 'rid='+rid+'&id='+id+'&regNo=' + regNo + '&ptNo=' + ptNo, 'dvBills');
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
                                afterUpdateElement : registration.setItem
                            });
                    }
                },
                setItem: function(text, item){
                    if(item.id !== ''){
                        if($('itemNoHd')) $('itemNoHd').value= item.id;
                        registration.getItemProfile(item.id);
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
                                if(typeof response.price !== 'undefined' && $('price')) $('price').value = response.price;
                                if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                                
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
                getItemTotalAmount: function(){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getItemTotalAmount&'+ Form.serialize('frmBill'),
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            
                            if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                            
                        }
                    });
                },
                saveBill: function(required){
                    var data = Form.serialize('frmBill');
                    var amount = $('amount')? $F('amount'): '';
                    data = data+ '&amount='+ amount;
                    if(module.validate(required)){
                        if($('frmModule'))  $('frmModule').disabled = true;  
                        if($('btnSave')) $('btnSave').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=saveBill&'+data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    
                                    if(typeof response.billNo !== 'undefined'){
                                        if($('billNo')) $('billNo').value = response.billNo;
                                        if($('billNoHd')) $('billNoHd').value = response.billNo;
                                    }
                                    
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    if($('dvPyEntries')) registration.getPyEntries(response.billNo);
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
                listBills: function(){
                    let id = $F('id');
                    module.execute('listBills', 'id='+ id, 'dvBills');
                },
                getPyEntries: function(billNo=''){
                    if(billNo === ''){
                        billNo = $F('billNo');
                    }
                    module.execute('getPyEntries', 'billNoHd='+ billNo, 'dvPyEntries');
                },
                editBill: function(id, rid, bid, billNoHd, regNo, ptNo){
//                    module.execute('manageBill', 'id='+ id+ '&bid='+ bid+ '&billNoHd='+ billNoHd, 'dvBills');
                    module.execute('manageBill', 'id='+id+'&rid='+ rid+ '&bid='+ bid+ '&billNoHd='+ billNoHd+'&regNo=' + regNo + '&ptNo=' + ptNo, 'dvBills');
                },
                editPyDtls: function(sid){
                    new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=editPyDtls&sid='+ sid,
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
                                    if($('dvPyEntries')) registration.getPyEntries();
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
                print: function(billNo){
                    var printWindow = window.open(
                            './print?billNo='+ billNo, '', 'height=464, width=525, toolbar=no, menubar=no, directories=no, location=no, scrollbars=yes, status=no, resizable=no, fullscreen=no, top=200, left=200');
                    printWindow.focus();
                },
                printLab: function(required){
                    var data = Form.serialize('frmLab');
                    if(module.validate(required)){
                        var printWindow = window.open(
                            './print_lab?'+ data, '', 'height=500, width=750, toolbar=no, menubar=no, directories=no, location=no, scrollbars=yes, status=no, resizable=no, fullscreen=no, top=200, left=200');
                        printWindow.focus();
                    }
                },
                uploadLabItem: function(required){
                    if(module.validate(required)){
                        var frmModule = $('frmLabDoc');
                        var data = frmModule.serialize()+ '&'+ Form.serialize('frmLab');
                        frmModule.action = "./upload/?"+ data;
                        frmModule.submit();
                    }
                },
                getUploadResponse: function(errorCount, errorMsg){
                    if(typeof errorCount !== 'undefined' && errorCount > 0){
                        g.error(errorMsg, { header : ' ' , life: 5, speedout: 2 });
                    }else{
                        g.info("Attachment successfully uploaded", { header : ' ' , life: 5, speedout: 2 });
//                        dashboard.getLab($F('regNo'));
                    }
                },
                saveVitals: function(required, rid, id, regNo, ptNo){
                    var data = Form.serialize('frmVitals');
                    data = data + '&rid='+ rid+ '&id='+ id+ '&regNo='+ regNo+ '&ptNo='+ ptNo;
                    if(module.validate(required)){
                        if($('frmVitals'))  $('frmVitals').disabled = true;  
                        if($('btnSaveVitals')) $('btnSaveVitals').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=saveVitals&'+data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("Oops! An unexpected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
			});
                        if($('frmVitals')) { $('frmVitals').disabled = false; }
                        if($('btnSaveVitals')) { $('btnSaveVitals').disabled = false;}
                    }
                }
            };
            
            var dashboard = {
                addComplaint: function(rid, id, regNo, ptNo){
                    module.execute('addComplaint', "rid="+rid+"&id="+id+"&regNo="+regNo+"&ptNo="+ptNo, 'divComplaints');
                },
                saveComplaint: function(required){
                    if(module.validate(required)){
                        if($('frmComplaint'))  $('frmComplaint').disabled = true;  
                        if($('btnSaveComplaint')) $('btnSaveComplaint').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=saveComplaint&'+ Form.serialize("frmComplaint"),
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success === 'number' && response.success===1){
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
                        if($('frmComplaint')) { $('frmComplaint').disabled = false; }
                        if($('btnSaveComplaint')) { $('btnSaveComplaint').disabled = false;}
                    }
                },
                getComplaints: function(rid, id, regNo, ptNo){
                    module.execute('getComplaints', "rid="+rid+"&id="+id+"&regNo="+regNo+"&ptNo="+ptNo, 'divComplaints');
                },
                editComplaint: function(cid, rid, id, regNo, ptNo){
                    module.execute('addComplaint', "cid="+cid+ "&rid="+rid+"&id="+id+"&regNo="+regNo+"&ptNo="+ptNo, 'divComplaints');
                },
                delComplaint: function(cid, name, regNo, rid, id, ptNo){
                    if(confirm("Delete '"+name+"'?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=delComplaint&cid='+ cid,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    dashboard.getComplaints(rid, id, regNo, ptNo);
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
                addLab: function(regNo){
                    module.execute('addLab', "regNo="+regNo, 'divLab');
                },
                saveLab: function(required){
                    if(module.validate(required)){
                        if($('frmLab'))  $('frmLab').disabled = true;  
                        if($('btnSaveLab')) $('btnSaveLab').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=saveLab&'+ Form.serialize("frmLab"),
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success === 'number' && response.success===1){
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
                        if($('frmLab')) { $('frmLab').disabled = false; }
                        if($('btnSaveLab')) { $('btnSaveLab').disabled = false;}
                    }
                },
                getLab: function(regNo){
                    module.execute('getLab', "regNo="+regNo, 'divLab');
                },
                editLab: function(id){
                    module.execute('addLab', "rid="+id, 'divLab');
                },
                delLab: function(id, name, regNo){
                    if(confirm("Delete '"+name+"'?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=delLab&rid='+ id,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    dashboard.getLab(regNo);
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
                addDiagnosis: function(regNo){
                    module.execute('addDiagnosis', "regNo="+regNo, 'divDiagnosis');
                },
                searchDiagnosis: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'diagnosisDiv';
                        new Ajax.Autocompleter(
                                'diagnosis', getResultTo, module.ajaxUrl,{
                                paramName  : 'diagnosisHd',
                                parameters : 'function=searchDiagnosis',
                                minChars   : 2,
                                frequency  : 1.0,
                                afterUpdateElement : dashboard.setDiagnosis
                            });
                    }
                },
                setDiagnosis: function(text, item){
                    if(item.id !== ''){
                        if($('diagnosisHd')) $('diagnosisHd').value= item.id;
                        dashboard.getDiagnosisProfile(item.id);
                    }
                },
                getDiagnosisProfile: function(diagnosis){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getDiagnosisProfile&diagnosis='+ diagnosis,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
                                if(typeof response.diagnosis !== 'undefined' && $('diagnosis')) $('diagnosis').value = (response.diagnosis);
                                if(typeof response.diagName !== 'undefined' && $('diagName')) $('diagName').value = (response.diagName);
//                                if(typeof response.itemName !== 'undefined' && $('tdItemName')) $('tdItemName').update(response.itemName);
//                                if(typeof response.quantity !== 'undefined' && $('quantity')) $('quantity').value = response.quantity;
//                                if(typeof response.price !== 'undefined' && $('price')) $('price').value = response.price;
//                                if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                                
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
                saveDiagnosis: function(required){
                    if(module.validate(required)){
                        if($('frmDiagnosis'))  $('frmDiagnosis').disabled = true;  
                        if($('btnSaveDiagnosis')) $('btnSaveDiagnosis').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=saveDiagnosis&'+ Form.serialize("frmDiagnosis"),
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success === 'number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  }); 
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("An un-expected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
			});
                        if($('frmDiagnosis')) { $('frmDiagnosis').disabled = false; }
                        if($('btnSaveDiagnosis')) { $('btnSaveDiagnosis').disabled = false;}
                    }
                },
                getDiagnosis: function(regNo){
                    module.execute('getDiagnosis', "regNo="+regNo, 'divDiagnosis');
                },
                editDiagnosis: function(id){
                    module.execute('addDiagnosis', "rid="+id, 'divDiagnosis');
                },
                delDiagnosis: function(id, name, regNo){
                    if(confirm("Delete '"+name+"'?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=delDiagnosis&rid='+ id,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    dashboard.getDiagnosis(regNo);
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
                },
                addMedication: function(regNo){
                    module.execute('addMedication', "regNo="+regNo, 'divMedication');
                },
                searchDrug: function(){
                    var count = Ajax.activeRequestCount;
                    if(count <= 0){
                        var getResultTo = 'drugDiv';
                        new Ajax.Autocompleter(
                                'drug', getResultTo, module.ajaxUrl,{
                                paramName  : 'drugHd',
                                parameters : 'function=searchDrug',
                                minChars   : 2,
                                frequency  : 1.0,
                                afterUpdateElement : dashboard.setDrugItem
                            });
                    }
                },
                setDrugItem: function(text, item){
                    if(item.id !== ''){
                        if($('drugHd')) $('drugHd').value= item.id;
                        dashboard.getDrugItemProfile(item.id);
                    }
                },
                getDrugItemProfile: function(itemNo){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=getDrugItemProfile&itemNo='+ itemNo,
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success === 'number' && response.success === 1){
                                
//                                if(typeof response.itemName !== 'undefined' && $('tdItemName')) $('tdItemName').update(response.itemName);
                                if(typeof response.itemName !== 'undefined' && $('drugName')) $('drugName').value = (response.itemName);
//                                if(typeof response.quantity !== 'undefined' && $('quantity')) $('quantity').value = response.quantity;
//                                if(typeof response.price !== 'undefined' && $('price')) $('price').value = response.price;
//                                if(typeof response.amount !== 'undefined' && $('amount')) $('amount').value = response.amount;
                                
//                                dashboard.getItemPhoto(itemNo);
                                
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
                saveMedication: function(required){
                    if(module.validate(required)){
                        if($('frmMedication'))  $('frmMedication').disabled = true;  
                        if($('btnSaveMedication')) $('btnSaveMedication').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=saveMedication&'+ Form.serialize("frmMedication"),
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success === 'number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  }); 
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("An un-expected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
			});
                        if($('frmMedication')) { $('frmMedication').disabled = false; }
                        if($('btnSaveMedication')) { $('btnSaveMedication').disabled = false;}
                    }
                },
                getMedication: function(regNo){
                    module.execute('getMedication', "regNo="+regNo, 'divMedication');
                },
                editMedication: function(id){
                    module.execute('addMedication', "rid="+id, 'divMedication');
                },
                delMedication: function(id, name, regNo){
                    if(confirm("Delete '"+name+"'?")){
                        new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=delMedication&rid='+ id,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success==='number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });
                                    dashboard.getMedication(regNo);
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
                },
                saveDrNotes: function(required){
                    var data = Form.serialize('frmDrNotes');
                    if(module.validate(required)){
                        if($('frmDrNotes'))  $('frmDrNotes').disabled = true;  
                        if($('btnSave')) $('btnSave').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=saveDrNotes&'+data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success === 'number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  }); 
                                    if(typeof response.receiptNo !== 'undefined' && $('receiptNo')) $('receiptNo').value = response.receiptNo;
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("Un-expected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
			});
                        if($('frmDrNotes')) { $('frmDrNotes').disabled = false; }
                        if($('btnSave')) { $('btnSave').disabled = false;}
                    }
                },
                printDrNotes: function(required){
                    var data = Form.serialize('frmDrNotes');
                    if(module.validate(required)){
                        var printWindow = window.open(
                            './print_dr_notes?'+ data, '', 'height=500, width=750, toolbar=no, menubar=no, directories=no, location=no, scrollbars=yes, status=no, resizable=no, fullscreen=no, top=200, left=200');
                        printWindow.focus();
                    }
                },
                discharge: function(required){
                    var data = Form.serialize('frmDischarge');
                    if(module.validate(required)){
                        if($('frmDischarge'))  $('frmDischarge').disabled = true;  
                        if($('btnDischarge')) $('btnDischarge').disabled = true; 
			
			new Ajax.Request(module.ajaxUrl ,{
                            method:'post',
                            parameters: 'function=discharge&'+data,
                            requestHeaders: { Accept: 'application/json'},
                            onSuccess: function(request) {
                                response = request.responseText.evalJSON();
                                if(typeof response.success === 'number' && response.success===1){
                                    g.info(response.message, { header : ' ' ,life: 5, speedout: 2  }); 
//                                    if(typeof response.receiptNo !== 'undefined' && $('receiptNo')) $('receiptNo').value = response.receiptNo;
                                }else{
                                    if(typeof response.message !== 'undefined'){
                                        g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                    }else{
                                        g.error("Un-expected error occured while saving record.", { header : ' ' ,life: 5, speedout: 2 });
                                    }
                                }
                            }
			});
                        if($('frmDischarge')) { $('frmDischarge').disabled = false; }
                        if($('btnDischarge')) { $('btnDischarge').disabled = false;}
                    }
                }
            };

        </script>
    </body>
</html>