class FulltextSearchCache
  module MetaWriter
    def self.included(base)
      base.send(:include, ActionController::UrlWriter)
    end

    def write_meta(mediator)
      File.open(mediator.meta_path(self), "wb"){|f| f.write to_meta.to_yaml }
    end

    def icon_url(icon_filename)
      root_url + "images/icons/" + icon_filename
    end
  end
end
