!function(){if(jQuery&&jQuery.fn&&jQuery.fn.select2&&jQuery.fn.select2.amd)var e=jQuery.fn.select2.amd;return e.define("select2/i18n/lv",[],function(){function e(e,t,n,i){return 11===e?t:e%10===1?n:i}return{inputTooLong:function(t){var n=t.input.length-t.maximum,i="L\u016bdzu ievadiet par  "+n;return i+=" simbol"+e(n,"iem","u","iem"),i+" maz\u0101k"},inputTooShort:function(t){var n=t.minimum-t.input.length,i="L\u016bdzu ievadiet v\u0113l "+n;return i+=" simbol"+e(n,"us","u","us")},loadingMore:function(){return"Datu iel\u0101de\u2026"},maximumSelected:function(t){var n="J\u016bs varat izv\u0113l\u0113ties ne vair\u0101k k\u0101 "+t.maximum;return n+=" element"+e(t.maximum,"us","u","us")},noResults:function(){return"Sakrit\u012bbu nav"},searching:function(){return"Mekl\u0113\u0161ana\u2026"}}}),{define:e.define,require:e.require}}();