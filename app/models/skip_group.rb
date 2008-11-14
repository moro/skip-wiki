require 'open-uri'

class SkipGroup < ActiveRecord::Base
  validates_presence_of :name, :gid
  validates_length_of :name, :in=>2..40, :if=>lambda{|r| r.name }
  validates_length_of :gid,  :maximum=>16, :if=>lambda{|r| r.gid }

  cattr_reader :site

  has_one  :group, :as => "backend"

  class << self
    @@site = URI("http://localhost:10080").normalize
    def site=(uri)
      @@site = (uri == URI) ? uri : URI(uri).normalize
    end

    def fetch(skip_username, password="To Be Detarmined")
      uri = build_uri_from_username(skip_username)
      xml = OpenURI.open_uri(uri).read
      Hash.from_xml(xml)["groups"]
    end

    def fetch_and_store(skip_username, password = "To Be Detarmined")
      fetch(skip_username, password).map do |h|
        returning( find_by_gid(h["gid"]) || new ) do |group|
          group.attributes = h
          group.save!
        end
      end
    end

    private
    def build_uri_from_username(name)
      URI.join(site.to_s, "user/#{name}/groups.xml")
    end
  end
end

