#!/usr/bin/env ruby
require 'thor'
module ComponentBuilder
  COMPONENTS = {
    arrays: { name: "mixins", obj: "[]" },
    statics: { name: "statics", obj: "{}" },
    string: { name: "displayName" },
    functions: [
      { name: "getInitialState", args: "", body: "\t\treturn {};" },
      { name: "getDefaultProps", args: "", body: "\t\treturn {};" },
      { name: "componentWillMount", args: "" },
      { name: "componentDidMount", args: "" },
      { name: "componentWillReceiveProps", args: "nextProp" },
      { name: "shouldComponentUpdate", args: "nextProp, nextState" },
      { name: "componentWillUpdate", args: "prevProps, prevState" },
      { name: "componentDidUpdate", args: "prevProps, prevState" },
      { name: "componentWillUnmount", args: "" },
      { name: "render", args: "", body: "\t\treturn;" }
    ]
  }

  def write_other(name: name, obj: obj)
    "\t#{name}: #{obj},\n"
  end

  def write_functions(functions)
    functions.map do |name: name, args: args, body: body|
      "\t#{name}: function(#{args}) {\n#{body}\n\t}"
    end.join(",\n\n")
  end

  def compose_file(component, elem, body="var ")
    body = "\/\/ require #{component.downcase}\n\n" << body 
    body << "#{component} = React.createClass({\n"

    COMPONENTS.each do |component_type, value|
      if component_type == :functions
        body << write_functions(value)
      elsif component_type == :string
        body << "\t#{value[:name]}: '#{component}',\n"
      else
        body << write_other(value)
      end
    end

    return body << "\n})\n\nmodule.exports = #{component};"
  end
end

class React < Thor
  include ComponentBuilder

  desc "composes the main js file by adding `require`", 'require add'
  method_options :alias => "-b"
  def browserify
    Dir["./*.js"].each do |file|
      data = File.read(file)
    end
  end

  desc "create a React component with all the bells and whistles", "component bldr"
  method_options :alias => 'a'
  def all(component="", elem="")
    component = component.split("_").map(&:capitalize).join
    file = File.new("#{component.downcase}.js", "a+")
    file << compose_file(component, elem)
    file.close
  end

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
