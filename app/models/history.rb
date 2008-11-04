class History < ActiveRecord::Base
  belongs_to :versionable, :polymorphic=>true
  belongs_to :content
  belongs_to :user

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
        h.versionable_id AS versionable_id,
        MAX(h.revision) AS revision
      FROM histories AS h
      GROUP BY h.versionable_id, h.versionable_type
  ) AS heads
    ON hs.versionable_id = heads.versionable_id
    AND hs.revision = heads.revision
WHERE
  c.data LIKE :keyword
SQL
  end

end
