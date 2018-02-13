class Task < ActiveRecord::Base

  belongs_to :construction_datum
  
  #ガント直接編集との切り分け用
  attr_accessor :form_edit_flag
  
  #フォームからの内容マスター保管用
  attr_accessor :master_save_flag
  
  #フォームからのマスター参照用
  attr_accessor :construction_datum_id_refer
  attr_accessor :task_content_name_refer
  
  attr_accessor :master_insert_flag
  
  #優先度
  def self.priority_name 
    [["常", 1 ], ["高", 2], ["低", 3]]
  end
	
  #ソート用
  def self.updateOrder(taskId, target)
        nextTask = false
        targetId = target
 
        if(target.start_with?('next:'))
            targetId = target['next:'.length, target.length]
            nextTask = true;
        end
 
        if(targetId == 'null')
            return
        end
 
        targetTask = self.find(targetId)
 
        targetOrder = targetTask.sortorder
 
        if(nextTask)
            targetOrder += 1
        end
 
        self.where("sortorder >= ?", targetOrder).
            update_all('sortorder = sortorder + 1')
 
        task = self.find(taskId)
        task.sortorder = targetOrder
        task.save
    end
end
