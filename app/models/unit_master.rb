class UnitMaster < ActiveRecord::Base
  
   #バリデーション
   validates :unit_name, presence: true, uniqueness: true
  
   #即時に取り出せるよう配列化
   #これだとIDが削除された場合にNG...使わないこと(220518)
   def self.all_list
      UnitMaster.all.pluck("unit_name, id")
   end
   
   #単位を返す(IDと連動させる)
   def self.all_list_by_id(unit_master_id)
     unit_master = UnitMaster.where(id: unit_master_id).first
     if unit_master.present?
       return unit_master.unit_name
     else
       return ""
     end
   end
   
end
