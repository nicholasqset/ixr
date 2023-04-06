<%@page import="com.qset.gui.*"%>
<%
    Gui gui = new Gui();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Home</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "module"));
        %>
        <style>
            div.home{
                text-align: center;
                vertical-align: middle;
                margin: 12% 13%;
                color: #3166A6;
                font-weight: bold;
            }
/*            div.home{
                text-align: center;
                vertical-align: middle;
                margin: 12% 13%;
                color: #3166A6;
                font-weight: bold;
                background-image: url("../../../assets/img/tm/tm.png");
                background-size: 96px 96px;
            }*/
            div.home .ui-lk{
                
            }
            
            div.home .ui-lk a{
                display: block;
                text-decoration: none;
                background: #4E9CAF;
                padding: 25px 25px;
                border-radius: 5px;
                width: 400px;
            }
            
            div.home .ui-lk ul{
                list-style-type: none;
            }
            
            div.home .ui-lk li{
                padding: 10px;
                margin: 10px;                
            }
        </style>
    </head>
    <body>
        <div class="module-wrapper ">
            <div class="module-header">
                <div class="module-header-row">
                    <div id="module-header-row-left"></div>
                    <div id="module-header-row-right"></div>
                </div>
            </div>

            <div id="module-content">
                <div id="content-row">
                    <div id="content-cell">
                        <div id="module"><%=gui.formAjaxIcon(request.getContextPath(),"ajax-loader.gif") %></div>
                    </div>
                </div>
            </div>
        </div>
        
        <%
            out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype"));
            out.print(gui.loadJs(request.getContextPath(), "scriptaculous/src/scriptaculous"));
            out.print(gui.loadJs(request.getContextPath(), "module"));
        %> 
        <script type="text/javascript">
            
            Event.observe(window,'load',function(){home.getModule();});
            
            var home = {
                getModule:function(){
                  if(parent.$('content-header')) parent.$('content-header').innerHTML = 'Home';
                   module.getModule();
                }
            }
            
        </script>
        
    </body>
    
</html>