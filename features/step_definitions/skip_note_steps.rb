#!/usr/bin/env ruby
# vim:set fileencoding=utf-8 filetype=ruby
# $KCODE = 'u'

require 'rubygems'
#require File.expand_path("..", File.dirname(__FILE__))

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

