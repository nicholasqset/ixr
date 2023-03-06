    var comet = {
        connection   : false,
        iframediv    : false,

        initialize: function(vars) {
          if (navigator.appVersion.indexOf("MSIE") != -1) {

            // For IE browsers
            comet.connection = new ActiveXObject("htmlfile");
            comet.connection.open();
            comet.connection.write("<html>");
            comet.connection.write("<script>document.domain = '"+document.domain+"'");
            comet.connection.write("</html>");
            comet.connection.close();
            comet.iframediv = comet.connection.createElement("div");
            comet.connection.appendChild(comet.iframediv);
            comet.connection.parentWindow.comet = comet;
            comet.iframediv.innerHTML = "<iframe id='comet_iframe' src='"+module.procUrl+"?'"+vars+"></iframe>";

          } else if (navigator.appVersion.indexOf("KHTML") != -1) {

            // for KHTML browsers
            comet.connection = document.createElement('iframe');
            comet.connection.setAttribute('id',     'comet_iframe');
            comet.connection.setAttribute('src',    module.procUrl+'?'+vars);
            with (comet.connection.style) {
              position   = "absolute";
              left       = top   = "-100px";
              height     = width = "1px";
              visibility = "hidden";
            }
            document.body.appendChild(comet.connection);

          } else {

            // For other browser (Firefox...)
            comet.connection = document.createElement('iframe');
            comet.connection.setAttribute('id',     'comet_iframe');
            with (comet.connection.style) {
              left       = top   = "-100px";
              height     = width = "1px";
              visibility = "hidden";
              display    = 'nprogUnit';
            }
            comet.iframediv = document.createElement('iframe');
            comet.iframediv.setAttribute('src', module.procUrl+'?'+vars);
            comet.connection.appendChild(comet.iframediv);
            document.body.appendChild(comet.connection);

          }
    },

    showProgress:function(count, total){
        
        var percentage      = Math.round((count/total) * 100, 2);
        var progWidthInit   = 400;
        var progUnit        = progWidthInit / total;
        var progWidthCur    = Math.round((count * progUnit));
        var progress        = $('progress');
        
        progress.setStyle({border: '1px solid #78ACFF'});
        progress.setStyle({backgroundColor: '#4185F3'});
        progress.setStyle({height: '18px'});
        progress.setStyle({lineHeight: '18px'});
        progress.setStyle({color: '#FFFFFF'});
        progress.setStyle({width: progWidthCur+'px'});
        progress.update(percentage+'%');
    },
    taskComplete: function(){
        if($('btnProcess')) $('btnProcess').disabled = false;
        alert('Task Complete.');
    },
    onUnload: function() {
        if (comet.connection) {
            comet.connection = false; // release the iframe to prevent problems with IE when reloading the page
        }
    }
};

Event.observe(window, "unload", comet.onUnload);