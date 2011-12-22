# coding: utf-8
module ApplicationHelper

  def check_error str
    if str.blank?
      return ""
    end
    return "error"
  end

end
