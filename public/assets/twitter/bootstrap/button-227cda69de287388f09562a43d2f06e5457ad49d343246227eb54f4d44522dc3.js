+function(e){"use strict";function t(t){return this.each(function(){var i=e(this),r=i.data("bs.button"),o="object"==typeof t&&t;r||i.data("bs.button",r=new n(this,o)),"toggle"==t?r.toggle():t&&r.setState(t)})}var n=function(t,i){this.$element=e(t),this.options=e.extend({},n.DEFAULTS,i),this.isLoading=!1};n.VERSION="3.2.0",n.DEFAULTS={loadingText:"loading..."},n.prototype.setState=function(t){var n="disabled",i=this.$element,r=i.is("input")?"val":"html",o=i.data();t+="Text",null==o.resetText&&i.data("resetText",i[r]()),i[r](null==o[t]?this.options[t]:o[t]),setTimeout(e.proxy(function(){"loadingText"==t?(this.isLoading=!0,i.addClass(n).attr(n,n)):this.isLoading&&(this.isLoading=!1,i.removeClass(n).removeAttr(n))},this),0)},n.prototype.toggle=function(){var e=!0,t=this.$element.closest('[data-toggle="buttons"]');if(t.length){var n=this.$element.find("input");"radio"==n.prop("type")&&(n.prop("checked")&&this.$element.hasClass("active")?e=!1:t.find(".active").removeClass("active")),e&&n.prop("checked",!this.$element.hasClass("active")).trigger("change")}e&&this.$element.toggleClass("active")};var i=e.fn.button;e.fn.button=t,e.fn.button.Constructor=n,e.fn.button.noConflict=function(){return e.fn.button=i,this},e(document).on("click.bs.button.data-api",'[data-toggle^="button"]',function(n){var i=e(n.target);i.hasClass("btn")||(i=i.closest(".btn")),t.call(i,"toggle"),n.preventDefault()})}(jQuery);