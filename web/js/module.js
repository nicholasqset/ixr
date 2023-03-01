/* 
 * author: Nicholas Gakumo
 */

var module = {
    ajaxUrl: './parser.jsp',
    /*menuUrl: './menu.jsp',*/
    procUrl: './processor.jsp',
    execute: function(callMethod, parameters, domTarget){
        if($(domTarget)){
            var domTargetNode = $(domTarget).nodeName;
            if(domTargetNode === 'DIV' || domTargetNode === 'SPAN' || domTargetNode === 'TD'){
                new Ajax.Request(this.ajaxUrl,{
                    method: 'post',
                    parameters: 'function='+callMethod+'&'+parameters,
                    onSuccess: function(request){
                        Element.update(domTarget, request.responseText);
                    },
                    onFailure: function(request){
                        alert('An Unhandled Error Occurred');
                        window.top.location  = top.location.href;
                    },
                    on403: function(request){
                        alert("Your session expired. Login again to continue.");
                        window.top.location  = top.location.href;
                    },
                    onException: function(request, Exception){
                        alert('An Unhandled Exception Occurred');
                        window.top.location  = top.location.href;
                    }
                });
            }else{
                alert('Only DIV, SPAN or TD Dom elements that are valid.');
            }
        }else{
            alert('Unable to get the DOM element.');
        }
    },
    getModule: function(){
        this.execute('getModule', '', 'module');
    },
    validate: function(fields){
        var elsClass;
        var elIndex; 
        var targetNode; 
        var elLabel;
        var elLabeltext; 
        var emptyFields = new Array;
        var countEmptyFields = 0;
        var els = '';
        var ares;
		 
        elsClass = $w(fields);
		 
        if(elsClass.length >0){
            elIndex = 0;
            elsClass.each(function(field){
                ++elIndex;
                if($(field)){
                    if ($F(field)===''){
                        targetNode = $(field).nodeName;
                        elLabel = $$('label[for='+field+']');
                        if(typeof elLabel[0] ==='object'){
                            elLabeltext = elLabel[0].innerHTML;
                            if( elLabeltext !==''){
                                emptyFields[elIndex] = elLabeltext;
                            }else{
                                emptyFields[elIndex] = field;
                            }
                        }else{
                            emptyFields[elIndex] = field;
                        }
		 		  
                        switch(targetNode) {
                            case 'INPUT':
                            case 'TEXTAREA':
                                new Effect.Highlight(field,{duration:4});
                                break;
                        }
                    }
                }
            });
        }
		  
        if(emptyFields.length>0){
            emptyFields.each(function(fld){
                els = els+'\n  - '+fld;
                ++countEmptyFields;
            });
            ares = countEmptyFields > 1 ? 's are' : ' is';
            alert('The Following '+countEmptyFields+' field'+ares+' required: '+els);
            return false;
        }
        return true;
    },
    getGrid: function(){
        this.execute('getGrid', '', 'module');
    },
    gridNext:function(){
        if($('startRecord')){
            if(Number($F('startRecord'))<Number($F('totalRecord'))){
                this.execute('getGrid', 'useGrid=1&gridAction=gridNext&maxRecord='+$F('maxRecord'), 'module');
            }else{
                alert('On last page!');
            }
        }
    },
    gridPrevious:function(){
        if($('startRecord')){
            if(Number($F('startRecord')) !== Number($F('maxRecord'))){
                this.execute('getGrid','useGrid=1&gridAction=gridPrevious&maxRecord='+$F('maxRecord'),'module');
            }else{
                alert('On first page!');
            }
        }
    },
    gridFirst:function(){
        if($('startRecord')){
            if(Number($F('startRecord')) !== Number($F('maxRecord'))){
                this.execute('getGrid','useGrid=1&gridAction=gridFirst&maxRecord='+$F('maxRecord'),'module');
            }else{
                alert('On first page!');
            }
        }
    },
    gridLast:function(){
        if($('startRecord')){
            if(Number($F('startRecord'))<Number($F('totalRecord'))){
                this.execute('getGrid','useGrid=1&gridAction=gridLast&maxRecord='+$F('maxRecord'),'module');
            }else{
                alert('On last page!');
            }
        }
    },
    editModule: function(id){
        this.execute('getModule', 'id='+ id, 'module');
    },
    find:function(){
        this.execute('getGrid', 'act=find&find='+$F('txtFind'), 'module');
        TINY.box.hide();
    },
    getSelectFieldText: function(selectField){
        var selectFieldText = '';
        if($(selectField)){
            if($F(selectField).trim() !== ''){
                var i = $(selectField).selectedIndex;
                if(i >= 0){
                    selectFieldText =  $(selectField).options[i].text;
                }
            }
        }
        return selectFieldText;
    }
    
};