!function(e,t){"object"==typeof exports&&"undefined"!=typeof module&&"function"==typeof require?t(require("../moment")):"function"==typeof define&&define.amd?define(["moment"],t):t(e.moment)}(this,function(e){"use strict";var t={0:"-\u0448\u0456",1:"-\u0448\u0456",2:"-\u0448\u0456",3:"-\u0448\u0456",4:"-\u0448\u0456",5:"-\u0448\u0456",6:"-\u0448\u044b",7:"-\u0448\u0456",8:"-\u0448\u0456",9:"-\u0448\u044b",10:"-\u0448\u044b",20:"-\u0448\u044b",30:"-\u0448\u044b",40:"-\u0448\u044b",50:"-\u0448\u0456",60:"-\u0448\u044b",70:"-\u0448\u0456",80:"-\u0448\u0456",90:"-\u0448\u044b",100:"-\u0448\u0456"},n=e.defineLocale("kk",{months:"\u049a\u0430\u04a3\u0442\u0430\u0440_\u0410\u049b\u043f\u0430\u043d_\u041d\u0430\u0443\u0440\u044b\u0437_\u0421\u04d9\u0443\u0456\u0440_\u041c\u0430\u043c\u044b\u0440_\u041c\u0430\u0443\u0441\u044b\u043c_\u0428\u0456\u043b\u0434\u0435_\u0422\u0430\u043c\u044b\u0437_\u049a\u044b\u0440\u043a\u04af\u0439\u0435\u043a_\u049a\u0430\u0437\u0430\u043d_\u049a\u0430\u0440\u0430\u0448\u0430_\u0416\u0435\u043b\u0442\u043e\u049b\u0441\u0430\u043d".split("_"),monthsShort:"\u049a\u0430\u04a3_\u0410\u049b\u043f_\u041d\u0430\u0443_\u0421\u04d9\u0443_\u041c\u0430\u043c_\u041c\u0430\u0443_\u0428\u0456\u043b_\u0422\u0430\u043c_\u049a\u044b\u0440_\u049a\u0430\u0437_\u049a\u0430\u0440_\u0416\u0435\u043b".split("_"),weekdays:"\u0416\u0435\u043a\u0441\u0435\u043d\u0431\u0456_\u0414\u04af\u0439\u0441\u0435\u043d\u0431\u0456_\u0421\u0435\u0439\u0441\u0435\u043d\u0431\u0456_\u0421\u04d9\u0440\u0441\u0435\u043d\u0431\u0456_\u0411\u0435\u0439\u0441\u0435\u043d\u0431\u0456_\u0416\u04b1\u043c\u0430_\u0421\u0435\u043d\u0431\u0456".split("_"),weekdaysShort:"\u0416\u0435\u043a_\u0414\u04af\u0439_\u0421\u0435\u0439_\u0421\u04d9\u0440_\u0411\u0435\u0439_\u0416\u04b1\u043c_\u0421\u0435\u043d".split("_"),weekdaysMin:"\u0416\u043a_\u0414\u0439_\u0421\u0439_\u0421\u0440_\u0411\u0439_\u0416\u043c_\u0421\u043d".split("_"),longDateFormat:{LT:"HH:mm",LTS:"HH:mm:ss",L:"DD.MM.YYYY",LL:"D MMMM YYYY",LLL:"D MMMM YYYY HH:mm",LLLL:"dddd, D MMMM YYYY HH:mm"},calendar:{sameDay:"[\u0411\u04af\u0433\u0456\u043d \u0441\u0430\u0493\u0430\u0442] LT",nextDay:"[\u0415\u0440\u0442\u0435\u04a3 \u0441\u0430\u0493\u0430\u0442] LT",nextWeek:"dddd [\u0441\u0430\u0493\u0430\u0442] LT",lastDay:"[\u041a\u0435\u0448\u0435 \u0441\u0430\u0493\u0430\u0442] LT",lastWeek:"[\u04e8\u0442\u043a\u0435\u043d \u0430\u043f\u0442\u0430\u043d\u044b\u04a3] dddd [\u0441\u0430\u0493\u0430\u0442] LT",sameElse:"L"},relativeTime:{future:"%s \u0456\u0448\u0456\u043d\u0434\u0435",past:"%s \u0431\u04b1\u0440\u044b\u043d",s:"\u0431\u0456\u0440\u043d\u0435\u0448\u0435 \u0441\u0435\u043a\u0443\u043d\u0434",m:"\u0431\u0456\u0440 \u043c\u0438\u043d\u0443\u0442",mm:"%d \u043c\u0438\u043d\u0443\u0442",h:"\u0431\u0456\u0440 \u0441\u0430\u0493\u0430\u0442",hh:"%d \u0441\u0430\u0493\u0430\u0442",d:"\u0431\u0456\u0440 \u043a\u04af\u043d",dd:"%d \u043a\u04af\u043d",M:"\u0431\u0456\u0440 \u0430\u0439",MM:"%d \u0430\u0439",y:"\u0431\u0456\u0440 \u0436\u044b\u043b",yy:"%d \u0436\u044b\u043b"},ordinalParse:/\d{1,2}-(\u0448\u0456|\u0448\u044b)/,ordinal:function(e){var n=e%10,r=e>=100?100:null;return e+(t[e]||t[n]||t[r])},week:{dow:1,doy:7}});return n});