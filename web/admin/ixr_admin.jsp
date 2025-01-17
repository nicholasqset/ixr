
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="com.qset.user.User"%>
<%@page import="com.qset.gui.Gui"%>
<%
    Gui gui     = new Gui();
    //System system     = new System();
  //  Menu menu   = new Menu();
  //  User user   = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
    
    Calendar calendar = Calendar.getInstance();
    SimpleDateFormat dateFormat     = new SimpleDateFormat("yyyy");
    
//    String companyCode = system.getOne("qset.CSCOPROFILE", "COMPANYCODE", "");
//    Company company = new Company(companyCode);
    
    String rootPath = "./";
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>iXR&trade; 1.1 -</title>  
        <link href="../css/bootstrap.min.css" type="text/css">
        <link rel="shortcut icon" href="favicon.ico" />
        <% 
            out.print(gui.loadCss(request.getContextPath(), "Growler"));
            out.print(gui.loadCss(request.getContextPath(), "container"));
            out.print(gui.loadCss(request.getContextPath(), "menu"));
        %>
      
    </head>
    <body>
        <div class="header"> 
            <div class="header-body-wrapper">
                <div class="header-body-row">
                    <div class="header-left">
                        iXR&trade; MIS
                    </div>
					
                    <div class="header-center" >
                        <a href = "javascript:;"  onclick="container.toggleUsrOpt();"><%= gui.formIcon(request.getContextPath(), "bullet-arrow-down-2.png", "", "") %></a>
                        <div id="usr_opt" style="display: none">
    
                            <ul>
                                <li><a href = "./admin/profile/" target="content-iframe"><%=gui.formIcon(request.getContextPath(), "user-identity.png", "", "") %> Profile</a></li>
                              
                                <li><a href = "./?act=logout" target="_top"><%=gui.formIcon(request.getContextPath(), "arrow-step-out.png", "", "") %> Sign Out</a></li>
                            </ul>
                        </div>
                    </div>	
                        <div class="header-right">
                            &nbsp;
                        </div>
                </div>
            </div>
        </div> 
        <div class="content-body-wrapper"> 
            <div class="content-body"> 
                <div id="primary-nav">
                    <div class="menu-header">
                        <div class="menu-header-row">
                            <div class="menu-header-left">Navigation</div>
                          
                            
<!--                            <div class="menu-header-right"><%= gui.formHref("onclick = \"container.reloadMenu();\"", request.getContextPath(), "reload.png", "", "Reload Menu", "", "") %></div>
                         -->
                            <div class="menu-header-right">
                              
                            </div>
                        
                        </div>
                    </div>
                    <div id="menu">
                        <div class="menu-s1">
                               <nav class="navbar navbar-expand-sm bg-light">

  <!-- Links -->
  <ul class="navbar-nav">
    <li class="nav-item">
        <a class="nav-link" href="companies"  target="content-iframe"><%=gui.formIcon(request.getContextPath(), "user-identity.png", "", "") %> Companies</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="subscriptions"  target="content-iframe"><%=gui.formIcon(request.getContextPath(), "user-identity.png", "", "") %>Subscriptions</a>
    </li>
    <li class="nav-item">
     <a href = "subscriptions" target="content-iframe"><%=gui.formIcon(request.getContextPath(), "user-identity.png", "", "") %> Registrations</a>
    </li>
  </ul>

</nav>
                        </div>
                                                             
                        <div>&nbsp;</div>
   
                    </div>
                </div> 
                <div id="secondary-nav">
                    <span onclick="container.toggleContent()">
                       <%=gui.formIcon(request.getContextPath(), "close-menu.png", "img_content_span", "Click to close main menu") %>
                    </span>
                </div> 
                <div class="content"> 
                       
                    <div id="content-header">&nbsp;</div>
                	<div class="content-wrapper-iframe">
                           
                            <iframe name="content-iframe" id="content-iframe" frameborder="0" marginheight="0" marginwidth="0" scrolling="auto" src="./../modules/system/home" allowtransparency="100%" >
                         
                            </iframe>
                      
                        </div>
                </div> 
            </div> 
        </div> 
        <div class="footer"> 
            iXR &trade; 2011 - <%= dateFormat.format(calendar.getTime()) %>. All rights reserved. Privacy Policy & Terms & Conditions
        </div> 
            <%
                out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype"));
                out.print(gui.loadJs(request.getContextPath(), "scriptaculous/src/scriptaculous"));
                out.print(gui.loadJs(request.getContextPath(), "Growler"));
                out.print(gui.loadJs(request.getContextPath(), "module"));
            %>                                       
	
	<script type="text/javascript">
//            Event.observe(window,'load',function(){container.hidePrimNav();});
            
            var g = new Growler( {location: 'br', width: ''});
            
            var container = {
                iconReload: '<%= gui.formAjaxIcon(request.getContextPath(),"ajax-loader.gif") %>',
                toggleMenu: function(menuCode){
                        var img         = $("img"+menuCode);
                        var imgCollapse = '<%= request.getContextPath() %>/assets/img/menu/minus.gif';
                        var imgExpand   = '<%= request.getContextPath() %>/assets/img/menu/plus.gif';
                        var row         = $('row'+menuCode);
                        var menu        = $("menu"+menuCode);

                        if(menu.style.display === 'none'){
                                row.style.display = '';
                                new Effect.Appear(menu);
                                if(img)img.src = imgCollapse;
                        }else{
                                row.style.display = 'none';
                                menu.style.display = 'none';
                                if(img)img.src = imgExpand;
                        }
                },
                getMenuHeader: function(menuName){
                    if(menuName !== ''){
                        $('content-header').innerHTML=menuName;
                    }
                },
                toggleContent: function(){
                    var img             = $('img_content_span');
                    var mnuContainer    = $('primary-nav');
                    if(mnuContainer.style.display === 'none'){
                        img.src     = "./assets/img/icons/close-menu.png";
                        img.title   = "Click to close main menu";
                        mnuContainer.style.display = '';
                    }else{
                        img.src     = "./assets/img/icons/open-menu.png";
                        img.title   = "Click to open main menu";
                        mnuContainer.style.display='none';
                        new Effect.Highlight('secondary-nav');	
                    }
                },
                toggleUsrOpt: function(){
                    var state = $('usr_opt').style.display;
                    if (state === 'block') {
                        $('usr_opt').style.display = 'none';
                    }else{
                        $('usr_opt').style.display = 'block';
                    }
                },
                reloadMenu: function(){
                    if($('menu')) $('menu').update(this.iconReload);
                    container.checkMenuSession();
                    module.execute('getMenu', '', 'menu');
                },
                checkMenuSession: function(){
                    new Ajax.Request(module.ajaxUrl ,{
                        method:'post',
                        parameters: 'function=checkMenuSession',
                        requestHeaders: { Accept: 'application/json'},
                        onSuccess: function(request) {
                            response = request.responseText.evalJSON();
                            if(typeof response.success==='number' && response.success===1){
                                /*g.info(response.message, { header : ' ' ,life: 5, speedout: 2  });*/
                            }else{
                                window.top.location  = '<%= rootPath %>';
                                if(typeof response.message !== 'undefined'){
                                    g.error(response.message, { header : ' ' ,life: 5, speedout: 2 });
                                }else{
                                    g.error("Un-expected error occured.", { header : ' ' ,life: 5, speedout: 2 });
                                }
                            }
                        }
                    });
                },
                hidePrimNav: function(){
                    var img                     = $('img_content_span');
                    var mnuContainer            = $('primary-nav');
                    img.src                     = "./assets/img/icons/open-menu.png";
                    img.title                   = "Click to open main menu";
                    mnuContainer.style.display  = 'none';
                    new Effect.Highlight('secondary-nav');	
                }
            };
	</script>
    </body>
</html>