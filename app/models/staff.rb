class Staff < ActiveRecord::Base
    belongs_to :affiliation
    has_many :construction_daily_reports
end
