require 'mechanize'

class Scraper

  def initialize
    @root = "http://web.archive.org/web/20030820233527/http://bytravelers.com/journal/entry/"
    @mechanize = Mechanize.new 
  end

  def run
    100.times do |i|
      begin
        url = "#{@root}#{i}"
        @mechanize.get( url ) do |page|
          puts "#{i} #{page.title}"
        end
      end
    end
  end

end
