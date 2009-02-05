module PagesModule
  module PagesUtil
    private
    def safe_split(str, separator = /\s*,\s*/)
      str.nil? ? [] : str.to_s.split(separator)
    end

    def page_order_white_list(order, default = "#{Page.quoted_table_name}.updated_at DESC")
      {:order =>
        case order
        when "updated_at_DESC" then "#{Page.quoted_table_name}.updated_at DESC"
        when "updated_at_ASC"  then "#{Page.quoted_table_name}.updated_at ASC"
        else default
        end }
    end
  end
end
