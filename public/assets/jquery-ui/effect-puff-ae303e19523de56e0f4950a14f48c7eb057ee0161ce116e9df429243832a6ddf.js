!function(e){"function"==typeof define&&define.amd?define(["jquery"],e):e(jQuery)}(function(e){var t="ui-effects-",n=e;return e.effects={effect:{}},function(e,t){function n(e,t,n){var i=d[t.type]||{};return null==e?n||!t.def?null:t.def:(e=i.floor?~~e:parseFloat(e),isNaN(e)?t.def:i.mod?(e+i.mod)%i.mod:0>e?0:i.max<e?i.max:e)}function i(t){var n=l(),i=n._rgba=[];return t=t.toLowerCase(),p(u,function(e,r){var o,s=r.re.exec(t),a=s&&r.parse(s),u=r.space||"rgba";if(a)return o=n[u](a),n[c[u].cache]=o[c[u].cache],i=n._rgba=o._rgba,!1}),i.length?("0,0,0,0"===i.join()&&e.extend(i,o.transparent),n):o[t]}function r(e,t,n){return n=(n+1)%1,6*n<1?e+(t-e)*n*6:2*n<1?t:3*n<2?e+(t-e)*(2/3-n)*6:e}var o,s="backgroundColor borderBottomColor borderLeftColor borderRightColor borderTopColor color columnRuleColor outlineColor textDecorationColor textEmphasisColor",a=/^([\-+])=\s*(\d+\.?\d*)/,u=[{re:/rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d?(?:\.\d+)?)\s*)?\)/,parse:function(e){return[e[1],e[2],e[3],e[4]]}},{re:/rgba?\(\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*(?:,\s*(\d?(?:\.\d+)?)\s*)?\)/,parse:function(e){return[2.55*e[1],2.55*e[2],2.55*e[3],e[4]]}},{re:/#([a-f0-9]{2})([a-f0-9]{2})([a-f0-9]{2})/,parse:function(e){return[parseInt(e[1],16),parseInt(e[2],16),parseInt(e[3],16)]}},{re:/#([a-f0-9])([a-f0-9])([a-f0-9])/,parse:function(e){return[parseInt(e[1]+e[1],16),parseInt(e[2]+e[2],16),parseInt(e[3]+e[3],16)]}},{re:/hsla?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*(?:,\s*(\d?(?:\.\d+)?)\s*)?\)/,space:"hsla",parse:function(e){return[e[1],e[2]/100,e[3]/100,e[4]]}}],l=e.Color=function(t,n,i,r){return new e.Color.fn.parse(t,n,i,r)},c={rgba:{props:{red:{idx:0,type:"byte"},green:{idx:1,type:"byte"},blue:{idx:2,type:"byte"}}},hsla:{props:{hue:{idx:0,type:"degrees"},saturation:{idx:1,type:"percent"},lightness:{idx:2,type:"percent"}}}},d={"byte":{floor:!0,max:255},percent:{max:1},degrees:{mod:360,floor:!0}},f=l.support={},h=e("<p>")[0],p=e.each;h.style.cssText="background-color:rgba(1,1,1,.5)",f.rgba=h.style.backgroundColor.indexOf("rgba")>-1,p(c,function(e,t){t.cache="_"+e,t.props.alpha={idx:3,type:"percent",def:1}}),l.fn=e.extend(l.prototype,{parse:function(r,s,a,u){if(r===t)return this._rgba=[null,null,null,null],this;(r.jquery||r.nodeType)&&(r=e(r).css(s),s=t);var d=this,f=e.type(r),h=this._rgba=[];return s!==t&&(r=[r,s,a,u],f="array"),"string"===f?this.parse(i(r)||o._default):"array"===f?(p(c.rgba.props,function(e,t){h[t.idx]=n(r[t.idx],t)}),this):"object"===f?(r instanceof l?p(c,function(e,t){r[t.cache]&&(d[t.cache]=r[t.cache].slice())}):p(c,function(t,i){var o=i.cache;p(i.props,function(e,t){if(!d[o]&&i.to){if("alpha"===e||null==r[e])return;d[o]=i.to(d._rgba)}d[o][t.idx]=n(r[e],t,!0)}),d[o]&&e.inArray(null,d[o].slice(0,3))<0&&(d[o][3]=1,i.from&&(d._rgba=i.from(d[o])))}),this):void 0},is:function(e){var t=l(e),n=!0,i=this;return p(c,function(e,r){var o,s=t[r.cache];return s&&(o=i[r.cache]||r.to&&r.to(i._rgba)||[],p(r.props,function(e,t){if(null!=s[t.idx])return n=s[t.idx]===o[t.idx]})),n}),n},_space:function(){var e=[],t=this;return p(c,function(n,i){t[i.cache]&&e.push(n)}),e.pop()},transition:function(e,t){var i=l(e),r=i._space(),o=c[r],s=0===this.alpha()?l("transparent"):this,a=s[o.cache]||o.to(s._rgba),u=a.slice();return i=i[o.cache],p(o.props,function(e,r){var o=r.idx,s=a[o],l=i[o],c=d[r.type]||{};null!==l&&(null===s?u[o]=l:(c.mod&&(l-s>c.mod/2?s+=c.mod:s-l>c.mod/2&&(s-=c.mod)),u[o]=n((l-s)*t+s,r)))}),this[r](u)},blend:function(t){if(1===this._rgba[3])return this;var n=this._rgba.slice(),i=n.pop(),r=l(t)._rgba;return l(e.map(n,function(e,t){return(1-i)*r[t]+i*e}))},toRgbaString:function(){var t="rgba(",n=e.map(this._rgba,function(e,t){return null==e?t>2?1:0:e});return 1===n[3]&&(n.pop(),t="rgb("),t+n.join()+")"},toHslaString:function(){var t="hsla(",n=e.map(this.hsla(),function(e,t){return null==e&&(e=t>2?1:0),t&&t<3&&(e=Math.round(100*e)+"%"),e});return 1===n[3]&&(n.pop(),t="hsl("),t+n.join()+")"},toHexString:function(t){var n=this._rgba.slice(),i=n.pop();return t&&n.push(~~(255*i)),"#"+e.map(n,function(e){return e=(e||0).toString(16),1===e.length?"0"+e:e}).join("")},toString:function(){return 0===this._rgba[3]?"transparent":this.toRgbaString()}}),l.fn.parse.prototype=l.fn,c.hsla.to=function(e){if(null==e[0]||null==e[1]||null==e[2])return[null,null,null,e[3]];var t,n,i=e[0]/255,r=e[1]/255,o=e[2]/255,s=e[3],a=Math.max(i,r,o),u=Math.min(i,r,o),l=a-u,c=a+u,d=.5*c;return t=u===a?0:i===a?60*(r-o)/l+360:r===a?60*(o-i)/l+120:60*(i-r)/l+240,n=0===l?0:d<=.5?l/c:l/(2-c),[Math.round(t)%360,n,d,null==s?1:s]},c.hsla.from=function(e){if(null==e[0]||null==e[1]||null==e[2])return[null,null,null,e[3]];var t=e[0]/360,n=e[1],i=e[2],o=e[3],s=i<=.5?i*(1+n):i+n-i*n,a=2*i-s;return[Math.round(255*r(a,s,t+1/3)),Math.round(255*r(a,s,t)),Math.round(255*r(a,s,t-1/3)),o]},p(c,function(i,r){var o=r.props,s=r.cache,u=r.to,c=r.from;l.fn[i]=function(i){if(u&&!this[s]&&(this[s]=u(this._rgba)),i===t)return this[s].slice();var r,a=e.type(i),d="array"===a||"object"===a?i:arguments,f=this[s].slice();return p(o,function(e,t){var i=d["object"===a?e:t.idx];null==i&&(i=f[t.idx]),f[t.idx]=n(i,t)}),c?(r=l(c(f)),r[s]=f,r):l(f)},p(o,function(t,n){l.fn[t]||(l.fn[t]=function(r){var o,s=e.type(r),u="alpha"===t?this._hsla?"hsla":"rgba":i,l=this[u](),c=l[n.idx];return"undefined"===s?c:("function"===s&&(r=r.call(this,c),s=e.type(r)),null==r&&n.empty?this:("string"===s&&(o=a.exec(r),o&&(r=c+parseFloat(o[2])*("+"===o[1]?1:-1))),l[n.idx]=r,this[u](l)))})})}),l.hook=function(t){var n=t.split(" ");p(n,function(t,n){e.cssHooks[n]={set:function(t,r){var o,s,a="";if("transparent"!==r&&("string"!==e.type(r)||(o=i(r)))){if(r=l(o||r),!f.rgba&&1!==r._rgba[3]){for(s="backgroundColor"===n?t.parentNode:t;(""===a||"transparent"===a)&&s&&s.style;)try{a=e.css(s,"backgroundColor"),s=s.parentNode}catch(e){}r=r.blend(a&&"transparent"!==a?a:"_default")}r=r.toRgbaString()}try{t.style[n]=r}catch(e){}}},e.fx.step[n]=function(t){t.colorInit||(t.start=l(t.elem,n),t.end=l(t.end),t.colorInit=!0),e.cssHooks[n].set(t.elem,t.start.transition(t.end,t.pos))}})},l.hook(s),e.cssHooks.borderColor={expand:function(e){var t={};return p(["Top","Right","Bottom","Left"],function(n,i){t["border"+i+"Color"]=e}),t}},o=e.Color.names={aqua:"#00ffff",black:"#000000",blue:"#0000ff",fuchsia:"#ff00ff",gray:"#808080",green:"#008000",lime:"#00ff00",maroon:"#800000",navy:"#000080",olive:"#808000",purple:"#800080",red:"#ff0000",silver:"#c0c0c0",teal:"#008080",white:"#ffffff",yellow:"#ffff00",transparent:[null,null,null,0],_default:"#ffffff"}}(n),function(){function t(t){var n,i,r=t.ownerDocument.defaultView?t.ownerDocument.defaultView.getComputedStyle(t,null):t.currentStyle,o={};if(r&&r.length&&r[0]&&r[r[0]])for(i=r.length;i--;)n=r[i],"string"==typeof r[n]&&(o[e.camelCase(n)]=r[n]);else for(n in r)"string"==typeof r[n]&&(o[n]=r[n]);return o}function i(t,n){var i,r,s={};for(i in n)r=n[i],t[i]!==r&&(o[i]||!e.fx.step[i]&&isNaN(parseFloat(r))||(s[i]=r));return s}var r=["add","remove","toggle"],o={border:1,borderBottom:1,borderColor:1,borderLeft:1,borderRight:1,borderTop:1,borderWidth:1,margin:1,padding:1};e.each(["borderLeftStyle","borderRightStyle","borderBottomStyle","borderTopStyle"],function(t,i){e.fx.step[i]=function(e){("none"!==e.end&&!e.setAttr||1===e.pos&&!e.setAttr)&&(n.style(e.elem,i,e.end),e.setAttr=!0)}}),e.fn.addBack||(e.fn.addBack=function(e){return this.add(null==e?this.prevObject:this.prevObject.filter(e))}),e.effects.animateClass=function(n,o,s,a){var u=e.speed(o,s,a);return this.queue(function(){var o,s=e(this),a=s.attr("class")||"",l=u.children?s.find("*").addBack():s;l=l.map(function(){var n=e(this);return{el:n,start:t(this)}}),o=function(){e.each(r,function(e,t){n[t]&&s[t+"Class"](n[t])})},o(),l=l.map(function(){return this.end=t(this.el[0]),this.diff=i(this.start,this.end),this}),s.attr("class",a),l=l.map(function(){var t=this,n=e.Deferred(),i=e.extend({},u,{queue:!1,complete:function(){n.resolve(t)}});return this.el.animate(this.diff,i),n.promise()}),e.when.apply(e,l.get()).done(function(){o(),e.each(arguments,function(){var t=this.el;e.each(this.diff,function(e){t.css(e,"")})}),u.complete.call(s[0])})})},e.fn.extend({addClass:function(t){return function(n,i,r,o){return i?e.effects.animateClass.call(this,{add:n},i,r,o):t.apply(this,arguments)}}(e.fn.addClass),removeClass:function(t){return function(n,i,r,o){return arguments.length>1?e.effects.animateClass.call(this,{remove:n},i,r,o):t.apply(this,arguments)}}(e.fn.removeClass),toggleClass:function(t){return function(n,i,r,o,s){return"boolean"==typeof i||void 0===i?r?e.effects.animateClass.call(this,i?{add:n}:{remove:n},r,o,s):t.apply(this,arguments):e.effects.animateClass.call(this,{toggle:n},i,r,o)}}(e.fn.toggleClass),switchClass:function(t,n,i,r,o){return e.effects.animateClass.call(this,{add:n,remove:t},i,r,o)}})}(),function(){function n(t,n,i,r){return e.isPlainObject(t)&&(n=t,t=t.effect),t={effect:t},null==n&&(n={}),e.isFunction(n)&&(r=n,i=null,n={}),("number"==typeof n||e.fx.speeds[n])&&(r=i,i=n,n={}),e.isFunction(i)&&(r=i,i=null),n&&e.extend(t,n),i=i||n.duration,t.duration=e.fx.off?0:"number"==typeof i?i:i in e.fx.speeds?e.fx.speeds[i]:e.fx.speeds._default,t.complete=r||n.complete,t}function i(t){return!(t&&"number"!=typeof t&&!e.fx.speeds[t])||("string"==typeof t&&!e.effects.effect[t]||(!!e.isFunction(t)||"object"==typeof t&&!t.effect))}e.extend(e.effects,{version:"1.11.4",save:function(e,n){for(var i=0;i<n.length;i++)null!==n[i]&&e.data(t+n[i],e[0].style[n[i]])},restore:function(e,n){var i,r;for(r=0;r<n.length;r++)null!==n[r]&&(i=e.data(t+n[r]),void 0===i&&(i=""),e.css(n[r],i))},setMode:function(e,t){return"toggle"===t&&(t=e.is(":hidden")?"show":"hide"),t},getBaseline:function(e,t){var n,i;switch(e[0]){case"top":n=0;break;case"middle":n=.5;break;case"bottom":n=1;break;default:n=e[0]/t.height}switch(e[1]){case"left":i=0;break;case"center":i=.5;break;case"right":i=1;break;default:i=e[1]/t.width}return{x:i,y:n}},createWrapper:function(t){if(t.parent().is(".ui-effects-wrapper"))return t.parent();var n={width:t.outerWidth(!0),height:t.outerHeight(!0),"float":t.css("float")},i=e("<div></div>").addClass("ui-effects-wrapper").css({fontSize:"100%",background:"transparent",border:"none",margin:0,padding:0}),r={width:t.width(),height:t.height()},o=document.activeElement;try{o.id}catch(e){o=document.body}return t.wrap(i),(t[0]===o||e.contains(t[0],o))&&e(o).focus(),i=t.parent(),"static"===t.css("position")?(i.css({position:"relative"}),t.css({position:"relative"})):(e.extend(n,{position:t.css("position"),zIndex:t.css("z-index")}),e.each(["top","left","bottom","right"],function(e,i){n[i]=t.css(i),isNaN(parseInt(n[i],10))&&(n[i]="auto")}),t.css({position:"relative",top:0,left:0,right:"auto",bottom:"auto"})),t.css(r),i.css(n).show()},removeWrapper:function(t){var n=document.activeElement;return t.parent().is(".ui-effects-wrapper")&&(t.parent().replaceWith(t),(t[0]===n||e.contains(t[0],n))&&e(n).focus()),t},setTransition:function(t,n,i,r){return r=r||{},e.each(n,function(e,n){var o=t.cssUnit(n);o[0]>0&&(r[n]=o[0]*i+o[1])}),r}}),e.fn.extend({effect:function(){function t(t){function n(){e.isFunction(o)&&o.call(r[0]),e.isFunction(t)&&t()}var r=e(this),o=i.complete,a=i.mode;(r.is(":hidden")?"hide"===a:"show"===a)?(r[a](),n()):s.call(r[0],i,n)}var i=n.apply(this,arguments),r=i.mode,o=i.queue,s=e.effects.effect[i.effect];return e.fx.off||!s?r?this[r](i.duration,i.complete):this.each(function(){i.complete&&i.complete.call(this)}):o===!1?this.each(t):this.queue(o||"fx",t)},show:function(e){return function(t){if(i(t))return e.apply(this,arguments);var r=n.apply(this,arguments);return r.mode="show",this.effect.call(this,r)}}(e.fn.show),hide:function(e){return function(t){if(i(t))return e.apply(this,arguments);var r=n.apply(this,arguments);return r.mode="hide",this.effect.call(this,r)}}(e.fn.hide),toggle:function(e){return function(t){if(i(t)||"boolean"==typeof t)return e.apply(this,arguments);var r=n.apply(this,arguments);return r.mode="toggle",this.effect.call(this,r)}}(e.fn.toggle),cssUnit:function(t){var n=this.css(t),i=[];return e.each(["em","px","%","pt"],function(e,t){n.indexOf(t)>0&&(i=[parseFloat(n),t])}),i}})}(),function(){var t={};e.each(["Quad","Cubic","Quart","Quint","Expo"],function(e,n){t[n]=function(t){return Math.pow(t,e+2)}}),e.extend(t,{Sine:function(e){return 1-Math.cos(e*Math.PI/2)},Circ:function(e){return 1-Math.sqrt(1-e*e)},Elastic:function(e){return 0===e||1===e?e:-Math.pow(2,8*(e-1))*Math.sin((80*(e-1)-7.5)*Math.PI/15)},Back:function(e){return e*e*(3*e-2)},Bounce:function(e){for(var t,n=4;e<((t=Math.pow(2,--n))-1)/11;);return 1/Math.pow(4,3-n)-7.5625*Math.pow((3*t-2)/22-e,2)}}),e.each(t,function(t,n){e.easing["easeIn"+t]=n,e.easing["easeOut"+t]=function(e){return 1-n(1-e)},e.easing["easeInOut"+t]=function(e){return e<.5?n(2*e)/2:1-n(e*-2+2)/2}})}(),e.effects}),function(e){"function"==typeof define&&define.amd?define(["jquery","./effect"],e):e(jQuery)}(function(e){return e.effects.effect.size=function(t,n){var i,r,o,s=e(this),a=["position","top","bottom","left","right","width","height","overflow","opacity"],u=["position","top","bottom","left","right","overflow","opacity"],l=["width","height","overflow"],c=["fontSize"],d=["borderTopWidth","borderBottomWidth","paddingTop","paddingBottom"],f=["borderLeftWidth","borderRightWidth","paddingLeft","paddingRight"],h=e.effects.setMode(s,t.mode||"effect"),p=t.restore||"effect"!==h,m=t.scale||"both",g=t.origin||["middle","center"],y=s.css("position"),v=p?a:u,b={height:0,width:0,outerHeight:0,outerWidth:0};"show"===h&&s.show(),i={height:s.height(),width:s.width(),outerHeight:s.outerHeight(),outerWidth:s.outerWidth()},"toggle"===t.mode&&"show"===h?(s.from=t.to||b,s.to=t.from||i):(s.from=t.from||("show"===h?b:i),s.to=t.to||("hide"===h?b:i)),o={from:{y:s.from.height/i.height,x:s.from.width/i.width},to:{y:s.to.height/i.height,x:s.to.width/i.width}},"box"!==m&&"both"!==m||(o.from.y!==o.to.y&&(v=v.concat(d),s.from=e.effects.setTransition(s,d,o.from.y,s.from),s.to=e.effects.setTransition(s,d,o.to.y,s.to)),o.from.x!==o.to.x&&(v=v.concat(f),s.from=e.effects.setTransition(s,f,o.from.x,s.from),s.to=e.effects.setTransition(s,f,o.to.x,s.to))),"content"!==m&&"both"!==m||o.from.y!==o.to.y&&(v=v.concat(c).concat(l),s.from=e.effects.setTransition(s,c,o.from.y,s.from),s.to=e.effects.setTransition(s,c,o.to.y,s.to)),e.effects.save(s,v),s.show(),e.effects.createWrapper(s),s.css("overflow","hidden").css(s.from),g&&(r=e.effects.getBaseline(g,i),s.from.top=(i.outerHeight-s.outerHeight())*r.y,s.from.left=(i.outerWidth-s.outerWidth())*r.x,s.to.top=(i.outerHeight-s.to.outerHeight)*r.y,s.to.left=(i.outerWidth-s.to.outerWidth)*r.x),s.css(s.from),"content"!==m&&"both"!==m||(d=d.concat(["marginTop","marginBottom"]).concat(c),f=f.concat(["marginLeft","marginRight"]),l=a.concat(d).concat(f),s.find("*[width]").each(function(){var n=e(this),i={height:n.height(),width:n.width(),outerHeight:n.outerHeight(),outerWidth:n.outerWidth()};p&&e.effects.save(n,l),n.from={height:i.height*o.from.y,width:i.width*o.from.x,outerHeight:i.outerHeight*o.from.y,outerWidth:i.outerWidth*o.from.x},n.to={height:i.height*o.to.y,width:i.width*o.to.x,outerHeight:i.height*o.to.y,outerWidth:i.width*o.to.x},o.from.y!==o.to.y&&(n.from=e.effects.setTransition(n,d,o.from.y,n.from),n.to=e.effects.setTransition(n,d,o.to.y,n.to)),o.from.x!==o.to.x&&(n.from=e.effects.setTransition(n,f,o.from.x,n.from),n.to=e.effects.setTransition(n,f,o.to.x,n.to)),n.css(n.from),n.animate(n.to,t.duration,t.easing,function(){p&&e.effects.restore(n,l)})})),s.animate(s.to,{queue:!1,duration:t.duration,easing:t.easing,complete:function(){0===s.to.opacity&&s.css("opacity",s.from.opacity),"hide"===h&&s.hide(),e.effects.restore(s,v),p||("static"===y?s.css({position:"relative",top:s.to.top,left:s.to.left}):e.each(["top","left"],function(e,t){s.css(t,function(t,n){var i=parseInt(n,10),r=e?s.to.left:s.to.top;return"auto"===n?r+"px":i+r+"px"})})),e.effects.removeWrapper(s),n()}})}}),function(e){"function"==typeof define&&define.amd?define(["jquery","./effect","./effect-size"],e):e(jQuery)}(function(e){return e.effects.effect.scale=function(t,n){var i=e(this),r=e.extend(!0,{},t),o=e.effects.setMode(i,t.mode||"effect"),s=parseInt(t.percent,10)||(0===parseInt(t.percent,10)?0:"hide"===o?0:100),a=t.direction||"both",u=t.origin,l={height:i.height(),width:i.width(),outerHeight:i.outerHeight(),outerWidth:i.outerWidth()},c={y:"horizontal"!==a?s/100:1,x:"vertical"!==a?s/100:1};r.effect="size",r.queue=!1,r.complete=n,"effect"!==o&&(r.origin=u||["middle","center"],r.restore=!0),r.from=t.from||("show"===o?{height:0,width:0,outerHeight:0,outerWidth:0}:l),r.to={height:l.height*c.y,width:l.width*c.x,outerHeight:l.outerHeight*c.y,outerWidth:l.outerWidth*c.x},r.fade&&("show"===o&&(r.from.opacity=0,r.to.opacity=1),"hide"===o&&(r.from.opacity=1,r.to.opacity=0)),i.effect(r)}}),function(e){"function"==typeof define&&define.amd?define(["jquery","./effect","./effect-scale"],e):e(jQuery)}(function(e){return e.effects.effect.puff=function(t,n){var i=e(this),r=e.effects.setMode(i,t.mode||"hide"),o="hide"===r,s=parseInt(t.percent,10)||150,a=s/100,u={height:i.height(),width:i.width(),outerHeight:i.outerHeight(),outerWidth:i.outerWidth()};e.extend(t,{effect:"scale",queue:!1,fade:!0,mode:r,complete:n,percent:o?s:100,from:o?u:{height:u.height*a,width:u.width*a,outerHeight:u.outerHeight*a,outerWidth:u.outerWidth*a}}),i.effect(t)}});