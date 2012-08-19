class RestaurantsCollector
  attr_reader :restaurants
  def initialize(city)
    @base = "http://www.restaurants.com"
    @url = "/listing/search/empty/where/#{CGI.escape city}/screen/"
    doc = Nokogiri::HTML(open(@base+@url+'1'))
    @pages = doc.at_css("div.paging p.complementaryInfo strong:last").text.to_i
    @queue = Queue.new
    @restaurants = []
  end

  def collect
    (1..@pages).each { |page| @queue << page }
    threads = []
    25.times do
      threads << Thread.new do
        until @queue.empty? do
          page = @queue.pop(true) rescue nil
          Thread::exit() if page.nil?
          puts "Parsing page #{page}..."
          doc = Nokogiri::HTML(open(@base+@url+page.to_s))
          doc.css("div.listing_summary").each do |item|
            parser = RestaurantParser.new(item, @base)
            parser.parse!
            @restaurants << parser.fields
          end
        end
      end
    end
    threads.each(&:join)
  end

  def update!
    collect if @restaurants.empty?
    Restaurant.delete_all
    Restaurant.create @restaurants
  end

end
