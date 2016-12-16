!function(t){"use strict";if("function"==typeof define&&define.amd)define(["jquery","moment"],t);else if("object"==typeof exports)t(require("jquery"),require("moment"));else{if("undefined"==typeof jQuery)throw"bootstrap-datetimepicker requires jQuery to be loaded first";if("undefined"==typeof moment)throw"bootstrap-datetimepicker requires Moment.js to be loaded first";t(jQuery,moment)}}(function(t,e){"use strict";if(!e)throw new Error("bootstrap-datetimepicker requires Moment.js to be loaded first");var i=function(i,n){var s,o,r,a,l,c={},u=e().startOf("d"),h=u.clone(),d=!0,p=!1,f=!1,m=0,g=[{clsName:"days",navFnc:"M",navStep:1},{clsName:"months",navFnc:"y",navStep:1},{clsName:"years",navFnc:"y",navStep:10}],v=["days","months","years"],y=["top","bottom","auto"],b=["left","right","auto"],_=["default","top","bottom"],w={up:38,38:"up",down:40,40:"down",left:37,37:"left",right:39,39:"right",tab:9,9:"tab",escape:27,27:"escape",enter:13,13:"enter",pageUp:33,33:"pageUp",pageDown:34,34:"pageDown",shift:16,16:"shift",control:17,17:"control",space:32,32:"space",t:84,84:"t","delete":46,46:"delete"},x={},C=function(t){if("string"!=typeof t||t.length>1)throw new TypeError("isEnabled expects a single character string parameter");switch(t){case"y":return r.indexOf("Y")!==-1;case"M":return r.indexOf("M")!==-1;case"d":return r.toLowerCase().indexOf("d")!==-1;case"h":case"H":return r.toLowerCase().indexOf("h")!==-1;case"m":return r.indexOf("m")!==-1;case"s":return r.indexOf("s")!==-1;default:return!1}},k=function(){return C("h")||C("m")||C("s")},D=function(){return C("y")||C("M")||C("d")},T=function(){var e=t("<thead>").append(t("<tr>").append(t("<th>").addClass("prev").attr("data-action","previous").append(t("<span>").addClass(n.icons.previous))).append(t("<th>").addClass("picker-switch").attr("data-action","pickerSwitch").attr("colspan",n.calendarWeeks?"6":"5")).append(t("<th>").addClass("next").attr("data-action","next").append(t("<span>").addClass(n.icons.next)))),i=t("<tbody>").append(t("<tr>").append(t("<td>").attr("colspan",n.calendarWeeks?"8":"7")));return[t("<div>").addClass("datepicker-days").append(t("<table>").addClass("table-condensed").append(e).append(t("<tbody>"))),t("<div>").addClass("datepicker-months").append(t("<table>").addClass("table-condensed").append(e.clone()).append(i.clone())),t("<div>").addClass("datepicker-years").append(t("<table>").addClass("table-condensed").append(e.clone()).append(i.clone()))]},S=function(){var e=t("<tr>"),i=t("<tr>"),s=t("<tr>");return C("h")&&(e.append(t("<td>").append(t("<a>").attr({href:"#",tabindex:"-1"}).addClass("btn").attr("data-action","incrementHours").append(t("<span>").addClass(n.icons.up)))),i.append(t("<td>").append(t("<span>").addClass("timepicker-hour").attr("data-time-component","hours").attr("data-action","showHours"))),s.append(t("<td>").append(t("<a>").attr({href:"#",tabindex:"-1"}).addClass("btn").attr("data-action","decrementHours").append(t("<span>").addClass(n.icons.down))))),C("m")&&(C("h")&&(e.append(t("<td>").addClass("separator")),i.append(t("<td>").addClass("separator").html(":")),s.append(t("<td>").addClass("separator"))),e.append(t("<td>").append(t("<a>").attr({href:"#",tabindex:"-1"}).addClass("btn").attr("data-action","incrementMinutes").append(t("<span>").addClass(n.icons.up)))),i.append(t("<td>").append(t("<span>").addClass("timepicker-minute").attr("data-time-component","minutes").attr("data-action","showMinutes"))),s.append(t("<td>").append(t("<a>").attr({href:"#",tabindex:"-1"}).addClass("btn").attr("data-action","decrementMinutes").append(t("<span>").addClass(n.icons.down))))),C("s")&&(C("m")&&(e.append(t("<td>").addClass("separator")),i.append(t("<td>").addClass("separator").html(":")),s.append(t("<td>").addClass("separator"))),e.append(t("<td>").append(t("<a>").attr({href:"#",tabindex:"-1"}).addClass("btn").attr("data-action","incrementSeconds").append(t("<span>").addClass(n.icons.up)))),i.append(t("<td>").append(t("<span>").addClass("timepicker-second").attr("data-time-component","seconds").attr("data-action","showSeconds"))),s.append(t("<td>").append(t("<a>").attr({href:"#",tabindex:"-1"}).addClass("btn").attr("data-action","decrementSeconds").append(t("<span>").addClass(n.icons.down))))),o||(e.append(t("<td>").addClass("separator")),i.append(t("<td>").append(t("<button>").addClass("btn btn-primary").attr("data-action","togglePeriod"))),s.append(t("<td>").addClass("separator"))),t("<div>").addClass("timepicker-picker").append(t("<table>").addClass("table-condensed").append([e,i,s]))},E=function(){var e=t("<div>").addClass("timepicker-hours").append(t("<table>").addClass("table-condensed")),i=t("<div>").addClass("timepicker-minutes").append(t("<table>").addClass("table-condensed")),n=t("<div>").addClass("timepicker-seconds").append(t("<table>").addClass("table-condensed")),s=[S()];return C("h")&&s.push(e),C("m")&&s.push(i),C("s")&&s.push(n),s},A=function(){var e=[];return n.showTodayButton&&e.push(t("<td>").append(t("<a>").attr("data-action","today").append(t("<span>").addClass(n.icons.today)))),!n.sideBySide&&D()&&k()&&e.push(t("<td>").append(t("<a>").attr("data-action","togglePicker").append(t("<span>").addClass(n.icons.time)))),n.showClear&&e.push(t("<td>").append(t("<a>").attr("data-action","clear").append(t("<span>").addClass(n.icons.clear)))),n.showClose&&e.push(t("<td>").append(t("<a>").attr("data-action","close").append(t("<span>").addClass(n.icons.close)))),t("<table>").addClass("table-condensed").append(t("<tbody>").append(t("<tr>").append(e)))},M=function(){var e=t("<div>").addClass("bootstrap-datetimepicker-widget dropdown-menu"),i=t("<div>").addClass("datepicker").append(T()),s=t("<div>").addClass("timepicker").append(E()),r=t("<ul>").addClass("list-unstyled"),a=t("<li>").addClass("picker-switch"+(n.collapse?" accordion-toggle":"")).append(A());return n.inline&&e.removeClass("dropdown-menu"),o&&e.addClass("usetwentyfour"),n.sideBySide&&D()&&k()?(e.addClass("timepicker-sbs"),e.append(t("<div>").addClass("row").append(i.addClass("col-sm-6")).append(s.addClass("col-sm-6"))),e.append(a),e):("top"===n.toolbarPlacement&&r.append(a),D()&&r.append(t("<li>").addClass(n.collapse&&k()?"collapse in":"").append(i)),"default"===n.toolbarPlacement&&r.append(a),k()&&r.append(t("<li>").addClass(n.collapse&&D()?"collapse":"").append(s)),"bottom"===n.toolbarPlacement&&r.append(a),e.append(r))},I=function(){var e,s={};return e=i.is("input")||n.inline?i.data():i.find("input").data(),e.dateOptions&&e.dateOptions instanceof Object&&(s=t.extend(!0,s,e.dateOptions)),t.each(n,function(t){var i="date"+t.charAt(0).toUpperCase()+t.slice(1);void 0!==e[i]&&(s[t]=e[i])}),s},P=function(){var e,s=(p||i).position(),o=(p||i).offset(),r=n.widgetPositioning.vertical,a=n.widgetPositioning.horizontal;if(n.widgetParent)e=n.widgetParent.append(f);else if(i.is("input"))e=i.parent().append(f);else{if(n.inline)return void(e=i.append(f));e=i,i.children().first().after(f)}if("auto"===r&&(r=o.top+1.5*f.height()>=t(window).height()+t(window).scrollTop()&&f.height()+i.outerHeight()<o.top?"top":"bottom"),"auto"===a&&(a=e.width()<o.left+f.outerWidth()/2&&o.left+f.outerWidth()>t(window).width()?"right":"left"),"top"===r?f.addClass("top").removeClass("bottom"):f.addClass("bottom").removeClass("top"),"right"===a?f.addClass("pull-right"):f.removeClass("pull-right"),"relative"!==e.css("position")&&(e=e.parents().filter(function(){return"relative"===t(this).css("position")}).first()),0===e.length)throw new Error("datetimepicker component should be placed within a relative positioned container");f.css({top:"top"===r?"auto":s.top+i.outerHeight(),bottom:"top"===r?s.top+i.outerHeight():"auto",left:"left"===a?e.css("padding-left"):"auto",right:"left"===a?"auto":e.width()-i.outerWidth()})},$=function(t){"dp.change"===t.type&&(t.date&&t.date.isSame(t.oldDate)||!t.date&&!t.oldDate)||i.trigger(t)},O=function(t){f&&(t&&(l=Math.max(m,Math.min(2,l+t))),f.find(".datepicker > div").hide().filter(".datepicker-"+g[l].clsName).show())},N=function(){var e=t("<tr>"),i=h.clone().startOf("w");for(n.calendarWeeks===!0&&e.append(t("<th>").addClass("cw").text("#"));i.isBefore(h.clone().endOf("w"));)e.append(t("<th>").addClass("dow").text(i.format("dd"))),i.add(1,"d");f.find(".datepicker-days thead").append(e)},H=function(t){return n.disabledDates[t.format("YYYY-MM-DD")]===!0},j=function(t){return n.enabledDates[t.format("YYYY-MM-DD")]===!0},L=function(t,e){return!!t.isValid()&&((!n.disabledDates||!H(t)||"M"===e)&&(!(n.enabledDates&&!j(t)&&"M"!==e)&&((!n.minDate||!t.isBefore(n.minDate,e))&&((!n.maxDate||!t.isAfter(n.maxDate,e))&&("d"!==e||n.daysOfWeekDisabled.indexOf(t.day())===-1)))))},z=function(){for(var e=[],i=h.clone().startOf("y").hour(12);i.isSame(h,"y");)e.push(t("<span>").attr("data-action","selectMonth").addClass("month").text(i.format("MMM"))),i.add(1,"M");f.find(".datepicker-months td").empty().append(e)},W=function(){var e=f.find(".datepicker-months"),i=e.find("th"),n=e.find("tbody").find("span");e.find(".disabled").removeClass("disabled"),L(h.clone().subtract(1,"y"),"y")||i.eq(0).addClass("disabled"),i.eq(1).text(h.year()),L(h.clone().add(1,"y"),"y")||i.eq(2).addClass("disabled"),n.removeClass("active"),u.isSame(h,"y")&&n.eq(u.month()).addClass("active"),n.each(function(e){L(h.clone().month(e),"M")||t(this).addClass("disabled")})},F=function(){var t=f.find(".datepicker-years"),e=t.find("th"),i=h.clone().subtract(5,"y"),s=h.clone().add(6,"y"),o="";for(t.find(".disabled").removeClass("disabled"),n.minDate&&n.minDate.isAfter(i,"y")&&e.eq(0).addClass("disabled"),e.eq(1).text(i.year()+"-"+s.year()),n.maxDate&&n.maxDate.isBefore(s,"y")&&e.eq(2).addClass("disabled");!i.isAfter(s,"y");)o+='<span data-action="selectYear" class="year'+(i.isSame(u,"y")?" active":"")+(L(i,"y")?"":" disabled")+'">'+i.year()+"</span>",i.add(1,"y");t.find("td").html(o)},R=function(){var i,s,o,r,a=f.find(".datepicker-days"),l=a.find("th"),c=[];if(D()){for(a.find(".disabled").removeClass("disabled"),l.eq(1).text(h.format(n.dayViewHeaderFormat)),L(h.clone().subtract(1,"M"),"M")||l.eq(0).addClass("disabled"),L(h.clone().add(1,"M"),"M")||l.eq(2).addClass("disabled"),i=h.clone().startOf("M").startOf("week"),r=0;r<42;r++)0===i.weekday()&&(s=t("<tr>"),n.calendarWeeks&&s.append('<td class="cw">'+i.week()+"</td>"),c.push(s)),o="",i.isBefore(h,"M")&&(o+=" old"),i.isAfter(h,"M")&&(o+=" new"),i.isSame(u,"d")&&!d&&(o+=" active"),L(i,"d")||(o+=" disabled"),i.isSame(e(),"d")&&(o+=" today"),0!==i.day()&&6!==i.day()||(o+=" weekend"),s.append('<td data-action="selectDay" data-day="'+i.format("L")+'" class="day'+o+'">'+i.date()+"</td>"),i.add(1,"d");a.find("tbody").empty().append(c),W(),F()}},q=function(){var e=f.find(".timepicker-hours table"),i=h.clone().startOf("d"),n=[],s=t("<tr>");for(h.hour()>11&&!o&&i.hour(12);i.isSame(h,"d")&&(o||h.hour()<12&&i.hour()<12||h.hour()>11);)i.hour()%4===0&&(s=t("<tr>"),n.push(s)),s.append('<td data-action="selectHour" class="hour'+(L(i,"h")?"":" disabled")+'">'+i.format(o?"HH":"hh")+"</td>"),i.add(1,"h");e.empty().append(n)},Y=function(){for(var e=f.find(".timepicker-minutes table"),i=h.clone().startOf("h"),s=[],o=t("<tr>"),r=1===n.stepping?5:n.stepping;h.isSame(i,"h");)i.minute()%(4*r)===0&&(o=t("<tr>"),s.push(o)),o.append('<td data-action="selectMinute" class="minute'+(L(i,"m")?"":" disabled")+'">'+i.format("mm")+"</td>"),i.add(r,"m");e.empty().append(s)},B=function(){for(var e=f.find(".timepicker-seconds table"),i=h.clone().startOf("m"),n=[],s=t("<tr>");h.isSame(i,"m");)i.second()%20===0&&(s=t("<tr>"),n.push(s)),s.append('<td data-action="selectSecond" class="second'+(L(i,"s")?"":" disabled")+'">'+i.format("ss")+"</td>"),i.add(5,"s");e.empty().append(n)},U=function(){var t=f.find(".timepicker span[data-time-component]");o||f.find(".timepicker [data-action=togglePeriod]").text(u.format("A")),t.filter("[data-time-component=hours]").text(u.format(o?"HH":"hh")),t.filter("[data-time-component=minutes]").text(u.format("mm")),t.filter("[data-time-component=seconds]").text(u.format("ss")),q(),Y(),B()},V=function(){f&&(R(),U())},K=function(t){var e=d?null:u;return t?(t=t.clone().locale(n.locale),1!==n.stepping&&t.minutes(Math.round(t.minutes()/n.stepping)*n.stepping%60).seconds(0),void(L(t)?(u=t,h=u.clone(),s.val(u.format(r)),i.data("date",u.format(r)),V(),d=!1,$({type:"dp.change",date:u.clone(),oldDate:e})):(n.keepInvalid||s.val(d?"":u.format(r)),$({type:"dp.error",date:t})))):(d=!0,s.val(""),i.data("date",""),$({type:"dp.change",date:null,oldDate:e}),void V())},Q=function(){var e=!1;return f?(f.find(".collapse").each(function(){var i=t(this).data("collapse");return!i||!i.transitioning||(e=!0,!1)}),e?c:(p&&p.hasClass("btn")&&p.toggleClass("active"),f.hide(),t(window).off("resize",P),f.off("click","[data-action]"),f.off("mousedown",!1),f.remove(),f=!1,$({type:"dp.hide",date:u.clone()}),c)):c},G=function(){K(null)},X={next:function(){h.add(g[l].navStep,g[l].navFnc),R()},previous:function(){h.subtract(g[l].navStep,g[l].navFnc),R()},pickerSwitch:function(){O(1)},selectMonth:function(e){var i=t(e.target).closest("tbody").find("span").index(t(e.target));h.month(i),l===m?(K(u.clone().year(h.year()).month(h.month())),n.inline||Q()):(O(-1),R())},selectYear:function(e){var i=parseInt(t(e.target).text(),10)||0;h.year(i),l===m?(K(u.clone().year(h.year())),n.inline||Q()):(O(-1),R())},selectDay:function(e){var i=h.clone();t(e.target).is(".old")&&i.subtract(1,"M"),t(e.target).is(".new")&&i.add(1,"M"),K(i.date(parseInt(t(e.target).text(),10))),k()||n.keepOpen||n.inline||Q()},incrementHours:function(){K(u.clone().add(1,"h"))},incrementMinutes:function(){K(u.clone().add(n.stepping,"m"))},incrementSeconds:function(){K(u.clone().add(1,"s"))},decrementHours:function(){K(u.clone().subtract(1,"h"))},decrementMinutes:function(){K(u.clone().subtract(n.stepping,"m"))},decrementSeconds:function(){K(u.clone().subtract(1,"s"))},togglePeriod:function(){K(u.clone().add(u.hours()>=12?-12:12,"h"))},togglePicker:function(e){var i,s=t(e.target),o=s.closest("ul"),r=o.find(".in"),a=o.find(".collapse:not(.in)");if(r&&r.length){if(i=r.data("collapse"),i&&i.transitioning)return;r.collapse?(r.collapse("hide"),a.collapse("show")):(r.removeClass("in"),a.addClass("in")),s.is("span")?s.toggleClass(n.icons.time+" "+n.icons.date):s.find("span").toggleClass(n.icons.time+" "+n.icons.date)}},showPicker:function(){f.find(".timepicker > div:not(.timepicker-picker)").hide(),f.find(".timepicker .timepicker-picker").show()},showHours:function(){f.find(".timepicker .timepicker-picker").hide(),f.find(".timepicker .timepicker-hours").show()},showMinutes:function(){f.find(".timepicker .timepicker-picker").hide(),f.find(".timepicker .timepicker-minutes").show()},showSeconds:function(){f.find(".timepicker .timepicker-picker").hide(),f.find(".timepicker .timepicker-seconds").show()},selectHour:function(e){var i=parseInt(t(e.target).text(),10);o||(u.hours()>=12?12!==i&&(i+=12):12===i&&(i=0)),K(u.clone().hours(i)),X.showPicker.call(c)},selectMinute:function(e){K(u.clone().minutes(parseInt(t(e.target).text(),10))),X.showPicker.call(c)},selectSecond:function(e){K(u.clone().seconds(parseInt(t(e.target).text(),10))),X.showPicker.call(c)},clear:G,today:function(){K(e())},close:Q},Z=function(e){return!t(e.currentTarget).is(".disabled")&&(X[t(e.currentTarget).data("action")].apply(c,arguments),!1)},J=function(){var i,o={year:function(t){return t.month(0).date(1).hours(0).seconds(0).minutes(0)},month:function(t){return t.date(1).hours(0).seconds(0).minutes(0)},day:function(t){return t.hours(0).seconds(0).minutes(0)},hour:function(t){return t.seconds(0).minutes(0)},minute:function(t){return t.seconds(0)}};return s.prop("disabled")||!n.ignoreReadonly&&s.prop("readonly")||f?c:(n.useCurrent&&d&&(s.is("input")&&0===s.val().trim().length||n.inline)&&(i=e(),"string"==typeof n.useCurrent&&(i=o[n.useCurrent](i)),K(i)),f=M(),N(),z(),f.find(".timepicker-hours").hide(),f.find(".timepicker-minutes").hide(),f.find(".timepicker-seconds").hide(),V(),O(),t(window).on("resize",P),f.on("click","[data-action]",Z),f.on("mousedown",!1),p&&p.hasClass("btn")&&p.toggleClass("active"),f.show(),P(),s.is(":focus")||s.focus(),$({type:"dp.show"}),c)},tt=function(){return f?Q():J()},et=function(t){return t=e.isMoment(t)||t instanceof Date?e(t):e(t,a,n.useStrict),t.locale(n.locale),t},it=function(t){var e,i,s,o,r=null,a=[],l={},u=t.which,h="p";x[u]=h;for(e in x)x.hasOwnProperty(e)&&x[e]===h&&(a.push(e),parseInt(e,10)!==u&&(l[e]=!0));for(e in n.keyBinds)if(n.keyBinds.hasOwnProperty(e)&&"function"==typeof n.keyBinds[e]&&(s=e.split(" "),s.length===a.length&&w[u]===s[s.length-1])){for(o=!0,i=s.length-2;i>=0;i--)if(!(w[s[i]]in l)){o=!1;break}if(o){r=n.keyBinds[e];break}}r&&(r.call(c,f),t.stopPropagation(),t.preventDefault())},nt=function(t){x[t.which]="r",t.stopPropagation(),t.preventDefault()},st=function(e){var i=t(e.target).val().trim(),n=i?et(i):null;return K(n),e.stopImmediatePropagation(),!1},ot=function(){s.on({change:st,blur:n.debug?"":Q,keydown:it,keyup:nt}),i.is("input")?s.on({focus:J}):p&&(p.on("click",tt),p.on("mousedown",!1))},rt=function(){s.off({change:st,blur:Q,keydown:it,keyup:nt}),i.is("input")?s.off({focus:J}):p&&(p.off("click",tt),p.off("mousedown",!1))},at=function(e){var i={};return t.each(e,function(){var t=et(this);t.isValid()&&(i[t.format("YYYY-MM-DD")]=!0)}),!!Object.keys(i).length&&i},lt=function(){var t=n.format||"L LT";r=t.replace(/(\[[^\[]*\])|(\\)?(LTS|LT|LL?L?L?|l{1,4})/g,function(t){var e=u.localeData().longDateFormat(t)||t;return e.replace(/(\[[^\[]*\])|(\\)?(LTS|LT|LL?L?L?|l{1,4})/g,function(t){return u.localeData().longDateFormat(t)||t})}),a=n.extraFormats?n.extraFormats.slice():[],a.indexOf(t)<0&&a.indexOf(r)<0&&a.push(r),o=r.toLowerCase().indexOf("a")<1&&r.indexOf("h")<1,C("y")&&(m=2),C("M")&&(m=1),C("d")&&(m=0),l=Math.max(m,l),d||K(u)};if(c.destroy=function(){Q(),rt(),i.removeData("DateTimePicker"),i.removeData("date")},c.toggle=tt,c.show=J,c.hide=Q,c.disable=function(){return Q(),p&&p.hasClass("btn")&&p.addClass("disabled"),s.prop("disabled",!0),c},c.enable=function(){return p&&p.hasClass("btn")&&p.removeClass("disabled"),s.prop("disabled",!1),c},c.ignoreReadonly=function(t){if(0===arguments.length)return n.ignoreReadonly;if("boolean"!=typeof t)throw new TypeError("ignoreReadonly () expects a boolean parameter");return n.ignoreReadonly=t,c},c.options=function(e){if(0===arguments.length)return t.extend(!0,{},n);if(!(e instanceof Object))throw new TypeError("options() options parameter should be an object");return t.extend(!0,n,e),t.each(n,function(t,e){if(void 0===c[t])throw new TypeError("option "+t+" is not recognized!");c[t](e)}),c},c.date=function(t){if(0===arguments.length)return d?null:u.clone();if(!(null===t||"string"==typeof t||e.isMoment(t)||t instanceof Date))throw new TypeError("date() parameter must be one of [null, string, moment or Date]");return K(null===t?null:et(t)),c},c.format=function(t){if(0===arguments.length)return n.format;if("string"!=typeof t&&("boolean"!=typeof t||t!==!1))throw new TypeError("format() expects a sting or boolean:false parameter "+t);return n.format=t,r&&lt(),c},c.dayViewHeaderFormat=function(t){if(0===arguments.length)return n.dayViewHeaderFormat;if("string"!=typeof t)throw new TypeError("dayViewHeaderFormat() expects a string parameter");return n.dayViewHeaderFormat=t,c},c.extraFormats=function(t){if(0===arguments.length)return n.extraFormats;if(t!==!1&&!(t instanceof Array))throw new TypeError("extraFormats() expects an array or false parameter");return n.extraFormats=t,a&&lt(),c},c.disabledDates=function(e){if(0===arguments.length)return n.disabledDates?t.extend({},n.disabledDates):n.disabledDates;if(!e)return n.disabledDates=!1,V(),c;if(!(e instanceof Array))throw new TypeError("disabledDates() expects an array parameter");return n.disabledDates=at(e),n.enabledDates=!1,V(),c},c.enabledDates=function(e){if(0===arguments.length)return n.enabledDates?t.extend({},n.enabledDates):n.enabledDates;if(!e)return n.enabledDates=!1,V(),c;if(!(e instanceof Array))throw new TypeError("enabledDates() expects an array parameter");return n.enabledDates=at(e),n.disabledDates=!1,V(),c},c.daysOfWeekDisabled=function(t){if(0===arguments.length)return n.daysOfWeekDisabled.splice(0);if(!(t instanceof Array))throw new TypeError("daysOfWeekDisabled() expects an array parameter");return n.daysOfWeekDisabled=t.reduce(function(t,e){return e=parseInt(e,10),e>6||e<0||isNaN(e)?t:(t.indexOf(e)===-1&&t.push(e),t)},[]).sort(),V(),c},c.maxDate=function(t){if(0===arguments.length)return n.maxDate?n.maxDate.clone():n.maxDate;if("boolean"==typeof t&&t===!1)return n.maxDate=!1,V(),c;"string"==typeof t&&("now"!==t&&"moment"!==t||(t=e()));var i=et(t);if(!i.isValid())throw new TypeError("maxDate() Could not parse date parameter: "+t);if(n.minDate&&i.isBefore(n.minDate))throw new TypeError("maxDate() date parameter is before options.minDate: "+i.format(r));return n.maxDate=i,n.maxDate.isBefore(t)&&K(n.maxDate),h.isAfter(i)&&(h=i.clone()),V(),c},c.minDate=function(t){if(0===arguments.length)return n.minDate?n.minDate.clone():n.minDate;if("boolean"==typeof t&&t===!1)return n.minDate=!1,V(),c;"string"==typeof t&&("now"!==t&&"moment"!==t||(t=e()));var i=et(t);if(!i.isValid())throw new TypeError("minDate() Could not parse date parameter: "+t);if(n.maxDate&&i.isAfter(n.maxDate))throw new TypeError("minDate() date parameter is after options.maxDate: "+i.format(r));return n.minDate=i,n.minDate.isAfter(t)&&K(n.minDate),h.isBefore(i)&&(h=i.clone()),V(),c},c.defaultDate=function(t){if(0===arguments.length)return n.defaultDate?n.defaultDate.clone():n.defaultDate;if(!t)return n.defaultDate=!1,c;"string"==typeof t&&("now"!==t&&"moment"!==t||(t=e()));var i=et(t);if(!i.isValid())throw new TypeError("defaultDate() Could not parse date parameter: "+t);if(!L(i))throw new TypeError("defaultDate() date passed is invalid according to component setup validations");return n.defaultDate=i,n.defaultDate&&""===s.val().trim()&&void 0===s.attr("placeholder")&&K(n.defaultDate),c},c.locale=function(t){if(0===arguments.length)return n.locale;if(!e.localeData(t))throw new TypeError("locale() locale "+t+" is not loaded from moment locales!");return n.locale=t,u.locale(n.locale),h.locale(n.locale),r&&lt(),f&&(Q(),J()),c},c.stepping=function(t){return 0===arguments.length?n.stepping:(t=parseInt(t,10),(isNaN(t)||t<1)&&(t=1),n.stepping=t,c)},c.useCurrent=function(t){var e=["year","month","day","hour","minute"];if(0===arguments.length)return n.useCurrent;if("boolean"!=typeof t&&"string"!=typeof t)throw new TypeError("useCurrent() expects a boolean or string parameter");if("string"==typeof t&&e.indexOf(t.toLowerCase())===-1)throw new TypeError("useCurrent() expects a string parameter of "+e.join(", "));return n.useCurrent=t,c},c.collapse=function(t){if(0===arguments.length)return n.collapse;if("boolean"!=typeof t)throw new TypeError("collapse() expects a boolean parameter");return n.collapse===t?c:(n.collapse=t,f&&(Q(),J()),c)},c.icons=function(e){if(0===arguments.length)return t.extend({},n.icons);if(!(e instanceof Object))throw new TypeError("icons() expects parameter to be an Object");return t.extend(n.icons,e),f&&(Q(),J()),c},c.useStrict=function(t){if(0===arguments.length)return n.useStrict;if("boolean"!=typeof t)throw new TypeError("useStrict() expects a boolean parameter");return n.useStrict=t,c},c.sideBySide=function(t){if(0===arguments.length)return n.sideBySide;if("boolean"!=typeof t)throw new TypeError("sideBySide() expects a boolean parameter");return n.sideBySide=t,f&&(Q(),J()),c},c.viewMode=function(t){if(0===arguments.length)return n.viewMode;if("string"!=typeof t)throw new TypeError("viewMode() expects a string parameter");if(v.indexOf(t)===-1)throw new TypeError("viewMode() parameter must be one of ("+v.join(", ")+") value");return n.viewMode=t,l=Math.max(v.indexOf(t),m),O(),c},c.toolbarPlacement=function(t){if(0===arguments.length)return n.toolbarPlacement;if("string"!=typeof t)throw new TypeError("toolbarPlacement() expects a string parameter");if(_.indexOf(t)===-1)throw new TypeError("toolbarPlacement() parameter must be one of ("+_.join(", ")+") value");return n.toolbarPlacement=t,f&&(Q(),J()),c},c.widgetPositioning=function(e){if(0===arguments.length)return t.extend({},n.widgetPositioning);if("[object Object]"!=={}.toString.call(e))throw new TypeError("widgetPositioning() expects an object variable");if(e.horizontal){if("string"!=typeof e.horizontal)throw new TypeError("widgetPositioning() horizontal variable must be a string");if(e.horizontal=e.horizontal.toLowerCase(),b.indexOf(e.horizontal)===-1)throw new TypeError("widgetPositioning() expects horizontal parameter to be one of ("+b.join(", ")+")");n.widgetPositioning.horizontal=e.horizontal}if(e.vertical){if("string"!=typeof e.vertical)throw new TypeError("widgetPositioning() vertical variable must be a string");if(e.vertical=e.vertical.toLowerCase(),y.indexOf(e.vertical)===-1)throw new TypeError("widgetPositioning() expects vertical parameter to be one of ("+y.join(", ")+")");n.widgetPositioning.vertical=e.vertical}return V(),c},c.calendarWeeks=function(t){if(0===arguments.length)return n.calendarWeeks;if("boolean"!=typeof t)throw new TypeError("calendarWeeks() expects parameter to be a boolean value");return n.calendarWeeks=t,V(),c},c.showTodayButton=function(t){if(0===arguments.length)return n.showTodayButton;if("boolean"!=typeof t)throw new TypeError("showTodayButton() expects a boolean parameter");return n.showTodayButton=t,f&&(Q(),J()),c},c.showClear=function(t){if(0===arguments.length)return n.showClear;if("boolean"!=typeof t)throw new TypeError("showClear() expects a boolean parameter");return n.showClear=t,f&&(Q(),J()),c},c.widgetParent=function(e){if(0===arguments.length)return n.widgetParent;if("string"==typeof e&&(e=t(e)),null!==e&&"string"!=typeof e&&!(e instanceof t))throw new TypeError("widgetParent() expects a string or a jQuery object parameter");return n.widgetParent=e,f&&(Q(),J()),c},c.keepOpen=function(t){if(0===arguments.length)return n.keepOpen;if("boolean"!=typeof t)throw new TypeError("keepOpen() expects a boolean parameter");return n.keepOpen=t,c},c.inline=function(t){if(0===arguments.length)return n.inline;if("boolean"!=typeof t)throw new TypeError("inline() expects a boolean parameter");return n.inline=t,c},c.clear=function(){return G(),c},c.keyBinds=function(t){return n.keyBinds=t,c},c.debug=function(t){if("boolean"!=typeof t)throw new TypeError("debug() expects a boolean parameter");return n.debug=t,c},c.showClose=function(t){if(0===arguments.length)return n.showClose;if("boolean"!=typeof t)throw new TypeError("showClose() expects a boolean parameter");return n.showClose=t,c},c.keepInvalid=function(t){if(0===arguments.length)return n.keepInvalid;if("boolean"!=typeof t)throw new TypeError("keepInvalid() expects a boolean parameter");return n.keepInvalid=t,c},c.datepickerInput=function(t){if(0===arguments.length)return n.datepickerInput;if("string"!=typeof t)throw new TypeError("datepickerInput() expects a string parameter");return n.datepickerInput=t,c},i.is("input"))s=i;else if(s=i.find(n.datepickerInput),0===s.size())s=i.find("input");else if(!s.is("input"))throw new Error('CSS class "'+n.datepickerInput+'" cannot be applied to non input element');if(i.hasClass("input-group")&&(p=0===i.find(".datepickerbutton").size()?i.find('[class^="input-group-"]'):i.find(".datepickerbutton")),!n.inline&&!s.is("input"))throw new Error("Could not initialize DateTimePicker without an input element");return t.extend(!0,n,I()),c.options(n),lt(),ot(),s.prop("disabled")&&c.disable(),s.is("input")&&0!==s.val().trim().length?K(et(s.val().trim())):n.defaultDate&&void 0===s.attr("placeholder")&&K(n.defaultDate),n.inline&&J(),c};t.fn.datetimepicker=function(e){return this.each(function(){var n=t(this);n.data("DateTimePicker")||(e=t.extend(!0,{},t.fn.datetimepicker.defaults,e),n.data("DateTimePicker",i(n,e)))})},t.fn.datetimepicker.defaults={format:!1,dayViewHeaderFormat:"MMMM YYYY",extraFormats:!1,stepping:1,minDate:!1,maxDate:!1,useCurrent:!0,collapse:!0,locale:e.locale(),defaultDate:!1,disabledDates:!1,enabledDates:!1,icons:{time:"glyphicon glyphicon-time",date:"glyphicon glyphicon-calendar",up:"glyphicon glyphicon-chevron-up",down:"glyphicon glyphicon-chevron-down",previous:"glyphicon glyphicon-chevron-left",next:"glyphicon glyphicon-chevron-right",today:"glyphicon glyphicon-screenshot",clear:"glyphicon glyphicon-trash",close:"glyphicon glyphicon-remove"},useStrict:!1,sideBySide:!1,daysOfWeekDisabled:[],calendarWeeks:!1,viewMode:"days",toolbarPlacement:"default",showTodayButton:!1,showClear:!1,showClose:!1,widgetPositioning:{horizontal:"auto",vertical:"auto"},widgetParent:null,ignoreReadonly:!1,keepOpen:!1,inline:!1,keepInvalid:!1,datepickerInput:".datepickerinput",keyBinds:{up:function(t){if(t){var i=this.date()||e();t.find(".datepicker").is(":visible")?this.date(i.clone().subtract(7,"d")):this.date(i.clone().add(1,"m"))}},down:function(t){if(!t)return void this.show();var i=this.date()||e();t.find(".datepicker").is(":visible")?this.date(i.clone().add(7,"d")):this.date(i.clone().subtract(1,"m"))},"control up":function(t){if(t){var i=this.date()||e();t.find(".datepicker").is(":visible")?this.date(i.clone().subtract(1,"y")):this.date(i.clone().add(1,"h"))}},"control down":function(t){if(t){var i=this.date()||e();t.find(".datepicker").is(":visible")?this.date(i.clone().add(1,"y")):this.date(i.clone().subtract(1,"h"))}},left:function(t){if(t){var i=this.date()||e();t.find(".datepicker").is(":visible")&&this.date(i.clone().subtract(1,"d"))}},right:function(t){if(t){var i=this.date()||e();t.find(".datepicker").is(":visible")&&this.date(i.clone().add(1,"d"))}},pageUp:function(t){if(t){var i=this.date()||e();t.find(".datepicker").is(":visible")&&this.date(i.clone().subtract(1,"M"))}},pageDown:function(t){if(t){var i=this.date()||e();t.find(".datepicker").is(":visible")&&this.date(i.clone().add(1,"M"))}},enter:function(){this.hide()},escape:function(){this.hide()},"control space":function(t){t.find(".timepicker").is(":visible")&&t.find('.btn[data-action="togglePeriod"]').click()},t:function(){this.date(e())},"delete":function(){this.clear()}},debug:!1}});