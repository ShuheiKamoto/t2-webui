# coding: utf-8
module ApplicationHelper

  # 文字列が入っていればerrorを返す(入力フィールドのスタイルで使用する)
  def check_error str
    if str.blank?
      return ""
    end
    return "error"
  end

end
