require 'mechanize'

class Scraper

  attr_accessor :root
  attr_accessor :agent

  def initialize
    @root = "http://web.archive.org/web/20030820233527/http://bytravelers.com/journal/entry/"
    @agent = Mechanize.new 
  end

  def run
    100.times do |i|
      begin
        url = "#{@root}#{i}"
        @agent.get( url ) do |page|
          puts "#{i} #{page.title}"
        end
      end
    end
  end

end
