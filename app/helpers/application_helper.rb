module ApplicationHelper
	def render_title
	  return @title if defined?(@title)
	  "maruDiary"
	end
end
