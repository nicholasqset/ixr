<%@page import="bean.gui.Gui"%>
<%
    Gui gui = new Gui();
    
    String feedback = "&nbsp;";
    
    String message = request.getParameter("m");
    
    if(message != null && ! message.equals("") && ! message.equals("ok")){
        feedback = message;
    }
    
    String rootPath = "./";
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" href="<%= rootPath %>favicon.ico" />
        <title>Welcome to iXR&trade; - Login or Sign Up</title>

        <% 
//            out.print(gui.loadCss(request.getContextPath(), "login"));
            out.print(gui.loadCss(request.getContextPath(), "bootstrap"));
        %>
      
    </head>
    <body class="bg-default">
     
        <%
            out.print(gui.formStart("frmLogin", "void%200", "post", "onSubmit=\"javascript:return false;\""));
        %>
        <div class="container">
            <div class="row" style="margin-top: 10%">
<!--                <div class="col-md-4">
                    
                </div>-->
                
                <div class="offset-md-3 col-md-5 card card-footer" style="background-color:#eceff1; border-radius: 5px ">
                    <div class="cont-headers">
                        <h1>Login to iXR &trade; ERP</h1>
                        <div id="feedback" class="feedback" style="color: red;font-weight: bolder"><%= feedback %></div>

                        <div class="hr"></div>
                    </div>
            
                    <div class="cont-inputs">
                        <div>
                            <span class="inputs-lbl"><% out.print(gui.formIcon(request.getContextPath(),"user-properties.png", "", "")); %> <% out.print(gui.formLabel("userId", "Email"));%></span>
                            <span class="inputs-ia"><input type="text" name="userId" id="userId" class="form-control"  ></span>
                        </div>

                        <div>
                            <span class="inputs-lbl"><% out.print(gui.formIcon(request.getContextPath(),"user-password.png", "", "")); %> <% out.print(gui.formLabel("password", "Password"));%></span>
                            <span class="inputs-ia"><input type="password" name="password" id="password" class="form-control"></span>
                            <br>
                        </div>
                    </div>
                <div class="cont-actions">
                    <div>
                        <span class="inputs-lbl">&nbsp;</span>
                            <span class="inputs-ia"><% out.print(gui.formButton(request.getContextPath(), "button", "btnLogin", "Login", "go-next-view.png", "onclick = \"login.auth();\"", "btn-info")); %></span>
                    </div>
                </div>
                    
                    <p style="text-align: center; padding-top: 20px;">Don't have an account yet?<br>
                        Click <a href="./register/" style="font-weight: bolder">here to register</a></p>
                    <p style="text-align: center">Forgot password?
                        Click <a href="resetpwd" style="font-weight: bolder">here</a>
                    </p>
                    <p style="text-align: center;">
                        <a href="https://www.qset.co.ke/#contact" target="_blank" style="color: #808080; font-size: 14px;">Inquire</a>
                    </p>
                </div>
            </div>
        
            <div class="cont-footers">
                
            </div>
                
        </div>
                
        <%
            out.print(gui.formEnd());
        %>
        <% 
            out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype"));
            out.print(gui.loadJs(request.getContextPath(), "login"));
        %>
    </body>
</html>