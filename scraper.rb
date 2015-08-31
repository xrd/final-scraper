require 'mechanize'

class Scraper

  attr_accessor :root
  attr_accessor :mechanize
  def initialize
    @root = "http://web.archive.org/web/20030820233527/http://bytravelers.com/journal/entry/"
    @mechanize = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
  end

  def run
    100.times do |i|
      begin
        url = "#{@root}#{i}"
        @mechanize.get( url ) do |page|
          rows = ( page / "table[valign=top] tr font" )
          puts rows[0].text if rows[0]
        end
      end
    end
  end

end
