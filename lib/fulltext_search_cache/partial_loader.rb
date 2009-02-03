class FulltextSearchCache
  class PartialLoader
    def initialize(model_or_scope, limit, finder_options = {})
      @model_or_scope = model_or_scope
      @limit = limit
      @finder_options = finder_options
    end

    def each
      0.step(@model_or_scope.count, @limit) do |offset|
        @model_or_scope.find(:all, :limit => @limit, :offset => offset).each do |model|
          yield model
        end
      end
    end
  end
end
