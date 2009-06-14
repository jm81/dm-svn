# This filter just replaces single newlines with "<br />" tags.
class Linebreaker

  def initialize(input)
    @input = input
  end
  
  def to_html
    @input.
      gsub(/(\S)\n(\S)/, "\\1<br />\n\\2").
      gsub(/(\S)\r\n(\S)/, "\\1<br />\n\\2")
  end
  
end
