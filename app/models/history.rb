class History < ActiveRecord::Base
  belongs_to :page
  belongs_to :content
  belongs_to :user

  after_save :update_page_updated_at

  validates_associated :content

  def self.find_all_by_head_content(keyword, only_head = true)
    find_by_sql([<<-SQL, {:keyword => "%#{keyword}%"}])
SELECT
  hs.*
FROM
  histories AS hs
  INNER JOIN contents AS c
    ON hs.content_id = c.id
  INNER JOIN (
      SELECT
        h.page_id AS page_id,
        MAX(h.revision) AS revision
      FROM histories AS h
      GROUP BY h.page_id
  ) AS heads
    ON hs.page_id = heads.page_id
    AND hs.revision = heads.revision
WHERE
  c.data LIKE :keyword
SQL
  end

  private
  def update_page_updated_at
    page.update_attributes(:updated_at => Time.now.utc)
  end
end

