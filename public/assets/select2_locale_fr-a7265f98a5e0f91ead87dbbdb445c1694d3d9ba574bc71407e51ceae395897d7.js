!function(){if(jQuery&&jQuery.fn&&jQuery.fn.select2&&jQuery.fn.select2.amd)var e=jQuery.fn.select2.amd;return e.define("select2/i18n/fr",[],function(){return{errorLoading:function(){return"Les r\xe9sultats ne peuvent pas \xeatre charg\xe9s."},inputTooLong:function(e){var t=e.input.length-e.maximum,n="Supprimez "+t+" caract\xe8re";return 1!==t&&(n+="s"),n},inputTooShort:function(e){var t=e.minimum-e.input.length,n="Saisissez "+t+" caract\xe8re";return 1!==t&&(n+="s"),n},loadingMore:function(){return"Chargement de r\xe9sultats suppl\xe9mentaires\u2026"},maximumSelected:function(e){var t="Vous pouvez seulement s\xe9lectionner "+e.maximum+" \xe9l\xe9ment";return 1!==e.maximum&&(t+="s"),t},noResults:function(){return"Aucun r\xe9sultat trouv\xe9"},searching:function(){return"Recherche en cours\u2026"}}}),{define:e.define,require:e.require}}();