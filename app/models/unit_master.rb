class UnitMaster < ActiveRecord::Base
  
   #バリデーション
   validates :unit_name, presence: true, uniqueness: true
  
   #即時に取り出せるよう配列化
   def self.all_list
      UnitMaster.all.pluck("unit_name, id")
   end
  
end
