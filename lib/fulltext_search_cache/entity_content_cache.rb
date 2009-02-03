require 'erb'

class FulltextSearchCache
  module EntityContentCache
    def write_cache(mediator)
      File.open(mediator.cache_path(self), "wb"){|f| f.write to_cache }
    end

    def to_cache
      ERB.new(<<-HTML).result(binding)
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>#{ERB::Util.h(title)}</title>
  </head>
  <body>
    #{ERB::Util.h(body)}
  </body>
</html>
HTML
    end
  end
end

