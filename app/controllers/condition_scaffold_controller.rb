class ConditionScaffoldController < ApplicationController

  def file_list
  end

  def column_list
    @model_klass = Module.const_get(params[:name])
  end

  #-------------------------------------------------------------
  # ConditionScaffold を使用して、アプリケーションの生成を行います。
  #-------------------------------------------------------------
  def generate
    @model_klass = Module.const_get(params[:moderu][:klass])
    hikisu = ""
    for column in @model_klass.columns
      if params[:retrieval][:"#{column.name}"] == "1"
        hikisu += column.name + " "
      end
    end
    
    generation_output = `ruby script/generate condition_scaffold --skip #{params[:moderu][:klass]} #{params[:moderu][:klass]}s #{hikisu}`
    print generation_output
    params[:generation_output] = generation_output
    
    render :action=>'result'
  end
  
  def result
    
  end
  
end
