class CustomerMaster < ActiveRecord::Base
    paginates_per 200  # 1ページあたり項目表示

    #締め日区分
    def self.closing_division 
      [["指定日(通常)", 0], ["月末", 1]]
    end
    #支払日区分
    def self.due_division 
      [["当月", 0], ["翌月", 1], ["翌々月", 2]]
    end

    has_many :construction_datum  # <== 関係を追記
    
    validates :closing_date, presence: true, numericality: :integer
    validates :due_date, presence: true, numericality: :integer
	
	#現状、利用価値が少ないのでチェックしないものとする・・・
	#add 171002
	#validates :search_character, presence: true, length: { maximum: 1 } , :format => {:with => /^[ぁ-んー－]+$/, :multiline => true, :message =>'はひらがなで入力して下さい。'} 
	
	#見積書・請求書等での敬称として使用
	def self.honorific 
      [["様", 0], ["御中", 1]] 
    end
	
	def self.syllabary 
      #[*('あ'..'ん')]   #これだと余計な文字が入るのでNG
      ['あ','い','う','え','お','か','き','く','け','こ','さ','し','す','せ','そ','た','ち','つ','て','と',
       'な','に','ぬ','ね','の','は','ひ','ふ','へ','ほ','ま','み','む','め','も','や','ゆ','よ',
       'ら','り','る','れ','ろ','わ','を','ん']
    end
end
