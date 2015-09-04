require './scraper'

describe "#run" do
  before :each  do
    @scraper = Scraper.new
  end

  describe "#process_titles" do
    it "should correct titles with double quotes" do
      str = ' something " with a double quote' 
      expect( @scraper.process_title( str ) ).to_not match( /"/ )
    end
    
    it "should strip whitespace from titles" do
      str = '\n\n something between newlines \n\n' 
      expect( @scraper.process_title( str ) ).to_not match( /^\n\n/ )
    end
  end

  describe "#get_filename" do
    it "should take 'Cuba - the good and bad' on January 12th, 2001 and get a proper filename" do
      input = 'Cuba - the good and bad'
      date = "January 12th, 2001"
      output = "2001-01-12-cuba-the-good-and-bad.md"
      expect( @scraper.get_filename( input, date ) ).to eq( output )
    end

    it "should `Mexico/Belize/Guatemala` and get a proper filename" do
      input = "Mexico/Belize/Guatemala"
      date = "2001-01-12" 
      output = "2001-01-12-mexico-belize-guatemala.md"
      expect( @scraper.get_filename( input, date ) ).to eq( output )
    end
  end
end
