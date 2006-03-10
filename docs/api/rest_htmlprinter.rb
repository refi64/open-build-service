#!/usr/bin/ruby

require "rest"

class HtmlPrinter < Printer

  attr_accessor :output_dir

  def initialize
    super()
    @output_dir = "html"
    @xml_examples = Hash.new
    @xml_schemas = Hash.new
  end

  def do_prepare
    unless File.exists? @output_dir
      Dir.mkdir @output_dir
    end
    @index = File.new( @output_dir + "/index.html", "w" )
    @html = Builder::XmlMarkup.new( :target => @index, :indent => 2 )
  end

  def do_finish
    puts "Written #{@index.path}."
    
    @xml_examples.each do |f,b|
      if !File.exist?( f )
        STDERR.puts "XML Example '#{f}' is missing."
      else
        File.copy f, @output_dir
      end
    end
    @xml_schemas.each do |f,b|
      if !File.exist?( f )
        STDERR.puts "XML Schema '#{f}' is missing."
      else
        File.copy f, @output_dir
      end
    end
    
    @index.close
  end

  def print_section section
    if ( !section.root? )
      tag = "h#{section.level}"
      @html.tag!( tag, section )
    end
    section.print_children self
  end

  def print_request request
    @html.div( "class" => "request" ) do

      @html.p do
        @html.a( "name" => request.id ) do
          @html.b request.to_s
        end
      end

      if false
        host = request.host
        if ( host )
          @html.p "Host: " + host.name
        end
      end

      if request.parameters.size > 0
        @html.p "Arguments:"
        @html.ul do
          request.parameters.each do |p|
            @html.li p.to_s
          end
        end
      end
      request.print_children self

    end
  end

  def print_text text
    @html.p do |p|
      text.text.each do |t|
        p << t << "\n"
      end
    end
  end

  def print_parameter parameter
  end

  def print_host host
    @html.p "Host: " + host.name
  end

  def print_result result
    @html.p "Result: " + result.name
  end
  
  def print_body body
    @html.p "Body: " + body.name
  end

  def print_xmlresult result
    print_xml_links "Result", result.name, result.schema
  end

  def print_xmlbody body
    print_xml_links "Body", body.name, body.schema
  end

  def print_xml_links title, xmlname, schema
    example = xmlname + ".xml"
    if ( !schema || schema.empty? )
      schema = xmlname + ".xsd"
    end
    @xml_examples[ example ] = true
    @xml_schemas[ schema ] = true
    @html.p do |p|
      p << title
      p << ": "
      has_example = File.exist? example
      has_schema = File.exist? schema
      if has_example
        @html.a( "Example", "href" => example )
      end
      if has_schema
        p << " ";
        @html.a( "Schema", "href" => schema )
      end
      if( !has_example && !has_schema )
        p << xmlname
      end
    end
  end

  def print_contents contents
    @html.p do |p|
      p << create_contents_list( contents.root, 1 )
    end
  end

  def create_contents_list section, min_level
    result = ""
    section.children.each do |s|
      if ( s.is_a? Section )
        result += create_contents_list s, min_level      
      end
      if ( s.is_a? Request )
        result += "<li><a href=\"##{s.id}\">" + h( s.to_s ) + "</a></li>\n"
      end
    end
    endresult = ""
    if ( !result.empty? )
      if ( section.level > min_level )
        endresult = "<li>" + h( section.to_s ) + "</li>\n"
      end
      if ( section.level >= min_level )
        endresult += "<ul>\n" + result + "</ul>\n"
      else
        endresult = result
      end
    end
    endresult 
  end

  def print_version version
    @html.p "Version: " + version.to_s
  end

end
