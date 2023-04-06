var login = {
    auth:function(){
        var frmLogin    = $('frmLogin');
        var userId      = $F('userId');
        var password    = $F('password');

        if(userId === ''){
            if($('feedback')) $('feedback').update('Enter Username');
        }else if(password === ''){
            if($('feedback')) $('feedback').update('Enter Password');
        }else{
            frmLogin.action = "./auth/";
            frmLogin.submit();
        }
    }
};