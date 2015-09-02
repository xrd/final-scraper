require './scraper'

describe "#run" do
  before :each  do
    @scraper = Scraper.new
  end

  describe "#process_titles" do
    it "should correct titles with double quotes" do
      expect( @scraper.process_title( ' something " with a double quote' ) ).to_not match( /"/ )
    end
    
    it "should strip whitespace from titles" do
      expect( @scraper.process_title( '\n\n something between newlines \n\n' ) ).to_not match( /^\n\n/ )
    end
  end

end
