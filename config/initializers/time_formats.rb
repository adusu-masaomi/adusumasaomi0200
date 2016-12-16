Time::DATE_FORMATS[:default] = '%Y/%m/%d %H:%M'
Time::DATE_FORMATS[:datetime] = '%Y/%m/%d %H:%M'
Time::DATE_FORMATS[:date] = '%Y/%m/%d'
Date::DATE_FORMATS[:default] = '%Y/%m/%d'
# 以下はなぜかNGなのでenviroment.rbに記述する
Time::DATE_FORMATS[:start_time_1] = '%H:%M'
