class RestaurantParser
  extend ActiveSupport::Memoizable

  def initialize(item, base)
    @item, @base = item, base
    @fields = {}
  end

  def name(item)
    item.at_css("h3 a").text
  end

  def link(item)
    item.at_css("h3 a")['href']
  end

  def twitter_link(item)
    item.at_css("a.listing_summary_icon_twitter")["href"]
  end

  def facebook_link(item)
    item.at_css("a.listing_summary_icon_facebook")["href"]
  end

  def map_link(item)
    item.at_css("ul.listing_summary_share_actions li:nth-child(1) a")["href"]
  end

  def new_review_link(item)
    item.at_css("ul.listing_summary_share_actions li:nth-child(2) a")["href"]
  end

  def email_link(item)
    item.at_css("ul.listing_summary_share_actions li:nth-child(3) a")["href"]
  end

  def zip(item)
    item.at_css("p.listing_summary_body_content_address span.zip").text
  end

  def address(item)
    address = item.at_css("p.listing_summary_body_content_address")
    address.at_css("span.zip").remove
    address.text.split(/\s+/).reject(&:empty?).join(" ")
  end

  def image_link(item)
    item.at_css("img.listing_summary_image")['src']
  end

  def first_review_link(item)
    item.at_css("div.listing_summary_body_content_review div.listing_summary_first_review a")["href"]
  end

  memoize :first_review_link

  def reviewer_location(item)
    unless first_review_link(item)
      item.at_css("div.listing_summary_body_content_review span.reviewer_location a").text
    end
  end

  def reviewer_location_link(item)
    unless first_review_link(item)
      item.at_css("div.listing_summary_body_content_review span.reviewer_location a")["href"]
    end
  end

  def reviewer_name(item)
    unless first_review_link(item)
      review = item.at_css("div.listing_summary_body_content_review")
      review.at_css("span.reviewer_location").remove
      review.at_css("span.reviewer_name").text
    end
  end

  def review_text(item)
    unless first_review_link(item)
      review = item.at_css("div.listing_summary_body_content_review")
      review.at_css("span.reviewer_location").remove
      review.at_css("span.reviewer_name").remove
      review.text.split(/\s+/).reject(&:empty?).join(" ").chomp(' -')
    end
  end

  def rating(item)
    item.css('img[src$="star_gold.png"]').count
  end

  def absolutize_links(fields)
    fields.keys.select { |k| k =~ /link/ }.map! { |k| fields[k] = base + fields[k] if fields[k].start_with?('/') }
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


