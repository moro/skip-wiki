class Category < ActiveRecord::Base
  named_scope :lang, proc{|lang|
    {:conditions=>["#{table_name}.lang = ?", lang]}
  }
end
