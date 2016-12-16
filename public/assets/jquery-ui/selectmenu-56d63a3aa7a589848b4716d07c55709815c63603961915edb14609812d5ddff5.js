!function(e){"function"==typeof define&&define.amd?define(["jquery"],e):e(jQuery)}(function(e){function t(t,i){var r,o,s,a=t.nodeName.toLowerCase();return"area"===a?(r=t.parentNode,o=r.name,!(!t.href||!o||"map"!==r.nodeName.toLowerCase())&&(s=e("img[usemap='#"+o+"']")[0],!!s&&n(s))):(/^(input|select|textarea|button|object)$/.test(a)?!t.disabled:"a"===a?t.href||i:i)&&n(t)}function n(t){return e.expr.filters.visible(t)&&!e(t).parents().addBack().filter(function(){return"hidden"===e.css(this,"visibility")}).length}e.ui=e.ui||{},e.extend(e.ui,{version:"1.11.4",keyCode:{BACKSPACE:8,COMMA:188,DELETE:46,DOWN:40,END:35,ENTER:13,ESCAPE:27,HOME:36,LEFT:37,PAGE_DOWN:34,PAGE_UP:33,PERIOD:190,RIGHT:39,SPACE:32,TAB:9,UP:38}}),e.fn.extend({scrollParent:function(t){var n=this.css("position"),i="absolute"===n,r=t?/(auto|scroll|hidden)/:/(auto|scroll)/,o=this.parents().filter(function(){var t=e(this);return(!i||"static"!==t.css("position"))&&r.test(t.css("overflow")+t.css("overflow-y")+t.css("overflow-x"))}).eq(0);return"fixed"!==n&&o.length?o:e(this[0].ownerDocument||document)},uniqueId:function(){var e=0;return function(){return this.each(function(){this.id||(this.id="ui-id-"+ ++e)})}}(),removeUniqueId:function(){return this.each(function(){/^ui-id-\d+$/.test(this.id)&&e(this).removeAttr("id")})}}),e.extend(e.expr[":"],{data:e.expr.createPseudo?e.expr.createPseudo(function(t){return function(n){return!!e.data(n,t)}}):function(t,n,i){return!!e.data(t,i[3])},focusable:function(n){return t(n,!isNaN(e.attr(n,"tabindex")))},tabbable:function(n){var i=e.attr(n,"tabindex"),r=isNaN(i);return(r||i>=0)&&t(n,!r)}}),e("<a>").outerWidth(1).jquery||e.each(["Width","Height"],function(t,n){function i(t,n,i,o){return e.each(r,function(){n-=parseFloat(e.css(t,"padding"+this))||0,i&&(n-=parseFloat(e.css(t,"border"+this+"Width"))||0),o&&(n-=parseFloat(e.css(t,"margin"+this))||0)}),n}var r="Width"===n?["Left","Right"]:["Top","Bottom"],o=n.toLowerCase(),s={innerWidth:e.fn.innerWidth,innerHeight:e.fn.innerHeight,outerWidth:e.fn.outerWidth,outerHeight:e.fn.outerHeight};e.fn["inner"+n]=function(t){return void 0===t?s["inner"+n].call(this):this.each(function(){e(this).css(o,i(this,t)+"px")})},e.fn["outer"+n]=function(t,r){return"number"!=typeof t?s["outer"+n].call(this,t):this.each(function(){e(this).css(o,i(this,t,!0,r)+"px")})}}),e.fn.addBack||(e.fn.addBack=function(e){return this.add(null==e?this.prevObject:this.prevObject.filter(e))}),e("<a>").data("a-b","a").removeData("a-b").data("a-b")&&(e.fn.removeData=function(t){return function(n){return arguments.length?t.call(this,e.camelCase(n)):t.call(this)}}(e.fn.removeData)),e.ui.ie=!!/msie [\w.]+/.exec(navigator.userAgent.toLowerCase()),e.fn.extend({focus:function(t){return function(n,i){return"number"==typeof n?this.each(function(){var t=this;setTimeout(function(){e(t).focus(),i&&i.call(t)},n)}):t.apply(this,arguments)}}(e.fn.focus),disableSelection:function(){var e="onselectstart"in document.createElement("div")?"selectstart":"mousedown";return function(){return this.bind(e+".ui-disableSelection",function(e){e.preventDefault()})}}(),enableSelection:function(){return this.unbind(".ui-disableSelection")},zIndex:function(t){if(void 0!==t)return this.css("zIndex",t);if(this.length)for(var n,i,r=e(this[0]);r.length&&r[0]!==document;){if(n=r.css("position"),("absolute"===n||"relative"===n||"fixed"===n)&&(i=parseInt(r.css("zIndex"),10),!isNaN(i)&&0!==i))return i;r=r.parent()}return 0}}),e.ui.plugin={add:function(t,n,i){var r,o=e.ui[t].prototype;for(r in i)o.plugins[r]=o.plugins[r]||[],o.plugins[r].push([n,i[r]])},call:function(e,t,n,i){var r,o=e.plugins[t];if(o&&(i||e.element[0].parentNode&&11!==e.element[0].parentNode.nodeType))for(r=0;r<o.length;r++)e.options[o[r][0]]&&o[r][1].apply(e.element,n)}}}),function(e){"function"==typeof define&&define.amd?define(["jquery"],e):e(jQuery)}(function(e){var t=0,n=Array.prototype.slice;return e.cleanData=function(t){return function(n){var i,r,o;for(o=0;null!=(r=n[o]);o++)try{i=e._data(r,"events"),i&&i.remove&&e(r).triggerHandler("remove")}catch(e){}t(n)}}(e.cleanData),e.widget=function(t,n,i){var r,o,s,a,u={},l=t.split(".")[0];return t=t.split(".")[1],r=l+"-"+t,i||(i=n,n=e.Widget),e.expr[":"][r.toLowerCase()]=function(t){return!!e.data(t,r)},e[l]=e[l]||{},o=e[l][t],s=e[l][t]=function(e,t){return this._createWidget?void(arguments.length&&this._createWidget(e,t)):new s(e,t)},e.extend(s,o,{version:i.version,_proto:e.extend({},i),_childConstructors:[]}),a=new n,a.options=e.widget.extend({},a.options),e.each(i,function(t,i){return e.isFunction(i)?void(u[t]=function(){var e=function(){return n.prototype[t].apply(this,arguments)},r=function(e){return n.prototype[t].apply(this,e)};return function(){var t,n=this._super,o=this._superApply;return this._super=e,this._superApply=r,t=i.apply(this,arguments),this._super=n,this._superApply=o,t}}()):void(u[t]=i)}),s.prototype=e.widget.extend(a,{widgetEventPrefix:o?a.widgetEventPrefix||t:t},u,{constructor:s,namespace:l,widgetName:t,widgetFullName:r}),o?(e.each(o._childConstructors,function(t,n){var i=n.prototype;e.widget(i.namespace+"."+i.widgetName,s,n._proto)}),delete o._childConstructors):n._childConstructors.push(s),e.widget.bridge(t,s),s},e.widget.extend=function(t){for(var i,r,o=n.call(arguments,1),s=0,a=o.length;s<a;s++)for(i in o[s])r=o[s][i],o[s].hasOwnProperty(i)&&void 0!==r&&(e.isPlainObject(r)?t[i]=e.isPlainObject(t[i])?e.widget.extend({},t[i],r):e.widget.extend({},r):t[i]=r);return t},e.widget.bridge=function(t,i){var r=i.prototype.widgetFullName||t;e.fn[t]=function(o){var s="string"==typeof o,a=n.call(arguments,1),u=this;return s?this.each(function(){var n,i=e.data(this,r);return"instance"===o?(u=i,!1):i?e.isFunction(i[o])&&"_"!==o.charAt(0)?(n=i[o].apply(i,a),n!==i&&void 0!==n?(u=n&&n.jquery?u.pushStack(n.get()):n,!1):void 0):e.error("no such method '"+o+"' for "+t+" widget instance"):e.error("cannot call methods on "+t+" prior to initialization; attempted to call method '"+o+"'")}):(a.length&&(o=e.widget.extend.apply(null,[o].concat(a))),this.each(function(){var t=e.data(this,r);t?(t.option(o||{}),t._init&&t._init()):e.data(this,r,new i(o,this))})),u}},e.Widget=function(){},e.Widget._childConstructors=[],e.Widget.prototype={widgetName:"widget",widgetEventPrefix:"",defaultElement:"<div>",options:{disabled:!1,create:null},_createWidget:function(n,i){i=e(i||this.defaultElement||this)[0],this.element=e(i),this.uuid=t++,this.eventNamespace="."+this.widgetName+this.uuid,this.bindings=e(),this.hoverable=e(),this.focusable=e(),i!==this&&(e.data(i,this.widgetFullName,this),this._on(!0,this.element,{remove:function(e){e.target===i&&this.destroy()}}),this.document=e(i.style?i.ownerDocument:i.document||i),this.window=e(this.document[0].defaultView||this.document[0].parentWindow)),this.options=e.widget.extend({},this.options,this._getCreateOptions(),n),this._create(),this._trigger("create",null,this._getCreateEventData()),this._init()},_getCreateOptions:e.noop,_getCreateEventData:e.noop,_create:e.noop,_init:e.noop,destroy:function(){this._destroy(),this.element.unbind(this.eventNamespace).removeData(this.widgetFullName).removeData(e.camelCase(this.widgetFullName)),this.widget().unbind(this.eventNamespace).removeAttr("aria-disabled").removeClass(this.widgetFullName+"-disabled ui-state-disabled"),this.bindings.unbind(this.eventNamespace),this.hoverable.removeClass("ui-state-hover"),this.focusable.removeClass("ui-state-focus")},_destroy:e.noop,widget:function(){return this.element},option:function(t,n){var i,r,o,s=t;if(0===arguments.length)return e.widget.extend({},this.options);if("string"==typeof t)if(s={},i=t.split("."),t=i.shift(),i.length){for(r=s[t]=e.widget.extend({},this.options[t]),o=0;o<i.length-1;o++)r[i[o]]=r[i[o]]||{},r=r[i[o]];if(t=i.pop(),1===arguments.length)return void 0===r[t]?null:r[t];r[t]=n}else{if(1===arguments.length)return void 0===this.options[t]?null:this.options[t];s[t]=n}return this._setOptions(s),this},_setOptions:function(e){var t;for(t in e)this._setOption(t,e[t]);return this},_setOption:function(e,t){return this.options[e]=t,"disabled"===e&&(this.widget().toggleClass(this.widgetFullName+"-disabled",!!t),t&&(this.hoverable.removeClass("ui-state-hover"),this.focusable.removeClass("ui-state-focus"))),this},enable:function(){return this._setOptions({disabled:!1})},disable:function(){return this._setOptions({disabled:!0})},_on:function(t,n,i){var r,o=this;"boolean"!=typeof t&&(i=n,n=t,t=!1),i?(n=r=e(n),this.bindings=this.bindings.add(n)):(i=n,n=this.element,r=this.widget()),e.each(i,function(i,s){function a(){if(t||o.options.disabled!==!0&&!e(this).hasClass("ui-state-disabled"))return("string"==typeof s?o[s]:s).apply(o,arguments)}"string"!=typeof s&&(a.guid=s.guid=s.guid||a.guid||e.guid++);var u=i.match(/^([\w:-]*)\s*(.*)$/),l=u[1]+o.eventNamespace,c=u[2];c?r.delegate(c,l,a):n.bind(l,a)})},_off:function(t,n){n=(n||"").split(" ").join(this.eventNamespace+" ")+this.eventNamespace,t.unbind(n).undelegate(n),this.bindings=e(this.bindings.not(t).get()),this.focusable=e(this.focusable.not(t).get()),this.hoverable=e(this.hoverable.not(t).get())},_delay:function(e,t){function n(){return("string"==typeof e?i[e]:e).apply(i,arguments)}var i=this;return setTimeout(n,t||0)},_hoverable:function(t){this.hoverable=this.hoverable.add(t),this._on(t,{mouseenter:function(t){e(t.currentTarget).addClass("ui-state-hover")},mouseleave:function(t){e(t.currentTarget).removeClass("ui-state-hover")}})},_focusable:function(t){this.focusable=this.focusable.add(t),this._on(t,{focusin:function(t){e(t.currentTarget).addClass("ui-state-focus")},focusout:function(t){e(t.currentTarget).removeClass("ui-state-focus")}})},_trigger:function(t,n,i){var r,o,s=this.options[t];if(i=i||{},n=e.Event(n),n.type=(t===this.widgetEventPrefix?t:this.widgetEventPrefix+t).toLowerCase(),n.target=this.element[0],o=n.originalEvent)for(r in o)r in n||(n[r]=o[r]);return this.element.trigger(n,i),!(e.isFunction(s)&&s.apply(this.element[0],[n].concat(i))===!1||n.isDefaultPrevented())}},e.each({show:"fadeIn",hide:"fadeOut"},function(t,n){e.Widget.prototype["_"+t]=function(i,r,o){"string"==typeof r&&(r={effect:r});var s,a=r?r===!0||"number"==typeof r?n:r.effect||n:t;r=r||{},"number"==typeof r&&(r={duration:r}),s=!e.isEmptyObject(r),r.complete=o,r.delay&&i.delay(r.delay),s&&e.effects&&e.effects.effect[a]?i[t](r):a!==t&&i[a]?i[a](r.duration,r.easing,o):i.queue(function(n){e(this)[t](),o&&o.call(i[0]),n()})}}),e.widget}),function(e){"function"==typeof define&&define.amd?define(["jquery"],e):e(jQuery)}(function(e){return function(){function t(e,t,n){return[parseFloat(e[0])*(h.test(e[0])?t/100:1),parseFloat(e[1])*(h.test(e[1])?n/100:1)]}function n(t,n){return parseInt(e.css(t,n),10)||0}function i(t){var n=t[0];return 9===n.nodeType?{width:t.width(),height:t.height(),offset:{top:0,left:0}}:e.isWindow(n)?{width:t.width(),height:t.height(),offset:{top:t.scrollTop(),left:t.scrollLeft()}}:n.preventDefault?{width:0,height:0,offset:{top:n.pageY,left:n.pageX}}:{width:t.outerWidth(),height:t.outerHeight(),offset:t.offset()}}e.ui=e.ui||{};var r,o,s=Math.max,a=Math.abs,u=Math.round,l=/left|center|right/,c=/top|center|bottom/,d=/[\+\-]\d+(\.[\d]+)?%?/,f=/^\w+/,h=/%$/,p=e.fn.position;e.position={scrollbarWidth:function(){if(void 0!==r)return r;var t,n,i=e("<div style='display:block;position:absolute;width:50px;height:50px;overflow:hidden;'><div style='height:100px;width:auto;'></div></div>"),o=i.children()[0];return e("body").append(i),t=o.offsetWidth,i.css("overflow","scroll"),n=o.offsetWidth,t===n&&(n=i[0].clientWidth),i.remove(),r=t-n},getScrollInfo:function(t){var n=t.isWindow||t.isDocument?"":t.element.css("overflow-x"),i=t.isWindow||t.isDocument?"":t.element.css("overflow-y"),r="scroll"===n||"auto"===n&&t.width<t.element[0].scrollWidth,o="scroll"===i||"auto"===i&&t.height<t.element[0].scrollHeight;return{width:o?e.position.scrollbarWidth():0,height:r?e.position.scrollbarWidth():0}},getWithinInfo:function(t){var n=e(t||window),i=e.isWindow(n[0]),r=!!n[0]&&9===n[0].nodeType;return{element:n,isWindow:i,isDocument:r,offset:n.offset()||{left:0,top:0},scrollLeft:n.scrollLeft(),scrollTop:n.scrollTop(),width:i||r?n.width():n.outerWidth(),height:i||r?n.height():n.outerHeight()}}},e.fn.position=function(r){if(!r||!r.of)return p.apply(this,arguments);r=e.extend({},r);var h,m,g,v,y,b,_=e(r.of),x=e.position.getWithinInfo(r.within),w=e.position.getScrollInfo(x),k=(r.collision||"flip").split(" "),T={};return b=i(_),_[0].preventDefault&&(r.at="left top"),m=b.width,g=b.height,v=b.offset,y=e.extend({},v),e.each(["my","at"],function(){var e,t,n=(r[this]||"").split(" ");1===n.length&&(n=l.test(n[0])?n.concat(["center"]):c.test(n[0])?["center"].concat(n):["center","center"]),n[0]=l.test(n[0])?n[0]:"center",n[1]=c.test(n[1])?n[1]:"center",e=d.exec(n[0]),t=d.exec(n[1]),T[this]=[e?e[0]:0,t?t[0]:0],r[this]=[f.exec(n[0])[0],f.exec(n[1])[0]]}),1===k.length&&(k[1]=k[0]),"right"===r.at[0]?y.left+=m:"center"===r.at[0]&&(y.left+=m/2),"bottom"===r.at[1]?y.top+=g:"center"===r.at[1]&&(y.top+=g/2),h=t(T.at,m,g),y.left+=h[0],y.top+=h[1],this.each(function(){var i,l,c=e(this),d=c.outerWidth(),f=c.outerHeight(),p=n(this,"marginLeft"),b=n(this,"marginTop"),C=d+p+n(this,"marginRight")+w.width,D=f+b+n(this,"marginBottom")+w.height,M=e.extend({},y),S=t(T.my,c.outerWidth(),c.outerHeight());"right"===r.my[0]?M.left-=d:"center"===r.my[0]&&(M.left-=d/2),"bottom"===r.my[1]?M.top-=f:"center"===r.my[1]&&(M.top-=f/2),M.left+=S[0],M.top+=S[1],o||(M.left=u(M.left),M.top=u(M.top)),i={marginLeft:p,marginTop:b},e.each(["left","top"],function(t,n){e.ui.position[k[t]]&&e.ui.position[k[t]][n](M,{targetWidth:m,targetHeight:g,elemWidth:d,elemHeight:f,collisionPosition:i,collisionWidth:C,collisionHeight:D,offset:[h[0]+S[0],h[1]+S[1]],my:r.my,at:r.at,within:x,elem:c})}),r.using&&(l=function(e){var t=v.left-M.left,n=t+m-d,i=v.top-M.top,o=i+g-f,u={target:{element:_,left:v.left,top:v.top,width:m,height:g},element:{element:c,left:M.left,top:M.top,width:d,height:f},horizontal:n<0?"left":t>0?"right":"center",vertical:o<0?"top":i>0?"bottom":"middle"};m<d&&a(t+n)<m&&(u.horizontal="center"),g<f&&a(i+o)<g&&(u.vertical="middle"),s(a(t),a(n))>s(a(i),a(o))?u.important="horizontal":u.important="vertical",r.using.call(this,e,u)}),c.offset(e.extend(M,{using:l}))})},e.ui.position={fit:{left:function(e,t){var n,i=t.within,r=i.isWindow?i.scrollLeft:i.offset.left,o=i.width,a=e.left-t.collisionPosition.marginLeft,u=r-a,l=a+t.collisionWidth-o-r;t.collisionWidth>o?u>0&&l<=0?(n=e.left+u+t.collisionWidth-o-r,e.left+=u-n):l>0&&u<=0?e.left=r:u>l?e.left=r+o-t.collisionWidth:e.left=r:u>0?e.left+=u:l>0?e.left-=l:e.left=s(e.left-a,e.left)},top:function(e,t){var n,i=t.within,r=i.isWindow?i.scrollTop:i.offset.top,o=t.within.height,a=e.top-t.collisionPosition.marginTop,u=r-a,l=a+t.collisionHeight-o-r;t.collisionHeight>o?u>0&&l<=0?(n=e.top+u+t.collisionHeight-o-r,e.top+=u-n):l>0&&u<=0?e.top=r:u>l?e.top=r+o-t.collisionHeight:e.top=r:u>0?e.top+=u:l>0?e.top-=l:e.top=s(e.top-a,e.top)}},flip:{left:function(e,t){var n,i,r=t.within,o=r.offset.left+r.scrollLeft,s=r.width,u=r.isWindow?r.scrollLeft:r.offset.left,l=e.left-t.collisionPosition.marginLeft,c=l-u,d=l+t.collisionWidth-s-u,f="left"===t.my[0]?-t.elemWidth:"right"===t.my[0]?t.elemWidth:0,h="left"===t.at[0]?t.targetWidth:"right"===t.at[0]?-t.targetWidth:0,p=-2*t.offset[0];c<0?(n=e.left+f+h+p+t.collisionWidth-s-o,(n<0||n<a(c))&&(e.left+=f+h+p)):d>0&&(i=e.left-t.collisionPosition.marginLeft+f+h+p-u,(i>0||a(i)<d)&&(e.left+=f+h+p))},top:function(e,t){var n,i,r=t.within,o=r.offset.top+r.scrollTop,s=r.height,u=r.isWindow?r.scrollTop:r.offset.top,l=e.top-t.collisionPosition.marginTop,c=l-u,d=l+t.collisionHeight-s-u,f="top"===t.my[1],h=f?-t.elemHeight:"bottom"===t.my[1]?t.elemHeight:0,p="top"===t.at[1]?t.targetHeight:"bottom"===t.at[1]?-t.targetHeight:0,m=-2*t.offset[1];c<0?(i=e.top+h+p+m+t.collisionHeight-s-o,(i<0||i<a(c))&&(e.top+=h+p+m)):d>0&&(n=e.top-t.collisionPosition.marginTop+h+p+m-u,(n>0||a(n)<d)&&(e.top+=h+p+m))}},flipfit:{left:function(){e.ui.position.flip.left.apply(this,arguments),e.ui.position.fit.left.apply(this,arguments)},top:function(){e.ui.position.flip.top.apply(this,arguments),e.ui.position.fit.top.apply(this,arguments)}}},function(){var t,n,i,r,s,a=document.getElementsByTagName("body")[0],u=document.createElement("div");t=document.createElement(a?"div":"body"),i={visibility:"hidden",width:0,height:0,border:0,margin:0,background:"none"},a&&e.extend(i,{position:"absolute",left:"-1000px",top:"-1000px"});for(s in i)t.style[s]=i[s];t.appendChild(u),n=a||document.documentElement,n.insertBefore(t,n.firstChild),u.style.cssText="position: absolute; left: 10.7432222px;",r=e(u).offset().left,o=r>10&&r<11,t.innerHTML="",n.removeChild(t)}()}(),e.ui.position}),function(e){"function"==typeof define&&define.amd?define(["jquery","./core","./widget","./position"],e):e(jQuery)}(function(e){return e.widget("ui.menu",{version:"1.11.4",defaultElement:"<ul>",delay:300,options:{icons:{submenu:"ui-icon-carat-1-e"},items:"> *",menus:"ul",position:{my:"left-1 top",at:"right top"},role:"menu",blur:null,focus:null,select:null},_create:function(){this.activeMenu=this.element,this.mouseHandled=!1,this.element.uniqueId().addClass("ui-menu ui-widget ui-widget-content").toggleClass("ui-menu-icons",!!this.element.find(".ui-icon").length).attr({role:this.options.role,tabIndex:0}),this.options.disabled&&this.element.addClass("ui-state-disabled").attr("aria-disabled","true"),this._on({"mousedown .ui-menu-item":function(e){e.preventDefault()},"click .ui-menu-item":function(t){var n=e(t.target);!this.mouseHandled&&n.not(".ui-state-disabled").length&&(this.select(t),t.isPropagationStopped()||(this.mouseHandled=!0),n.has(".ui-menu").length?this.expand(t):!this.element.is(":focus")&&e(this.document[0].activeElement).closest(".ui-menu").length&&(this.element.trigger("focus",[!0]),this.active&&1===this.active.parents(".ui-menu").length&&clearTimeout(this.timer)))},"mouseenter .ui-menu-item":function(t){if(!this.previousFilter){var n=e(t.currentTarget);n.siblings(".ui-state-active").removeClass("ui-state-active"),this.focus(t,n)}},mouseleave:"collapseAll","mouseleave .ui-menu":"collapseAll",focus:function(e,t){var n=this.active||this.element.find(this.options.items).eq(0);t||this.focus(e,n)},blur:function(t){this._delay(function(){e.contains(this.element[0],this.document[0].activeElement)||this.collapseAll(t)})},keydown:"_keydown"}),this.refresh(),this._on(this.document,{click:function(e){this._closeOnDocumentClick(e)&&this.collapseAll(e),this.mouseHandled=!1}})},_destroy:function(){this.element.removeAttr("aria-activedescendant").find(".ui-menu").addBack().removeClass("ui-menu ui-widget ui-widget-content ui-menu-icons ui-front").removeAttr("role").removeAttr("tabIndex").removeAttr("aria-labelledby").removeAttr("aria-expanded").removeAttr("aria-hidden").removeAttr("aria-disabled").removeUniqueId().show(),this.element.find(".ui-menu-item").removeClass("ui-menu-item").removeAttr("role").removeAttr("aria-disabled").removeUniqueId().removeClass("ui-state-hover").removeAttr("tabIndex").removeAttr("role").removeAttr("aria-haspopup").children().each(function(){var t=e(this);t.data("ui-menu-submenu-carat")&&t.remove()}),this.element.find(".ui-menu-divider").removeClass("ui-menu-divider ui-widget-content")},_keydown:function(t){var n,i,r,o,s=!0;switch(t.keyCode){case e.ui.keyCode.PAGE_UP:this.previousPage(t);break;case e.ui.keyCode.PAGE_DOWN:this.nextPage(t);break;case e.ui.keyCode.HOME:this._move("first","first",t);break;case e.ui.keyCode.END:this._move("last","last",t);break;case e.ui.keyCode.UP:this.previous(t);break;case e.ui.keyCode.DOWN:this.next(t);break;case e.ui.keyCode.LEFT:this.collapse(t);break;case e.ui.keyCode.RIGHT:this.active&&!this.active.is(".ui-state-disabled")&&this.expand(t);break;case e.ui.keyCode.ENTER:case e.ui.keyCode.SPACE:this._activate(t);break;case e.ui.keyCode.ESCAPE:this.collapse(t);break;default:s=!1,i=this.previousFilter||"",r=String.fromCharCode(t.keyCode),o=!1,clearTimeout(this.filterTimer),r===i?o=!0:r=i+r,n=this._filterMenuItems(r),n=o&&n.index(this.active.next())!==-1?this.active.nextAll(".ui-menu-item"):n,n.length||(r=String.fromCharCode(t.keyCode),n=this._filterMenuItems(r)),n.length?(this.focus(t,n),this.previousFilter=r,this.filterTimer=this._delay(function(){delete this.previousFilter},1e3)):delete this.previousFilter}s&&t.preventDefault()},_activate:function(e){this.active.is(".ui-state-disabled")||(this.active.is("[aria-haspopup='true']")?this.expand(e):this.select(e))},refresh:function(){var t,n,i=this,r=this.options.icons.submenu,o=this.element.find(this.options.menus);this.element.toggleClass("ui-menu-icons",!!this.element.find(".ui-icon").length),o.filter(":not(.ui-menu)").addClass("ui-menu ui-widget ui-widget-content ui-front").hide().attr({role:this.options.role,"aria-hidden":"true","aria-expanded":"false"}).each(function(){var t=e(this),n=t.parent(),i=e("<span>").addClass("ui-menu-icon ui-icon "+r).data("ui-menu-submenu-carat",!0);n.attr("aria-haspopup","true").prepend(i),t.attr("aria-labelledby",n.attr("id"))}),t=o.add(this.element),n=t.find(this.options.items),n.not(".ui-menu-item").each(function(){var t=e(this);i._isDivider(t)&&t.addClass("ui-widget-content ui-menu-divider")}),n.not(".ui-menu-item, .ui-menu-divider").addClass("ui-menu-item").uniqueId().attr({tabIndex:-1,role:this._itemRole()}),n.filter(".ui-state-disabled").attr("aria-disabled","true"),this.active&&!e.contains(this.element[0],this.active[0])&&this.blur()},_itemRole:function(){return{menu:"menuitem",listbox:"option"}[this.options.role]},_setOption:function(e,t){"icons"===e&&this.element.find(".ui-menu-icon").removeClass(this.options.icons.submenu).addClass(t.submenu),"disabled"===e&&this.element.toggleClass("ui-state-disabled",!!t).attr("aria-disabled",t),this._super(e,t)},focus:function(e,t){var n,i;this.blur(e,e&&"focus"===e.type),this._scrollIntoView(t),this.active=t.first(),i=this.active.addClass("ui-state-focus").removeClass("ui-state-active"),this.options.role&&this.element.attr("aria-activedescendant",i.attr("id")),this.active.parent().closest(".ui-menu-item").addClass("ui-state-active"),e&&"keydown"===e.type?this._close():this.timer=this._delay(function(){this._close()},this.delay),n=t.children(".ui-menu"),n.length&&e&&/^mouse/.test(e.type)&&this._startOpening(n),this.activeMenu=t.parent(),this._trigger("focus",e,{item:t})},_scrollIntoView:function(t){var n,i,r,o,s,a;this._hasScroll()&&(n=parseFloat(e.css(this.activeMenu[0],"borderTopWidth"))||0,i=parseFloat(e.css(this.activeMenu[0],"paddingTop"))||0,r=t.offset().top-this.activeMenu.offset().top-n-i,o=this.activeMenu.scrollTop(),s=this.activeMenu.height(),a=t.outerHeight(),r<0?this.activeMenu.scrollTop(o+r):r+a>s&&this.activeMenu.scrollTop(o+r-s+a))},blur:function(e,t){t||clearTimeout(this.timer),this.active&&(this.active.removeClass("ui-state-focus"),this.active=null,this._trigger("blur",e,{item:this.active}))},_startOpening:function(e){clearTimeout(this.timer),"true"===e.attr("aria-hidden")&&(this.timer=this._delay(function(){this._close(),this._open(e)},this.delay))},_open:function(t){var n=e.extend({of:this.active},this.options.position);clearTimeout(this.timer),this.element.find(".ui-menu").not(t.parents(".ui-menu")).hide().attr("aria-hidden","true"),t.show().removeAttr("aria-hidden").attr("aria-expanded","true").position(n)},collapseAll:function(t,n){clearTimeout(this.timer),this.timer=this._delay(function(){var i=n?this.element:e(t&&t.target).closest(this.element.find(".ui-menu"));i.length||(i=this.element),this._close(i),this.blur(t),this.activeMenu=i},this.delay)},_close:function(e){e||(e=this.active?this.active.parent():this.element),e.find(".ui-menu").hide().attr("aria-hidden","true").attr("aria-expanded","false").end().find(".ui-state-active").not(".ui-state-focus").removeClass("ui-state-active")},_closeOnDocumentClick:function(t){return!e(t.target).closest(".ui-menu").length},_isDivider:function(e){return!/[^\-\u2014\u2013\s]/.test(e.text())},collapse:function(e){var t=this.active&&this.active.parent().closest(".ui-menu-item",this.element);t&&t.length&&(this._close(),this.focus(e,t))},expand:function(e){var t=this.active&&this.active.children(".ui-menu ").find(this.options.items).first();t&&t.length&&(this._open(t.parent()),this._delay(function(){this.focus(e,t)}))},next:function(e){this._move("next","first",e)},previous:function(e){this._move("prev","last",e)},isFirstItem:function(){return this.active&&!this.active.prevAll(".ui-menu-item").length},isLastItem:function(){return this.active&&!this.active.nextAll(".ui-menu-item").length},_move:function(e,t,n){var i;this.active&&(i="first"===e||"last"===e?this.active["first"===e?"prevAll":"nextAll"](".ui-menu-item").eq(-1):this.active[e+"All"](".ui-menu-item").eq(0)),i&&i.length&&this.active||(i=this.activeMenu.find(this.options.items)[t]()),this.focus(n,i)},nextPage:function(t){var n,i,r;return this.active?void(this.isLastItem()||(this._hasScroll()?(i=this.active.offset().top,r=this.element.height(),this.active.nextAll(".ui-menu-item").each(function(){return n=e(this),n.offset().top-i-r<0}),this.focus(t,n)):this.focus(t,this.activeMenu.find(this.options.items)[this.active?"last":"first"]()))):void this.next(t)},previousPage:function(t){var n,i,r;return this.active?void(this.isFirstItem()||(this._hasScroll()?(i=this.active.offset().top,r=this.element.height(),this.active.prevAll(".ui-menu-item").each(function(){return n=e(this),n.offset().top-i+r>0}),this.focus(t,n)):this.focus(t,this.activeMenu.find(this.options.items).first()))):void this.next(t)},_hasScroll:function(){return this.element.outerHeight()<this.element.prop("scrollHeight")},select:function(t){this.active=this.active||e(t.target).closest(".ui-menu-item");var n={item:this.active};this.active.has(".ui-menu").length||this.collapseAll(t,!0),this._trigger("select",t,n)},_filterMenuItems:function(t){var n=t.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g,"\\$&"),i=new RegExp("^"+n,"i");return this.activeMenu.find(this.options.items).filter(".ui-menu-item").filter(function(){return i.test(e.trim(e(this).text()))})}})}),function(e){"function"==typeof define&&define.amd?define(["jquery","./core","./widget","./position","./menu"],e):e(jQuery)}(function(e){return e.widget("ui.selectmenu",{version:"1.11.4",defaultElement:"<select>",options:{appendTo:null,disabled:null,icons:{button:"ui-icon-triangle-1-s"},position:{my:"left top",at:"left bottom",collision:"none"},width:null,change:null,close:null,focus:null,open:null,select:null},_create:function(){var e=this.element.uniqueId().attr("id");this.ids={element:e,button:e+"-button",menu:e+"-menu"},this._drawButton(),this._drawMenu(),this.options.disabled&&this.disable()},_drawButton:function(){var t=this;this.label=e("label[for='"+this.ids.element+"']").attr("for",this.ids.button),this._on(this.label,{click:function(e){this.button.focus(),e.preventDefault()}}),this.element.hide(),this.button=e("<span>",{"class":"ui-selectmenu-button ui-widget ui-state-default ui-corner-all",tabindex:this.options.disabled?-1:0,id:this.ids.button,role:"combobox","aria-expanded":"false","aria-autocomplete":"list","aria-owns":this.ids.menu,"aria-haspopup":"true"}).insertAfter(this.element),e("<span>",{"class":"ui-icon "+this.options.icons.button}).prependTo(this.button),this.buttonText=e("<span>",{"class":"ui-selectmenu-text"}).appendTo(this.button),this._setText(this.buttonText,this.element.find("option:selected").text()),this._resizeButton(),this._on(this.button,this._buttonEvents),this.button.one("focusin",function(){t.menuItems||t._refreshMenu()}),this._hoverable(this.button),this._focusable(this.button)},_drawMenu:function(){var t=this;this.menu=e("<ul>",{"aria-hidden":"true","aria-labelledby":this.ids.button,id:this.ids.menu}),this.menuWrap=e("<div>",{"class":"ui-selectmenu-menu ui-front"}).append(this.menu).appendTo(this._appendTo()),this.menuInstance=this.menu.menu({role:"listbox",select:function(e,n){e.preventDefault(),t._setSelection(),t._select(n.item.data("ui-selectmenu-item"),e)},focus:function(e,n){var i=n.item.data("ui-selectmenu-item");null!=t.focusIndex&&i.index!==t.focusIndex&&(t._trigger("focus",e,{item:i}),t.isOpen||t._select(i,e)),t.focusIndex=i.index,t.button.attr("aria-activedescendant",t.menuItems.eq(i.index).attr("id"))}}).menu("instance"),this.menu.addClass("ui-corner-bottom").removeClass("ui-corner-all"),this.menuInstance._off(this.menu,"mouseleave"),this.menuInstance._closeOnDocumentClick=function(){return!1},this.menuInstance._isDivider=function(){return!1}},refresh:function(){this._refreshMenu(),this._setText(this.buttonText,this._getSelectedItem().text()),this.options.width||this._resizeButton()},_refreshMenu:function(){this.menu.empty();var e,t=this.element.find("option");t.length&&(this._parseOptions(t),this._renderMenu(this.menu,this.items),this.menuInstance.refresh(),this.menuItems=this.menu.find("li").not(".ui-selectmenu-optgroup"),e=this._getSelectedItem(),this.menuInstance.focus(null,e),this._setAria(e.data("ui-selectmenu-item")),this._setOption("disabled",this.element.prop("disabled")))},open:function(e){this.options.disabled||(this.menuItems?(this.menu.find(".ui-state-focus").removeClass("ui-state-focus"),this.menuInstance.focus(null,this._getSelectedItem())):this._refreshMenu(),this.isOpen=!0,this._toggleAttr(),this._resizeMenu(),this._position(),this._on(this.document,this._documentClick),this._trigger("open",e))},_position:function(){this.menuWrap.position(e.extend({of:this.button},this.options.position))},close:function(e){this.isOpen&&(this.isOpen=!1,this._toggleAttr(),this.range=null,this._off(this.document),this._trigger("close",e))},widget:function(){return this.button},menuWidget:function(){return this.menu},_renderMenu:function(t,n){var i=this,r="";e.each(n,function(n,o){o.optgroup!==r&&(e("<li>",{"class":"ui-selectmenu-optgroup ui-menu-divider"+(o.element.parent("optgroup").prop("disabled")?" ui-state-disabled":""),text:o.optgroup}).appendTo(t),r=o.optgroup),i._renderItemData(t,o)})},_renderItemData:function(e,t){return this._renderItem(e,t).data("ui-selectmenu-item",t)},_renderItem:function(t,n){var i=e("<li>");return n.disabled&&i.addClass("ui-state-disabled"),this._setText(i,n.label),i.appendTo(t)},_setText:function(e,t){t?e.text(t):e.html("&#160;")},_move:function(e,t){var n,i,r=".ui-menu-item";this.isOpen?n=this.menuItems.eq(this.focusIndex):(n=this.menuItems.eq(this.element[0].selectedIndex),r+=":not(.ui-state-disabled)"),i="first"===e||"last"===e?n["first"===e?"prevAll":"nextAll"](r).eq(-1):n[e+"All"](r).eq(0),i.length&&this.menuInstance.focus(t,i)},_getSelectedItem:function(){return this.menuItems.eq(this.element[0].selectedIndex)},_toggle:function(e){this[this.isOpen?"close":"open"](e)},_setSelection:function(){var e;this.range&&(window.getSelection?(e=window.getSelection(),e.removeAllRanges(),e.addRange(this.range)):this.range.select(),this.button.focus())},_documentClick:{mousedown:function(t){this.isOpen&&(e(t.target).closest(".ui-selectmenu-menu, #"+this.ids.button).length||this.close(t))}},_buttonEvents:{mousedown:function(){var e;window.getSelection?(e=window.getSelection(),e.rangeCount&&(this.range=e.getRangeAt(0))):this.range=document.selection.createRange()},click:function(e){this._setSelection(),this._toggle(e)},keydown:function(t){var n=!0;switch(t.keyCode){case e.ui.keyCode.TAB:case e.ui.keyCode.ESCAPE:this.close(t),n=!1;break;case e.ui.keyCode.ENTER:this.isOpen&&this._selectFocusedItem(t);break;case e.ui.keyCode.UP:t.altKey?this._toggle(t):this._move("prev",t);break;case e.ui.keyCode.DOWN:t.altKey?this._toggle(t):this._move("next",t);break;case e.ui.keyCode.SPACE:this.isOpen?this._selectFocusedItem(t):this._toggle(t);break;case e.ui.keyCode.LEFT:this._move("prev",t);break;case e.ui.keyCode.RIGHT:this._move("next",t);break;case e.ui.keyCode.HOME:case e.ui.keyCode.PAGE_UP:this._move("first",t);break;case e.ui.keyCode.END:case e.ui.keyCode.PAGE_DOWN:this._move("last",t);break;default:this.menu.trigger(t),n=!1}n&&t.preventDefault()}},_selectFocusedItem:function(e){var t=this.menuItems.eq(this.focusIndex);t.hasClass("ui-state-disabled")||this._select(t.data("ui-selectmenu-item"),e)},_select:function(e,t){var n=this.element[0].selectedIndex;this.element[0].selectedIndex=e.index,this._setText(this.buttonText,e.label),this._setAria(e),this._trigger("select",t,{item:e}),e.index!==n&&this._trigger("change",t,{item:e}),this.close(t)},_setAria:function(e){var t=this.menuItems.eq(e.index).attr("id");this.button.attr({"aria-labelledby":t,"aria-activedescendant":t}),this.menu.attr("aria-activedescendant",t)},_setOption:function(e,t){"icons"===e&&this.button.find("span.ui-icon").removeClass(this.options.icons.button).addClass(t.button),
this._super(e,t),"appendTo"===e&&this.menuWrap.appendTo(this._appendTo()),"disabled"===e&&(this.menuInstance.option("disabled",t),this.button.toggleClass("ui-state-disabled",t).attr("aria-disabled",t),this.element.prop("disabled",t),t?(this.button.attr("tabindex",-1),this.close()):this.button.attr("tabindex",0)),"width"===e&&this._resizeButton()},_appendTo:function(){var t=this.options.appendTo;return t&&(t=t.jquery||t.nodeType?e(t):this.document.find(t).eq(0)),t&&t[0]||(t=this.element.closest(".ui-front")),t.length||(t=this.document[0].body),t},_toggleAttr:function(){this.button.toggleClass("ui-corner-top",this.isOpen).toggleClass("ui-corner-all",!this.isOpen).attr("aria-expanded",this.isOpen),this.menuWrap.toggleClass("ui-selectmenu-open",this.isOpen),this.menu.attr("aria-hidden",!this.isOpen)},_resizeButton:function(){var e=this.options.width;e||(e=this.element.show().outerWidth(),this.element.hide()),this.button.outerWidth(e)},_resizeMenu:function(){this.menu.outerWidth(Math.max(this.button.outerWidth(),this.menu.width("").outerWidth()+1))},_getCreateOptions:function(){return{disabled:this.element.prop("disabled")}},_parseOptions:function(t){var n=[];t.each(function(t,i){var r=e(i),o=r.parent("optgroup");n.push({element:r,index:t,value:r.val(),label:r.text(),optgroup:o.attr("label")||"",disabled:o.prop("disabled")||r.prop("disabled")})}),this.items=n},_destroy:function(){this.menuWrap.remove(),this.button.remove(),this.element.show(),this.element.removeUniqueId(),this.label.attr("for",this.ids.element)}})});