class EmptyLabel
  include GetText
  attr_reader :note
  def initialize(note)
    @note = note
  end

  def pages
    PageProxy.new(note)
  end

  def display_name
    _("No Labels")
  end

  class PageProxy
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }
    def initialize(note)
      @note = note
    end
    def next(pivot)
      return nil if pivot < 0
      target.nth(pivot + 1).first
    end

    def previous(pivot)
      return nil unless pivot > 1
      target.nth(pivot - 1).first
    end
    private
    def target
      @note.pages.no_labels
    end

    def method_missing(method, *args)
      if block_given?
        target.send(method, *args)  { |*block_args| yield(*block_args) }
      else
        target.send(method, *args)
      end
    end
  end
end
