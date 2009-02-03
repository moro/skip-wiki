class FulltextSearchCache
  module MetaWriter
    def write_meta(mediator)
      File.open(mediator.meta_path(self), "wb"){|f| f.write to_meta.to_yaml }
    end
  end
end
