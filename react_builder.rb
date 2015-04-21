#!/usr/bin/env ruby
require 'thor'

class React < Thor
  desc "creates js file of [COMPONENT]", "shows react component"
  method_options :alias => :g
  def generate(component="", elem="")
    component = component.split("_").map(&:capitalize).join
    file = File.new("#{component.downcase}.js", 'w+')
    file <<
      "var #{component} = React.createClass({\n"\
      "  render: function() {\n"\
      "    return (\n"\
      "      <#{elem}></#{elem}>\n"\
      "    )\n"\
      "  }\n"\
      "})\n"\
      "\n"\
      "module.exports = #{component};"
    file.close
  end
end


React.start
