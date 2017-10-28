module ApplicationHelper

  #index.htmlへチェックボックス表示用
  def check_if_true(item)
    if(item == 'true' or item == true or item == 1 or item == '1')
      return true
    else
      return false
    end
  end
  
  #add170710
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    #new_object = f.object.class.reflect_on_association(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields btn btn-cyan700_rsd ", data: {id: id, fields: fields.gsub("\n", "")})
  end
 
 
  #def my_color_for(condition)
  #   if condition == 1 then
  #    'red !important'
  #  else
  #    'blue !important'
  #  end
  #end

 # 選択中のサイドメニューのクラスを返す
  def sidebar_activate(sidebar_link_url)
    current_url = request.headers['PATH_INFO']
    if current_url.match(sidebar_link_url)
      ' class="active"'
    else
      ''
    end
  end

  # サイドメニューの項目を出力する
  def sidebar_list_items
    items = [
      {:text => 'Users',      :path => admin_users_path},
      {:text => 'Contacts',   :path => admin_contacts_path}
    ]

    html = ''
    items.each do |item|
      text = item[:text]
      path = item[:path]
      html = html + %Q(<li#{sidebar_activate(path)}><a href="#{path}">#{text}</a></li>)
    end

    raw(html)
  end
 
 

end
