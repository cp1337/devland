//mmmhmhm, have a cookie?
var Cookies = {
	init: function () {
		var allCookies = document.cookie.split('; ');
		for (var i=0;i<allCookies.length;i++) {
			var cookiePair = allCookies[i].split('=');
			this[cookiePair[0]] = cookiePair[1];
		}
	},
	get: function (cookie_name)
	{
	  var results = document.cookie.match ( cookie_name + '=(.*?)(;|$)' );

	  if ( results )
	    return ( unescape ( results[1] ) );
	  else
	    return null;
	},
	create: function (name,value,days) {
		if (days) {
			var date = new Date();
			date.setTime(date.getTime()+(days*24*60*60*1000));
			var expires = "; expires="+date.toGMTString();
		}
		else var expires = "";
		document.cookie = name+"="+value+expires+"; path=/";
		this[name] = value;
	},
	erase: function (name) {
		this.create(name,'',-1);
		this[name] = undefined;
	}
}
Cookies.init();

//Simple _POST AJAX
	function ajax_init()
	{
		try
		{
			//Normal browsers
			http_request=new XMLHttpRequest();
		}
		catch (e)
		{
			//Stupid explorer... can't support fucking standarts
			try
			{
				http_request=new ActiveXObject("Msxml2.XMLHTTP");
			}
			catch (e)
			{
				try
				{
					http_request=new ActiveXObject("Microsoft.XMLHTTP");
				}
				catch (e)
				{
					alert("Your browser does not support AJAX!");
					return false;
				}
			}
		}
		return http_request;
	}

//this loads html content between element_id tags. warn displays loading message.
   function ajax(element_id, script_url, get, warn) {

	http_request = ajax_init();
	if (!http_request){
		window.location.href=script_url+'?'+encodeURI(get);
	}
	if (warn) {
		document.getElementById(element_id).innerHTML = '<div style="z-index: 10; position: absolute; background-color: #660000; color:white;">Loading... Please wait or click <a style="color: white;" href="'+script_url+'?'+encodeURI(get)+'">here</a></div>' + document.getElementById(element_id).innerHTML;
	}

    http_request.onreadystatechange = function()
    {
        if (http_request.readyState == 4) {
            if (http_request.status == 200) {
				document.getElementById(element_id).innerHTML = http_request.responseText;
				if (element_id == 'form'){
					ticker = 0;
					document.getElementById('iobox').style.left = Cookies.get('iobox_x');
					document.getElementById('iobox').style.top = Cookies.get('iobox_y');
					document.getElementById('iobox').style['visibility'] = 'visible';
				}
            }else if(warn){
              alert('Server failed to load script: \n'+script_url+'\nError: '+http_request.status);
            }
        }
    }
    parameters = encodeURI(get) + '&ajax=true';
    http_request.open('POST', script_url, true);
    http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    http_request.setRequestHeader("Content-length", parameters.length);
    http_request.setRequestHeader("Connection", "close");
    http_request.send(parameters);
   }

function getRef(obj){
		return (typeof obj == "string") ?
			 document.getElementById(obj) : obj;
}

function setStyle(obj,style,value){
		getRef(obj).style[style]= value;
}

// found on some website, no idea how it works :D :D
function startDrag(e){
 // determine event object
 if(!e){var e=window.event};
 // determine target element
 var targ=e.target?e.target:e.srcElement;
 if(targ.className!='draggable'){return};
 // calculate event X,Y coordinates
    offsetX=e.clientX;
    offsetY=e.clientY;
 // assign default values for top and left properties
 if(!targ.style.left){targ.style.left=offsetX+'px'};
 if(!targ.style.top){targ.style.top=offsetY+'px'};
 // calculate integer values for top and left properties
    coordX=parseInt(targ.style.left);
    coordY=parseInt(targ.style.top);
    drag_node=targ;
 // move element
    document.onmousemove=dragDiv;
	document.onmouseup=stopDrag;
}
// continue dragging
function dragDiv(e){
 if(!e){var e=window.event};
 if(!drag_node){return};
 // move element
 drag_node.style.left=coordX+e.clientX-offsetX+'px';
 drag_node.style.top=coordY+e.clientY-offsetY+'px';
 return false;
}
// stop dragging
function stopDrag(){
 drag_node=null;
}
document.onmousedown=startDrag;

//retrieves input data from element childs
function getParams(obj) {
  var getstr = '';
  for (i=0; i<obj.childNodes.length; i++) {
     if (obj.childNodes[i].tagName == "INPUT") {
        if (obj.childNodes[i].type == "text" || obj.childNodes[i].type == "password") {
           getstr += obj.childNodes[i].name + "=" + obj.childNodes[i].value + "&";
        }
        if (obj.childNodes[i].type == "checkbox") {
           if (obj.childNodes[i].checked) {
              getstr += obj.childNodes[i].name + "=" + obj.childNodes[i].value + "&";
           } else {
              getstr += obj.childNodes[i].name + "=&";
           }
        }
        if (obj.childNodes[i].type == "radio") {
           if (obj.childNodes[i].checked) {
              getstr += obj.childNodes[i].name + "=" + obj.childNodes[i].value + "&";
           }
        }
     }   
     if (obj.childNodes[i].tagName == "SELECT") {
        var sel = obj.childNodes[i];
        getstr += sel.name + "=" + sel.options[sel.selectedIndex].value + "&";
     }
	 if (obj.childNodes[i].tagName == "TEXTAREA") {
        var sel = obj.childNodes[i];
        getstr += sel.name + "=" + sel.value + "&";
     }
     
  }
  return getstr;
}

function calcFlags(){
	var flags = 0;
	var flagNode = document.getElementById('groups');
	for (var i = 0; i < flagNode.elements.length; i++){
		if(flagNode.elements[i].checked){
			flags = flags*1 + flagNode.elements[i].value*1;
		}
	}
	document.getElementById('groups__flags').value = flags;
}

function server_state()
{
	ajax('server_state','status.php','',false);
	setTimeout ("server_state()",60000);
}
setTimeout ("server_state()",60000);