+function(e){"use strict";function t(t){t&&3===t.which||(e(r).remove(),e(o).each(function(){var i=n(e(this)),r={relatedTarget:this};i.hasClass("open")&&(i.trigger(t=e.Event("hide.bs.dropdown",r)),t.isDefaultPrevented()||i.removeClass("open").trigger("hidden.bs.dropdown",r))}))}function n(t){var n=t.attr("data-target");n||(n=t.attr("href"),n=n&&/#[A-Za-z]/.test(n)&&n.replace(/.*(?=#[^\s]*$)/,""));var i=n&&e(n);return i&&i.length?i:t.parent()}function i(t){return this.each(function(){var n=e(this),i=n.data("bs.dropdown");i||n.data("bs.dropdown",i=new s(this)),"string"==typeof t&&i[t].call(n)})}var r=".dropdown-backdrop",o='[data-toggle="dropdown"]',s=function(t){e(t).on("click.bs.dropdown",this.toggle)};s.VERSION="3.2.0",s.prototype.toggle=function(i){var r=e(this);if(!r.is(".disabled, :disabled")){var o=n(r),s=o.hasClass("open");if(t(),!s){"ontouchstart"in document.documentElement&&!o.closest(".navbar-nav").length&&e('<div class="dropdown-backdrop"/>').insertAfter(e(this)).on("click",t);var a={relatedTarget:this};if(o.trigger(i=e.Event("show.bs.dropdown",a)),i.isDefaultPrevented())return;r.trigger("focus"),o.toggleClass("open").trigger("shown.bs.dropdown",a)}return!1}},s.prototype.keydown=function(t){if(/(38|40|27)/.test(t.keyCode)){var i=e(this);if(t.preventDefault(),t.stopPropagation(),!i.is(".disabled, :disabled")){var r=n(i),s=r.hasClass("open");if(!s||s&&27==t.keyCode)return 27==t.which&&r.find(o).trigger("focus"),i.trigger("click");var a=" li:not(.divider):visible a",l=r.find('[role="menu"]'+a+', [role="listbox"]'+a);if(l.length){var u=l.index(l.filter(":focus"));38==t.keyCode&&u>0&&u--,40==t.keyCode&&u<l.length-1&&u++,~u||(u=0),l.eq(u).trigger("focus")}}}};var a=e.fn.dropdown;e.fn.dropdown=i,e.fn.dropdown.Constructor=s,e.fn.dropdown.noConflict=function(){return e.fn.dropdown=a,this},e(document).on("click.bs.dropdown.data-api",t).on("click.bs.dropdown.data-api",".dropdown form",function(e){e.stopPropagation()}).on("click.bs.dropdown.data-api",o,s.prototype.toggle).on("keydown.bs.dropdown.data-api",o+', [role="menu"], [role="listbox"]',s.prototype.keydown)}(jQuery);