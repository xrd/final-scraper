require 'mechanize'
require 'vcr'
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
    row.strip
  end

  def run
    scrape()
    @pages.each do |page|
      rows = ( page / "table[valign=top] tr" )
      puts process_title( rows[0].text() )
    end
  end

end
