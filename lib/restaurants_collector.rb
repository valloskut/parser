class RestaurantsCollector
  extend ActiveSupport::Memoizable

  def initialize(city)
    @base = "http://www.restaurants.com"
    @url = "/listing/search/empty/where/#{CGI.escape city}/screen/"
    @pages = 249 # TODO get number of pages from the page
    @queue = Queue.new
    @restaurants = []
    @threads = []
  end

  (1..249).each { |page| queue << page }
  25.times do
    threads << Thread.new do
      until queue.empty? do
        page = queue.pop(true) rescue nil
        Thread::exit() if page.nil?
        puts "Parsing page #{page}..."
        doc = Nokogiri::HTML(open(base+url+page.to_s))
        doc.css("div.listing_summary").each do |item|
          fields = {}
          restaurants << fields
        end
      end
    end
  end
  threads.each(&:join)
  Restaurant.delete_all
  Restaurant.create restaurants
end

