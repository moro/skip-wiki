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
      :published_at => 1.days.ago,
      :format_type => "html",
  }.freeze,
  :label => {
      :display_name => "Ruby",
      :color => "#ff0000",
  }.freeze
}

def name_options(key)
  {:name => key.to_s, :display_name => key.to_s.humanize }
end

def prepare_default_category
  Category.transaction do
    Category.delete_all
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

def disable_sso
  FixedOp.sso_openid_provider_url = nil
end

Before do
  prepare_default_category
  disable_sso
end

Given(/^ノート"(.*)"が作成済みである/) do |note_name|
  builder = NoteBuilder.new(@user, valid_attributes[:note].merge(name_options(note_name)))
  builder.note.save!
  builder.front_page.save!
  @note = builder.note
end

Given( /^そのノートにはページ"(.*)"が作成済みである$/)  do |page_name|
  attrs = valid_attributes[:page].merge(name_options(page_name))
  attrs[:content] = "Content for the page `#{page_name}'"
  @page = @note.pages.add(attrs, @user)
  @page.save!
end

Given(/^そのノートにはラベル"(.*?)"が作成済みである$/)  do |label|
  @label = @note.label_indices.create!(valid_attributes[:label].merge(:display_name => label))
end

Given(/^そのページはラベル"(.*?)"と関連付けられている$/) do |label|
  label = @note.label_indices.find_by_display_name(label)
  @page.label_index_id = label.id
  @page.save!
end

Given( /^そのページの更新日時を"(\d+)"分進める$/ ) do |min|
  t = Integer(min).minutes.since(@page.updated_at)
  Page.update_all("updated_at = '#{t.to_s(:db)}'", ["id = ?", @page.id])
end

Given( /^ノート"(.*)"の情報を表示している$/) do |note|
  visit note_path(note)
end

Given( /^ノート"(.*)"のページ"(.*)"を表示している$/) do |note, page|
  visit note_page_path(note, page)
end

Given( /^ノート"(.*)"のページ"(.*)"を表示すると"(.*)"エラーが発生すること$/) do |note, page, e|
  begin
    visit note_page_path(note, page)
    flunk("No error raised.")
  rescue StandardError => ex
    ex.should be_kind_of(e.constantize)
  end
end

Given(/^"(.+)"を"(\d+)"日前に設定する/) do |label, n|
  date = Integer(n).days.ago(Time.now)
  select_datetime(date, :from => label, :use_month_numbers=>true)
end

Given(/^"(.+)"を"(\d+)"日後に設定する/) do |label, n|
  date = Integer(n).days.since(Time.now)
  select_datetime(date, :from => label, :use_month_numbers=>true)
end

Given(/固定OPの設定をする/) do
  pending("このシナリオは手動で実行する")
end

Given(/ナビゲーションメニューから"(\w+)"を選択する/) do |label|
  visit select(label)
end

