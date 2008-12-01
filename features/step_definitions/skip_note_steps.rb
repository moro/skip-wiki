require 'rubygems'

valid_attributes = {
  :note => {
    :name => "value for name",
    :display_name => "value for display_name",
    :description => "value for note description",
    :publicity => 0,
    :category_id => "1",
    :group_backend_type => "BuiltinGroup",
    :group_backend_id => ""
  }.freeze,
  :page => {
      :name => "value for name",
      :display_name => "value for display_name",
      :format_type => "html",
  }.freeze
}

def name_options(key)
  {:name => key.to_s, :display_name => key.to_s.humanize }
end

Given "デフォルトのカテゴリが登録されている" do
  Category.transaction do
    [
      %w[OFFICE オフィス  社内の公式資料の置き場所として利用する場合に選択してください。],
      %w[BIZ    ビジネス  プロジェクト内など、業務で利用する場合に選択してください。],
      %w[LIFE   ライフ    業務に直結しない会社内の活動で利用する場合に選択してください。],
      %w[OFF    オフ      趣味などざっくばらんな話題で利用する場合に選択してください。],
    ].each_with_index do |(name, display_name, desc), idx|
      Category.create(:name=>name, :display_name=>display_name, :description => desc) do |c|
        c.lang = "ja"
        c.id = idx + 1
      end
    end
  end
end


Given(/^ノート"(.*)"が作成済みである/) do |note_name|
  @note = @account.user.build_note(valid_attributes[:note].merge(name_options(note_name)))
  @note.save!
end

Given( /^そのノートにはページ"(.*)"が作成済みである$/)  do |page_name|
  @page = @note.pages.create!(valid_attributes[:page].merge(name_options(page_name)))
end

Given( /^そのページの更新日時を"(\d+)"分進める$/ ) do |min|
  t = Integer(min).minutes.since(@page.updated_at)
  Page.update_all("updated_at = '#{t.to_s(:db)}'", ["id = ?", @page.id])
end

Given( /^ノート"(.*)"のページ"(.*)"を表示している$/) do |note, page|
  visit note_page_path(note, page)
end

