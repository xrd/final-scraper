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

end
