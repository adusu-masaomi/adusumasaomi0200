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
 
  def full_title(page_title)
    base_title = "Adusu" # 自分のアプリ名を設定する
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
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
 
 
  #add180929
  def set_cookies(cookie_name, value)
    cookies[cookie_name.to_sym] = value
  end
  def get_cookies(cookie_name)
    return cookies[cookie_name.to_sym]
  end
  
  #検索結果保存用のクッキーを初期化する
  def cookie_clear(cookies, cookie_name)
    #仕入画面検索結果を削除
    if cookie_name != "recent_search_history_purchase"
      
      #工事・得意先は残したいので、他を消すようにする
      new_array = eval(cookies[:recent_search_history_purchase])
      
      #
      new_array.each{|item|
        if item[0] != "with_construction" &&
           item[0] != "with_customer" 
          new_array.delete(item[0])
        end
      }
      
      #new_array.delete("with_material_code")
      #
      
      #１時間後に消すクッキーとして再セット
      search_history = {
        value: new_array,
        expires: 1.hours.from_now
      }
      
      #cookies.delete(:recent_search_history_purchase)
      set_cookies("recent_search_history_purchase", search_history)
      
    end
    
    #return cookies
  end
  
  #外注のIDから社員ID取得
  #後でマスターから拾えるようにする
  def getSupplierToStaff(supplier_id)
    
    case supplier_id
    when 37  #村山電気
      staff_id = 3
    when 31  #須戸
      staff_id = 6
    when 39  #小柳
      staff_id = 5
    else
      staff_id = 0
    end
    
    return staff_id
  end
  #社員IDから仕入先ID取得
  #後でマスターから拾えるようにする
  def getStaffToSupplier(staff_id)
    
    case staff_id
    when 3  #村山電気
      supplier_id = 37
    when 6  #須戸
      supplier_id = 31
    when 5  #小柳
      supplier_id = 39
    else
      supplier_id = nil
    end
    
    return supplier_id
  end
  
end
