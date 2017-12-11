class WorkingUnit < ActiveRecord::Base
  validates :working_unit_name, presence: true
  
  #工事種別をここで宣言
  #単位と直接関連がないが、共通化したい為
  def self.types 
    [["通常", 0], ["小計", 1], ["値引", 2], ["配管配線工事", 3], ["機器取付工事", 4], ["労務費", 5]] 
  end
  
end
