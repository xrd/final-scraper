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
      end
    end
  end

  def process_title( row )
    row.strip.gsub( /"/, '' )
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
    processed_title = title.downcase.gsub( '"', '' ).gsub( /\s+/, '-').gsub( /\//, '-' ).gsub( ':', '-' ).gsub( ',', '' )
    "#{date}-#{processed_title}"
  end

  def render( processed )
    processed['layout'] = 'post'
    rendered = <<"TEMPLATE"
---
#{processed.to_yaml}
---

TEMPLATE
    rendered
  end

  def write( rendered, processed )
    Dir.mkdir( "_posts" ) unless File.exists?( "_posts" )
    filename = get_filename( processed['title'], processed['creation_date'] )
    File.open( "_posts/#{filename}.md", "w+" ) do |f|
      f.write rendered
    end
  end

  def process_creation_date( date )
    date.split( /last updated on:/ )[1]
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
