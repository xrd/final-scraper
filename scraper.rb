require 'mechanize'
require 'vcr'
require 'yaml'

VCR.configure do |c|
  c.cassette_library_dir = 'cached'
  c.hook_into :webmock
end

class Scraper

  attr_accessor :root
  attr_accessor :agent
  attr_accessor :pages

  def initialize
    @root = "http://web.archive.org/web/20030820233527/http://bytravelers.com/journal/entry/"
    @agent = Mechanize.new 
    @pages = []
  end

  def scrape
    100.times do |i|
      begin
        VCR.use_cassette("bt_#{i}") do
          url = "#{@root}#{i}"
          @agent.get( url ) do |page|
            if page.title.eql? "Read Journal Entries"
              pages << page
            end
          end
        end
      rescue Exception => e
        STDERR.puts "Unable to scrape this file (#{i})"
      end
    end
  end

  def process_title( row )
    row.strip.gsub( /"/, '' ) # if row
  end

  def process_body( paragraphs )
    body = ""
    paragraphs.each do |p|
      text = p.text().strip.gsub( /\*\s*/, '' )
      body += text + "\n\n"
    end
    body
  end

  def get_filename( title, date )
    processed_date = DateTime.parse( date )
    processed_title = title.downcase.gsub( /[^a-z]+/, '-' )
    "#{processed_date.strftime('%Y-%m-%d')}-#{processed_title}.md"
  end

  def render( processed )
    processed['layout'] = 'post'
    rendered = "#{processed.to_yaml}---\n\n"
    rendered
  end

  def write( rendered, processed )
    Dir.mkdir( "_posts" ) unless File.exists?( "_posts" )
    filename = get_filename( processed['title'], processed['creation_date'] )
    File.open( "_posts/#{filename}", "w+" ) do |f|
      f.write rendered
    end
  end

  def process_creation_date( date )
    tuple = date.split( /last updated on:/ )
    rv = tuple[1].strip if tuple and tuple.length > 1
    rv
  end

  def run
    scrape()
    @pages.each do |page|
      rows = ( page / "table[valign=top] tr" )
      processed = {}
      processed['title'] = process_title( rows[0].text() )
      processed['creation_date'] = process_creation_date( rows[3].text() )
      rendered = render( processed )
      write( rendered, processed )
    end
  end

end
