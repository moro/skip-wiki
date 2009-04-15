class ChangePagePublicityToSimpleFlag < ActiveRecord::Migration
  def self.up
    add_column :pages, :published, :boolean, :null => false, :default => true

    pivot = Time.now
    ActiveRecord::Base.transaction do
      Page.all.each{|p| p.update_attribute(:published, (pivot >= p.published_at)) }
    end

    remove_column :pages, :published_at
  end

  def self.down
    past, future = 1.days.ago, 1.days.since

    add_column :pages, :published_at, :datetime
    ActiveRecord::Base.transaction do
      Page.all.each do |p|
        p.update_attribute(:published_at, p.published ? past : future)
      end
    end
    change_column :pages, :published_at, :datetime, :null => false
    remove_column :pages, :published
  end
end
