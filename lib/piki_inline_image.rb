class PikiInlineImage
  def accept?(src)
    return false unless path = src.scan(/image\('(.*)'\)/).flatten.first
    URI(path).path =~ regexp rescue false
  end

  def inline_plugin(src)
    return "" unless accept?(src) # guard
    
    u = URI(path = src.scan(/image\('(.*)'\)/).flatten.first)
    "<img class='piki' src='#{u.path}?#{u.query}' />"
  end

  def block_plugin(src)
    "<p class='piki image'>#{inline_plugin(src)}</p>"
  end

  private
  def regexp
    %r{\A/(?:[a-z\-]+/)?notes/[A-Za-z0-9_\-]+/attachments/\d+}
  end
end
