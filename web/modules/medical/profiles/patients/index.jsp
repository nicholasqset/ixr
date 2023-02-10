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
                        var frmModule = $('frmModule')
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
                    if (ptNo != '') {
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
                addRegistration: function(id, ptNo){
                    module.execute('addRegistration', "id="+id+"&ptNo="+ptNo, 'divRegistrations');
                },
                getRegistrations: function(id){
                    module.execute('getRegistrations', "id="+id+"&ptNo="+ptNo, 'divRegistrations');
                }
            };

        </script>
    </body>
</html>