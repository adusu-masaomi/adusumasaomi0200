+function(e){"use strict";function t(){var e=document.createElement("bootstrap"),t={WebkitTransition:"webkitTransitionEnd",MozTransition:"transitionend",OTransition:"oTransitionEnd otransitionend",transition:"transitionend"};for(var n in t)if(void 0!==e.style[n])return{end:t[n]};return!1}e.fn.emulateTransitionEnd=function(t){var n=!1,r=this;e(this).one("bsTransitionEnd",function(){n=!0});var i=function(){n||e(r).trigger(e.support.transition.end)};return setTimeout(i,t),this},e(function(){e.support.transition=t(),e.support.transition&&(e.event.special.bsTransitionEnd={bindType:e.support.transition.end,delegateType:e.support.transition.end,handle:function(t){if(e(t.target).is(this))return t.handleObj.handler.apply(this,arguments)}})})}(jQuery),+function(e){"use strict";function t(t){return this.each(function(){var n=e(this),i=n.data("bs.alert");i||n.data("bs.alert",i=new r(this)),"string"==typeof t&&i[t].call(n)})}var n='[data-dismiss="alert"]',r=function(t){e(t).on("click",n,this.close)};r.VERSION="3.2.0",r.prototype.close=function(t){function n(){o.detach().trigger("closed.bs.alert").remove()}var r=e(this),i=r.attr("data-target");i||(i=r.attr("href"),i=i&&i.replace(/.*(?=#[^\s]*$)/,""));var o=e(i);t&&t.preventDefault(),o.length||(o=r.hasClass("alert")?r:r.parent()),o.trigger(t=e.Event("close.bs.alert")),t.isDefaultPrevented()||(o.removeClass("in"),e.support.transition&&o.hasClass("fade")?o.one("bsTransitionEnd",n).emulateTransitionEnd(150):n())};var i=e.fn.alert;e.fn.alert=t,e.fn.alert.Constructor=r,e.fn.alert.noConflict=function(){return e.fn.alert=i,this},e(document).on("click.bs.alert.data-api",n,r.prototype.close)}(jQuery),+function(e){"use strict";function t(t,r){return this.each(function(){var i=e(this),o=i.data("bs.modal"),a=e.extend({},n.DEFAULTS,i.data(),"object"==typeof t&&t);o||i.data("bs.modal",o=new n(this,a)),"string"==typeof t?o[t](r):a.show&&o.show(r)})}var n=function(t,n){this.options=n,this.$body=e(document.body),this.$element=e(t),this.$backdrop=this.isShown=null,this.scrollbarWidth=0,this.options.remote&&this.$element.find(".modal-content").load(this.options.remote,e.proxy(function(){this.$element.trigger("loaded.bs.modal")},this))};n.VERSION="3.2.0",n.DEFAULTS={backdrop:!0,keyboard:!0,show:!0},n.prototype.toggle=function(e){return this.isShown?this.hide():this.show(e)},n.prototype.show=function(t){var n=this,r=e.Event("show.bs.modal",{relatedTarget:t});this.$element.trigger(r),this.isShown||r.isDefaultPrevented()||(this.isShown=!0,this.checkScrollbar(),this.$body.addClass("modal-open"),this.setScrollbar(),this.escape(),this.$element.on("click.dismiss.bs.modal",'[data-dismiss="modal"]',e.proxy(this.hide,this)),this.backdrop(function(){var r=e.support.transition&&n.$element.hasClass("fade");n.$element.parent().length||n.$element.appendTo(n.$body),n.$element.show().scrollTop(0),r&&n.$element[0].offsetWidth,n.$element.addClass("in").attr("aria-hidden",!1),n.enforceFocus();var i=e.Event("shown.bs.modal",{relatedTarget:t});r?n.$element.find(".modal-dialog").one("bsTransitionEnd",function(){n.$element.trigger("focus").trigger(i)}).emulateTransitionEnd(300):n.$element.trigger("focus").trigger(i)}))},n.prototype.hide=function(t){t&&t.preventDefault(),t=e.Event("hide.bs.modal"),this.$element.trigger(t),this.isShown&&!t.isDefaultPrevented()&&(this.isShown=!1,this.$body.removeClass("modal-open"),this.resetScrollbar(),this.escape(),e(document).off("focusin.bs.modal"),this.$element.removeClass("in").attr("aria-hidden",!0).off("click.dismiss.bs.modal"),e.support.transition&&this.$element.hasClass("fade")?this.$element.one("bsTransitionEnd",e.proxy(this.hideModal,this)).emulateTransitionEnd(300):this.hideModal())},n.prototype.enforceFocus=function(){e(document).off("focusin.bs.modal").on("focusin.bs.modal",e.proxy(function(e){this.$element[0]===e.target||this.$element.has(e.target).length||this.$element.trigger("focus")},this))},n.prototype.escape=function(){this.isShown&&this.options.keyboard?this.$element.on("keyup.dismiss.bs.modal",e.proxy(function(e){27==e.which&&this.hide()},this)):this.isShown||this.$element.off("keyup.dismiss.bs.modal")},n.prototype.hideModal=function(){var e=this;this.$element.hide(),this.backdrop(function(){e.$element.trigger("hidden.bs.modal")})},n.prototype.removeBackdrop=function(){this.$backdrop&&this.$backdrop.remove(),this.$backdrop=null},n.prototype.backdrop=function(t){var n=this,r=this.$element.hasClass("fade")?"fade":"";if(this.isShown&&this.options.backdrop){var i=e.support.transition&&r;if(this.$backdrop=e('<div class="modal-backdrop '+r+'" />').appendTo(this.$body),this.$element.on("click.dismiss.bs.modal",e.proxy(function(e){e.target===e.currentTarget&&("static"==this.options.backdrop?this.$element[0].focus.call(this.$element[0]):this.hide.call(this))},this)),i&&this.$backdrop[0].offsetWidth,this.$backdrop.addClass("in"),!t)return;i?this.$backdrop.one("bsTransitionEnd",t).emulateTransitionEnd(150):t()}else if(!this.isShown&&this.$backdrop){this.$backdrop.removeClass("in");var o=function(){n.removeBackdrop(),t&&t()};e.support.transition&&this.$element.hasClass("fade")?this.$backdrop.one("bsTransitionEnd",o).emulateTransitionEnd(150):o()}else t&&t()},n.prototype.checkScrollbar=function(){document.body.clientWidth>=window.innerWidth||(this.scrollbarWidth=this.scrollbarWidth||this.measureScrollbar())},n.prototype.setScrollbar=function(){var e=parseInt(this.$body.css("padding-right")||0,10);this.scrollbarWidth&&this.$body.css("padding-right",e+this.scrollbarWidth)},n.prototype.resetScrollbar=function(){this.$body.css("padding-right","")},n.prototype.measureScrollbar=function(){var e=document.createElement("div");e.className="modal-scrollbar-measure",this.$body.append(e);var t=e.offsetWidth-e.clientWidth;return this.$body[0].removeChild(e),t};var r=e.fn.modal;e.fn.modal=t,e.fn.modal.Constructor=n,e.fn.modal.noConflict=function(){return e.fn.modal=r,this},e(document).on("click.bs.modal.data-api",'[data-toggle="modal"]',function(n){var r=e(this),i=r.attr("href"),o=e(r.attr("data-target")||i&&i.replace(/.*(?=#[^\s]+$)/,"")),a=o.data("bs.modal")?"toggle":e.extend({remote:!/#/.test(i)&&i},o.data(),r.data());r.is("a")&&n.preventDefault(),o.one("show.bs.modal",function(e){e.isDefaultPrevented()||o.one("hidden.bs.modal",function(){r.is(":visible")&&r.trigger("focus")})}),t.call(o,a,this)})}(jQuery),+function(e){"use strict";function t(t){t&&3===t.which||(e(i).remove(),e(o).each(function(){var r=n(e(this)),i={relatedTarget:this};r.hasClass("open")&&(r.trigger(t=e.Event("hide.bs.dropdown",i)),t.isDefaultPrevented()||r.removeClass("open").trigger("hidden.bs.dropdown",i))}))}function n(t){var n=t.attr("data-target");n||(n=t.attr("href"),n=n&&/#[A-Za-z]/.test(n)&&n.replace(/.*(?=#[^\s]*$)/,""));var r=n&&e(n);return r&&r.length?r:t.parent()}function r(t){return this.each(function(){var n=e(this),r=n.data("bs.dropdown");r||n.data("bs.dropdown",r=new a(this)),"string"==typeof t&&r[t].call(n)})}var i=".dropdown-backdrop",o='[data-toggle="dropdown"]',a=function(t){e(t).on("click.bs.dropdown",this.toggle)};a.VERSION="3.2.0",a.prototype.toggle=function(r){var i=e(this);if(!i.is(".disabled, :disabled")){var o=n(i),a=o.hasClass("open");if(t(),!a){"ontouchstart"in document.documentElement&&!o.closest(".navbar-nav").length&&e('<div class="dropdown-backdrop"/>').insertAfter(e(this)).on("click",t);var s={relatedTarget:this};if(o.trigger(r=e.Event("show.bs.dropdown",s)),r.isDefaultPrevented())return;i.trigger("focus"),o.toggleClass("open").trigger("shown.bs.dropdown",s)}return!1}},a.prototype.keydown=function(t){if(/(38|40|27)/.test(t.keyCode)){var r=e(this);if(t.preventDefault(),t.stopPropagation(),!r.is(".disabled, :disabled")){var i=n(r),a=i.hasClass("open");if(!a||a&&27==t.keyCode)return 27==t.which&&i.find(o).trigger("focus"),r.trigger("click");var s=" li:not(.divider):visible a",l=i.find('[role="menu"]'+s+', [role="listbox"]'+s);if(l.length){var u=l.index(l.filter(":focus"));38==t.keyCode&&u>0&&u--,40==t.keyCode&&u<l.length-1&&u++,~u||(u=0),l.eq(u).trigger("focus")}}}};var s=e.fn.dropdown;e.fn.dropdown=r,e.fn.dropdown.Constructor=a,e.fn.dropdown.noConflict=function(){return e.fn.dropdown=s,this},e(document).on("click.bs.dropdown.data-api",t).on("click.bs.dropdown.data-api",".dropdown form",function(e){e.stopPropagation()}).on("click.bs.dropdown.data-api",o,a.prototype.toggle).on("keydown.bs.dropdown.data-api",o+', [role="menu"], [role="listbox"]',a.prototype.keydown)}(jQuery),+function(e){"use strict";function t(n,r){var i=e.proxy(this.process,this);this.$body=e("body"),this.$scrollElement=e(e(n).is("body")?window:n),this.options=e.extend({},t.DEFAULTS,r),this.selector=(this.options.target||"")+" .nav li > a",this.offsets=[],this.targets=[],this.activeTarget=null,this.scrollHeight=0,this.$scrollElement.on("scroll.bs.scrollspy",i),this.refresh(),this.process()}function n(n){return this.each(function(){var r=e(this),i=r.data("bs.scrollspy"),o="object"==typeof n&&n;i||r.data("bs.scrollspy",i=new t(this,o)),"string"==typeof n&&i[n]()})}t.VERSION="3.2.0",t.DEFAULTS={offset:10},t.prototype.getScrollHeight=function(){return this.$scrollElement[0].scrollHeight||Math.max(this.$body[0].scrollHeight,document.documentElement.scrollHeight)},t.prototype.refresh=function(){var t="offset",n=0;e.isWindow(this.$scrollElement[0])||(t="position",n=this.$scrollElement.scrollTop()),this.offsets=[],this.targets=[],this.scrollHeight=this.getScrollHeight();var r=this;this.$body.find(this.selector).map(function(){var r=e(this),i=r.data("target")||r.attr("href"),o=/^#./.test(i)&&e(i);return o&&o.length&&o.is(":visible")&&[[o[t]().top+n,i]]||null}).sort(function(e,t){return e[0]-t[0]}).each(function(){r.offsets.push(this[0]),r.targets.push(this[1])})},t.prototype.process=function(){var e,t=this.$scrollElement.scrollTop()+this.options.offset,n=this.getScrollHeight(),r=this.options.offset+n-this.$scrollElement.height(),i=this.offsets,o=this.targets,a=this.activeTarget;if(this.scrollHeight!=n&&this.refresh(),t>=r)return a!=(e=o[o.length-1])&&this.activate(e);if(a&&t<=i[0])return a!=(e=o[0])&&this.activate(e);for(e=i.length;e--;)a!=o[e]&&t>=i[e]&&(!i[e+1]||t<=i[e+1])&&this.activate(o[e])},t.prototype.activate=function(t){this.activeTarget=t,e(this.selector).parentsUntil(this.options.target,".active").removeClass("active");var n=this.selector+'[data-target="'+t+'"],'+this.selector+'[href="'+t+'"]',r=e(n).parents("li").addClass("active");r.parent(".dropdown-menu").length&&(r=r.closest("li.dropdown").addClass("active")),r.trigger("activate.bs.scrollspy")};var r=e.fn.scrollspy;e.fn.scrollspy=n,e.fn.scrollspy.Constructor=t,e.fn.scrollspy.noConflict=function(){return e.fn.scrollspy=r,this},e(window).on("load.bs.scrollspy.data-api",function(){e('[data-spy="scroll"]').each(function(){var t=e(this);n.call(t,t.data())})})}(jQuery),+function(e){"use strict";function t(t){return this.each(function(){var r=e(this),i=r.data("bs.tab");i||r.data("bs.tab",i=new n(this)),"string"==typeof t&&i[t]()})}var n=function(t){this.element=e(t)};n.VERSION="3.2.0",n.prototype.show=function(){var t=this.element,n=t.closest("ul:not(.dropdown-menu)"),r=t.data("target");if(r||(r=t.attr("href"),r=r&&r.replace(/.*(?=#[^\s]*$)/,"")),!t.parent("li").hasClass("active")){var i=n.find(".active:last a")[0],o=e.Event("show.bs.tab",{relatedTarget:i});if(t.trigger(o),!o.isDefaultPrevented()){var a=e(r);this.activate(t.closest("li"),n),this.activate(a,a.parent(),function(){t.trigger({type:"shown.bs.tab",relatedTarget:i})})}}},n.prototype.activate=function(t,n,r){function i(){o.removeClass("active").find("> .dropdown-menu > .active").removeClass("active"),t.addClass("active"),a?(t[0].offsetWidth,t.addClass("in")):t.removeClass("fade"),t.parent(".dropdown-menu")&&t.closest("li.dropdown").addClass("active"),r&&r()}var o=n.find("> .active"),a=r&&e.support.transition&&o.hasClass("fade");a?o.one("bsTransitionEnd",i).emulateTransitionEnd(150):i(),o.removeClass("in")};var r=e.fn.tab;e.fn.tab=t,e.fn.tab.Constructor=n,e.fn.tab.noConflict=function(){return e.fn.tab=r,this},e(document).on("click.bs.tab.data-api",'[data-toggle="tab"], [data-toggle="pill"]',function(n){n.preventDefault(),t.call(e(this),"show")})}(jQuery),+function(e){"use strict";function t(t){return this.each(function(){var r=e(this),i=r.data("bs.tooltip"),o="object"==typeof t&&t;(i||"destroy"!=t)&&(i||r.data("bs.tooltip",i=new n(this,o)),"string"==typeof t&&i[t]())})}var n=function(e,t){this.type=this.options=this.enabled=this.timeout=this.hoverState=this.$element=null,this.init("tooltip",e,t)};n.VERSION="3.2.0",n.DEFAULTS={animation:!0,placement:"top",selector:!1,template:'<div class="tooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>',trigger:"hover focus",title:"",delay:0,html:!1,container:!1,viewport:{selector:"body",padding:0}},n.prototype.init=function(t,n,r){this.enabled=!0,this.type=t,this.$element=e(n),this.options=this.getOptions(r),this.$viewport=this.options.viewport&&e(this.options.viewport.selector||this.options.viewport);for(var i=this.options.trigger.split(" "),o=i.length;o--;){var a=i[o];if("click"==a)this.$element.on("click."+this.type,this.options.selector,e.proxy(this.toggle,this));else if("manual"!=a){var s="hover"==a?"mouseenter":"focusin",l="hover"==a?"mouseleave":"focusout";this.$element.on(s+"."+this.type,this.options.selector,e.proxy(this.enter,this)),this.$element.on(l+"."+this.type,this.options.selector,e.proxy(this.leave,this))}}this.options.selector?this._options=e.extend({},this.options,{trigger:"manual",selector:""}):this.fixTitle()},n.prototype.getDefaults=function(){return n.DEFAULTS},n.prototype.getOptions=function(t){return t=e.extend({},this.getDefaults(),this.$element.data(),t),t.delay&&"number"==typeof t.delay&&(t.delay={show:t.delay,hide:t.delay}),t},n.prototype.getDelegateOptions=function(){var t={},n=this.getDefaults();return this._options&&e.each(this._options,function(e,r){n[e]!=r&&(t[e]=r)}),t},n.prototype.enter=function(t){var n=t instanceof this.constructor?t:e(t.currentTarget).data("bs."+this.type);return n||(n=new this.constructor(t.currentTarget,this.getDelegateOptions()),e(t.currentTarget).data("bs."+this.type,n)),clearTimeout(n.timeout),n.hoverState="in",n.options.delay&&n.options.delay.show?void(n.timeout=setTimeout(function(){"in"==n.hoverState&&n.show()},n.options.delay.show)):n.show()},n.prototype.leave=function(t){var n=t instanceof this.constructor?t:e(t.currentTarget).data("bs."+this.type);return n||(n=new this.constructor(t.currentTarget,this.getDelegateOptions()),e(t.currentTarget).data("bs."+this.type,n)),clearTimeout(n.timeout),n.hoverState="out",n.options.delay&&n.options.delay.hide?void(n.timeout=setTimeout(function(){"out"==n.hoverState&&n.hide()},n.options.delay.hide)):n.hide()},n.prototype.show=function(){var t=e.Event("show.bs."+this.type);if(this.hasContent()&&this.enabled){this.$element.trigger(t);var n=e.contains(document.documentElement,this.$element[0]);if(t.isDefaultPrevented()||!n)return;var r=this,i=this.tip(),o=this.getUID(this.type);this.setContent(),i.attr("id",o),this.$element.attr("aria-describedby",o),this.options.animation&&i.addClass("fade");var a="function"==typeof this.options.placement?this.options.placement.call(this,i[0],this.$element[0]):this.options.placement,s=/\s?auto?\s?/i,l=s.test(a);l&&(a=a.replace(s,"")||"top"),i.detach().css({top:0,left:0,display:"block"}).addClass(a).data("bs."+this.type,this),this.options.container?i.appendTo(this.options.container):i.insertAfter(this.$element);var u=this.getPosition(),c=i[0].offsetWidth,f=i[0].offsetHeight;if(l){var d=a,p=this.$element.parent(),h=this.getPosition(p);a="bottom"==a&&u.top+u.height+f-h.scroll>h.height?"top":"top"==a&&u.top-h.scroll-f<0?"bottom":"right"==a&&u.right+c>h.width?"left":"left"==a&&u.left-c<h.left?"right":a,i.removeClass(d).addClass(a)}var g=this.getCalculatedOffset(a,u,c,f);this.applyPlacement(g,a);var m=function(){r.$element.trigger("shown.bs."+r.type),r.hoverState=null};e.support.transition&&this.$tip.hasClass("fade")?i.one("bsTransitionEnd",m).emulateTransitionEnd(150):m()}},n.prototype.applyPlacement=function(t,n){var r=this.tip(),i=r[0].offsetWidth,o=r[0].offsetHeight,a=parseInt(r.css("margin-top"),10),s=parseInt(r.css("margin-left"),10);isNaN(a)&&(a=0),isNaN(s)&&(s=0),t.top=t.top+a,t.left=t.left+s,e.offset.setOffset(r[0],e.extend({using:function(e){r.css({top:Math.round(e.top),left:Math.round(e.left)})}},t),0),r.addClass("in");var l=r[0].offsetWidth,u=r[0].offsetHeight;"top"==n&&u!=o&&(t.top=t.top+o-u);var c=this.getViewportAdjustedDelta(n,t,l,u);c.left?t.left+=c.left:t.top+=c.top;var f=c.left?2*c.left-i+l:2*c.top-o+u,d=c.left?"left":"top",p=c.left?"offsetWidth":"offsetHeight";r.offset(t),this.replaceArrow(f,r[0][p],d)},n.prototype.replaceArrow=function(e,t,n){this.arrow().css(n,e?50*(1-e/t)+"%":"")},n.prototype.setContent=function(){var e=this.tip(),t=this.getTitle();e.find(".tooltip-inner")[this.options.html?"html":"text"](t),e.removeClass("fade in top bottom left right")},n.prototype.hide=function(){function t(){"in"!=n.hoverState&&r.detach(),n.$element.trigger("hidden.bs."+n.type)}var n=this,r=this.tip(),i=e.Event("hide.bs."+this.type);if(this.$element.removeAttr("aria-describedby"),this.$element.trigger(i),!i.isDefaultPrevented())return r.removeClass("in"),e.support.transition&&this.$tip.hasClass("fade")?r.one("bsTransitionEnd",t).emulateTransitionEnd(150):t(),this.hoverState=null,this},n.prototype.fixTitle=function(){var e=this.$element;(e.attr("title")||"string"!=typeof e.attr("data-original-title"))&&e.attr("data-original-title",e.attr("title")||"").attr("title","")},n.prototype.hasContent=function(){return this.getTitle()},n.prototype.getPosition=function(t){t=t||this.$element;var n=t[0],r="BODY"==n.tagName;return e.extend({},"function"==typeof n.getBoundingClientRect?n.getBoundingClientRect():null,{scroll:r?document.documentElement.scrollTop||document.body.scrollTop:t.scrollTop(),width:r?e(window).width():t.outerWidth(),height:r?e(window).height():t.outerHeight()},r?{top:0,left:0}:t.offset())},n.prototype.getCalculatedOffset=function(e,t,n,r){return"bottom"==e?{top:t.top+t.height,left:t.left+t.width/2-n/2}:"top"==e?{top:t.top-r,left:t.left+t.width/2-n/2}:"left"==e?{top:t.top+t.height/2-r/2,left:t.left-n}:{top:t.top+t.height/2-r/2,left:t.left+t.width}},n.prototype.getViewportAdjustedDelta=function(e,t,n,r){var i={top:0,left:0};if(!this.$viewport)return i;var o=this.options.viewport&&this.options.viewport.padding||0,a=this.getPosition(this.$viewport);if(/right|left/.test(e)){var s=t.top-o-a.scroll,l=t.top+o-a.scroll+r;s<a.top?i.top=a.top-s:l>a.top+a.height&&(i.top=a.top+a.height-l)}else{var u=t.left-o,c=t.left+o+n;u<a.left?i.left=a.left-u:c>a.width&&(i.left=a.left+a.width-c)}return i},n.prototype.getTitle=function(){var e,t=this.$element,n=this.options;return e=t.attr("data-original-title")||("function"==typeof n.title?n.title.call(t[0]):n.title)},n.prototype.getUID=function(e){do e+=~~(1e6*Math.random());while(document.getElementById(e));return e},n.prototype.tip=function(){return this.$tip=this.$tip||e(this.options.template)},n.prototype.arrow=function(){return this.$arrow=this.$arrow||this.tip().find(".tooltip-arrow")},n.prototype.validate=function(){this.$element[0].parentNode||(this.hide(),this.$element=null,this.options=null)},n.prototype.enable=function(){this.enabled=!0},n.prototype.disable=function(){this.enabled=!1},n.prototype.toggleEnabled=function(){this.enabled=!this.enabled},n.prototype.toggle=function(t){var n=this;t&&(n=e(t.currentTarget).data("bs."+this.type),n||(n=new this.constructor(t.currentTarget,this.getDelegateOptions()),e(t.currentTarget).data("bs."+this.type,n))),n.tip().hasClass("in")?n.leave(n):n.enter(n)},n.prototype.destroy=function(){clearTimeout(this.timeout),this.hide().$element.off("."+this.type).removeData("bs."+this.type)};var r=e.fn.tooltip;e.fn.tooltip=t,e.fn.tooltip.Constructor=n,e.fn.tooltip.noConflict=function(){return e.fn.tooltip=r,this}}(jQuery),+function(e){"use strict";function t(t){return this.each(function(){var r=e(this),i=r.data("bs.popover"),o="object"==typeof t&&t;(i||"destroy"!=t)&&(i||r.data("bs.popover",i=new n(this,o)),"string"==typeof t&&i[t]())})}var n=function(e,t){this.init("popover",e,t)};if(!e.fn.tooltip)throw new Error("Popover requires tooltip.js");n.VERSION="3.2.0",n.DEFAULTS=e.extend({},e.fn.tooltip.Constructor.DEFAULTS,{placement:"right",trigger:"click",content:"",template:'<div class="popover" role="tooltip"><div class="arrow"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'}),n.prototype=e.extend({},e.fn.tooltip.Constructor.prototype),n.prototype.constructor=n,n.prototype.getDefaults=function(){return n.DEFAULTS},n.prototype.setContent=function(){var e=this.tip(),t=this.getTitle(),n=this.getContent();e.find(".popover-title")[this.options.html?"html":"text"](t),e.find(".popover-content").empty()[this.options.html?"string"==typeof n?"html":"append":"text"](n),e.removeClass("fade top bottom left right in"),e.find(".popover-title").html()||e.find(".popover-title").hide()},n.prototype.hasContent=function(){return this.getTitle()||this.getContent()},n.prototype.getContent=function(){var e=this.$element,t=this.options;return e.attr("data-content")||("function"==typeof t.content?t.content.call(e[0]):t.content)},n.prototype.arrow=function(){return this.$arrow=this.$arrow||this.tip().find(".arrow")},n.prototype.tip=function(){return this.$tip||(this.$tip=e(this.options.template)),this.$tip};var r=e.fn.popover;e.fn.popover=t,e.fn.popover.Constructor=n,e.fn.popover.noConflict=function(){return e.fn.popover=r,this}}(jQuery),+function(e){"use strict";function t(t){return this.each(function(){var r=e(this),i=r.data("bs.button"),o="object"==typeof t&&t;i||r.data("bs.button",i=new n(this,o)),"toggle"==t?i.toggle():t&&i.setState(t)})}var n=function(t,r){this.$element=e(t),this.options=e.extend({},n.DEFAULTS,r),this.isLoading=!1};n.VERSION="3.2.0",n.DEFAULTS={loadingText:"loading..."},n.prototype.setState=function(t){var n="disabled",r=this.$element,i=r.is("input")?"val":"html",o=r.data();t+="Text",null==o.resetText&&r.data("resetText",r[i]()),r[i](null==o[t]?this.options[t]:o[t]),setTimeout(e.proxy(function(){"loadingText"==t?(this.isLoading=!0,r.addClass(n).attr(n,n)):this.isLoading&&(this.isLoading=!1,r.removeClass(n).removeAttr(n))},this),0)},n.prototype.toggle=function(){var e=!0,t=this.$element.closest('[data-toggle="buttons"]');if(t.length){var n=this.$element.find("input");"radio"==n.prop("type")&&(n.prop("checked")&&this.$element.hasClass("active")?e=!1:t.find(".active").removeClass("active")),e&&n.prop("checked",!this.$element.hasClass("active")).trigger("change")}e&&this.$element.toggleClass("active")};var r=e.fn.button;e.fn.button=t,e.fn.button.Constructor=n,e.fn.button.noConflict=function(){return e.fn.button=r,this},e(document).on("click.bs.button.data-api",'[data-toggle^="button"]',function(n){var r=e(n.target);r.hasClass("btn")||(r=r.closest(".btn")),t.call(r,"toggle"),n.preventDefault()})}(jQuery),+function(e){"use strict";function t(t){return this.each(function(){var r=e(this),i=r.data("bs.collapse"),o=e.extend({},n.DEFAULTS,r.data(),"object"==typeof t&&t);!i&&o.toggle&&"show"==t&&(t=!t),i||r.data("bs.collapse",i=new n(this,o)),"string"==typeof t&&i[t]()})}var n=function(t,r){this.$element=e(t),this.options=e.extend({},n.DEFAULTS,r),this.transitioning=null,this.options.parent&&(this.$parent=e(this.options.parent)),this.options.toggle&&this.toggle()};n.VERSION="3.2.0",n.DEFAULTS={toggle:!0},n.prototype.dimension=function(){var e=this.$element.hasClass("width");return e?"width":"height"},n.prototype.show=function(){if(!this.transitioning&&!this.$element.hasClass("in")){var n=e.Event("show.bs.collapse");if(this.$element.trigger(n),!n.isDefaultPrevented()){var r=this.$parent&&this.$parent.find("> .panel > .in");if(r&&r.length){var i=r.data("bs.collapse");if(i&&i.transitioning)return;t.call(r,"hide"),i||r.data("bs.collapse",null)}var o=this.dimension();this.$element.removeClass("collapse").addClass("collapsing")[o](0),this.transitioning=1;var a=function(){this.$element.removeClass("collapsing").addClass("collapse in")[o](""),this.transitioning=0,this.$element.trigger("shown.bs.collapse")};if(!e.support.transition)return a.call(this);var s=e.camelCase(["scroll",o].join("-"));this.$element.one("bsTransitionEnd",e.proxy(a,this)).emulateTransitionEnd(350)[o](this.$element[0][s])}}},n.prototype.hide=function(){if(!this.transitioning&&this.$element.hasClass("in")){var t=e.Event("hide.bs.collapse");if(this.$element.trigger(t),!t.isDefaultPrevented()){var n=this.dimension();this.$element[n](this.$element[n]())[0].offsetHeight,this.$element.addClass("collapsing").removeClass("collapse").removeClass("in"),this.transitioning=1;var r=function(){this.transitioning=0,this.$element.trigger("hidden.bs.collapse").removeClass("collapsing").addClass("collapse")};return e.support.transition?void this.$element[n](0).one("bsTransitionEnd",e.proxy(r,this)).emulateTransitionEnd(350):r.call(this)}}},n.prototype.toggle=function(){this[this.$element.hasClass("in")?"hide":"show"]()};var r=e.fn.collapse;e.fn.collapse=t,e.fn.collapse.Constructor=n,e.fn.collapse.noConflict=function(){return e.fn.collapse=r,this},e(document).on("click.bs.collapse.data-api",'[data-toggle="collapse"]',function(n){var r,i=e(this),o=i.attr("data-target")||n.preventDefault()||(r=i.attr("href"))&&r.replace(/.*(?=#[^\s]+$)/,""),a=e(o),s=a.data("bs.collapse"),l=s?"toggle":i.data(),u=i.attr("data-parent"),c=u&&e(u);s&&s.transitioning||(c&&c.find('[data-toggle="collapse"][data-parent="'+u+'"]').not(i).addClass("collapsed"),i[a.hasClass("in")?"addClass":"removeClass"]("collapsed")),t.call(a,l)})}(jQuery),+function(e){"use strict";function t(t){return this.each(function(){var r=e(this),i=r.data("bs.carousel"),o=e.extend({},n.DEFAULTS,r.data(),"object"==typeof t&&t),a="string"==typeof t?t:o.slide;i||r.data("bs.carousel",i=new n(this,o)),"number"==typeof t?i.to(t):a?i[a]():o.interval&&i.pause().cycle()})}var n=function(t,n){this.$element=e(t).on("keydown.bs.carousel",e.proxy(this.keydown,this)),this.$indicators=this.$element.find(".carousel-indicators"),this.options=n,this.paused=this.sliding=this.interval=this.$active=this.$items=null,"hover"==this.options.pause&&this.$element.on("mouseenter.bs.carousel",e.proxy(this.pause,this)).on("mouseleave.bs.carousel",e.proxy(this.cycle,this))};n.VERSION="3.2.0",n.DEFAULTS={interval:5e3,pause:"hover",wrap:!0},n.prototype.keydown=function(e){switch(e.which){case 37:this.prev();break;case 39:this.next();break;default:return}e.preventDefault()},n.prototype.cycle=function(t){return t||(this.paused=!1),this.interval&&clearInterval(this.interval),this.options.interval&&!this.paused&&(this.interval=setInterval(e.proxy(this.next,this),this.options.interval)),this},n.prototype.getItemIndex=function(e){return this.$items=e.parent().children(".item"),this.$items.index(e||this.$active)},n.prototype.to=function(t){var n=this,r=this.getItemIndex(this.$active=this.$element.find(".item.active"));if(!(t>this.$items.length-1||t<0))return this.sliding?this.$element.one("slid.bs.carousel",function(){n.to(t)}):r==t?this.pause().cycle():this.slide(t>r?"next":"prev",e(this.$items[t]))},n.prototype.pause=function(t){return t||(this.paused=!0),this.$element.find(".next, .prev").length&&e.support.transition&&(this.$element.trigger(e.support.transition.end),this.cycle(!0)),this.interval=clearInterval(this.interval),this},n.prototype.next=function(){if(!this.sliding)return this.slide("next")},n.prototype.prev=function(){if(!this.sliding)return this.slide("prev")},n.prototype.slide=function(t,n){var r=this.$element.find(".item.active"),i=n||r[t](),o=this.interval,a="next"==t?"left":"right",s="next"==t?"first":"last",l=this;if(!i.length){if(!this.options.wrap)return;i=this.$element.find(".item")[s]()}if(i.hasClass("active"))return this.sliding=!1;var u=i[0],c=e.Event("slide.bs.carousel",{relatedTarget:u,direction:a});if(this.$element.trigger(c),!c.isDefaultPrevented()){if(this.sliding=!0,o&&this.pause(),this.$indicators.length){this.$indicators.find(".active").removeClass("active");var f=e(this.$indicators.children()[this.getItemIndex(i)]);f&&f.addClass("active")}var d=e.Event("slid.bs.carousel",{relatedTarget:u,direction:a});return e.support.transition&&this.$element.hasClass("slide")?(i.addClass(t),i[0].offsetWidth,r.addClass(a),i.addClass(a),r.one("bsTransitionEnd",function(){i.removeClass([t,a].join(" ")).addClass("active"),r.removeClass(["active",a].join(" ")),l.sliding=!1,setTimeout(function(){l.$element.trigger(d)},0)}).emulateTransitionEnd(1e3*r.css("transition-duration").slice(0,-1))):(r.removeClass("active"),i.addClass("active"),this.sliding=!1,this.$element.trigger(d)),o&&this.cycle(),this}};var r=e.fn.carousel;e.fn.carousel=t,e.fn.carousel.Constructor=n,e.fn.carousel.noConflict=function(){return e.fn.carousel=r,this},e(document).on("click.bs.carousel.data-api","[data-slide], [data-slide-to]",function(n){var r,i=e(this),o=e(i.attr("data-target")||(r=i.attr("href"))&&r.replace(/.*(?=#[^\s]+$)/,""));if(o.hasClass("carousel")){var a=e.extend({},o.data(),i.data()),s=i.attr("data-slide-to");s&&(a.interval=!1),t.call(o,a),s&&o.data("bs.carousel").to(s),n.preventDefault()}}),e(window).on("load",function(){e('[data-ride="carousel"]').each(function(){var n=e(this);t.call(n,n.data())})})}(jQuery),+function(e){"use strict";function t(t){return this.each(function(){var r=e(this),i=r.data("bs.affix"),o="object"==typeof t&&t;i||r.data("bs.affix",i=new n(this,o)),"string"==typeof t&&i[t]()})}var n=function(t,r){this.options=e.extend({},n.DEFAULTS,r),this.$target=e(this.options.target).on("scroll.bs.affix.data-api",e.proxy(this.checkPosition,this)).on("click.bs.affix.data-api",e.proxy(this.checkPositionWithEventLoop,this)),this.$element=e(t),this.affixed=this.unpin=this.pinnedOffset=null,this.checkPosition()};n.VERSION="3.2.0",n.RESET="affix affix-top affix-bottom",n.DEFAULTS={offset:0,target:window},n.prototype.getPinnedOffset=function(){if(this.pinnedOffset)return this.pinnedOffset;this.$element.removeClass(n.RESET).addClass("affix");var e=this.$target.scrollTop(),t=this.$element.offset();return this.pinnedOffset=t.top-e},n.prototype.checkPositionWithEventLoop=function(){setTimeout(e.proxy(this.checkPosition,this),1)},n.prototype.checkPosition=function(){if(this.$element.is(":visible")){var t=e(document).height(),r=this.$target.scrollTop(),i=this.$element.offset(),o=this.options.offset,a=o.top,s=o.bottom;"object"!=typeof o&&(s=a=o),"function"==typeof a&&(a=o.top(this.$element)),"function"==typeof s&&(s=o.bottom(this.$element));var l=!(null!=this.unpin&&r+this.unpin<=i.top)&&(null!=s&&i.top+this.$element.height()>=t-s?"bottom":null!=a&&r<=a&&"top");if(this.affixed!==l){null!=this.unpin&&this.$element.css("top","");var u="affix"+(l?"-"+l:""),c=e.Event(u+".bs.affix");this.$element.trigger(c),c.isDefaultPrevented()||(this.affixed=l,this.unpin="bottom"==l?this.getPinnedOffset():null,this.$element.removeClass(n.RESET).addClass(u).trigger(e.Event(u.replace("affix","affixed"))),"bottom"==l&&this.$element.offset({top:t-this.$element.height()-s}))}}};var r=e.fn.affix;e.fn.affix=t,e.fn.affix.Constructor=n,e.fn.affix.noConflict=function(){return e.fn.affix=r,this},e(window).on("load",function(){e('[data-spy="affix"]').each(function(){var n=e(this),r=n.data();r.offset=r.offset||{},r.offsetBottom&&(r.offset.bottom=r.offsetBottom),r.offsetTop&&(r.offset.top=r.offsetTop),t.call(n,r)})})}(jQuery);