class RestaurantParser
  attr_reader :fields

  def initialize(item, base)
    @item, @base = item, base
    @name = @item.at_css("h3 a")
    @actions = @item.at_css("ul.listing_summary_share_actions")
    @address = @item.at_css("p.listing_summary_body_content_address")
    @review = @item.at_css("div.listing_summary_body_content_review")
    @first_review = @review.at_css("div.listing_summary_first_review a")
    @reviewer_location = @review.at_css("span.reviewer_location").remove.at_css("a") unless @first_review
    @fields = {}
  end

  def name
    @fields[:name] = @name.text
  end

  def link
    @fields[:link] = @name['href']
  end

  def twitter_link
    @fields[:twitter_link] = @item.at_css("a.listing_summary_icon_twitter")["href"]
  end

  def facebook_link
    @fields[:facebook_link] = @item.at_css("a.listing_summary_icon_facebook")["href"]
  end

  def map_link
    @fields[:map_link] = @actions.at_css("li:nth-child(1) a")["href"]
  end

  def new_review_link
    @fields[:new_review_link] = @actions.at_css("li:nth-child(2) a")["href"]
  end

  def email_link
    @fields[:email_link] = @actions.at_css("li:nth-child(3) a")["href"]
  end

  def zip
    @fields[:zip] = @address.at_css("span.zip").remove.text
  end

  def address
    zip unless @fields[:zip]
    @fields[:address] = @address.text.split(/\s+/).reject(&:empty?).join(" ")
  end

  def image_link
    @fields[:image_link] = @item.at_css("img.listing_summary_image")['src']
  end

  def first_review_link
    @fields[:first_review_link] = @first_review["href"] if @first_review
  end

  def reviewer_location
    @fields[:reviewer_location] = @reviewer_location.text unless @first_review
  end

  def reviewer_location_link
    @fields[:reviewer_location_link] = @reviewer_location["href"] unless @first_review
  end

  def reviewer_name
    @fields[:reviewer_name] = @review.at_css("span.reviewer_name").remove.text unless @first_review
  end

  def review_text
    reviewer_name unless fields[:reviewer_name]
    @fields[:review_text] = @review.text.split(/\s+/).reject(&:empty?).join(" ").chomp(' -')
  end

  def rating
    @fields[:rating] = @item.css('img[src$="star_gold.png"]').count
  end

  def absolutize_links
    @fields.keys.select { |k| k =~ /link/ }.map! { |k| fields[k] = @base + fields[k] if fields[k].start_with?('/') }
  end

  def parse!
    name
    link
    twitter_link
    facebook_link
    map_link
    new_review_link
    email_link
    zip
    address
    image_link
    if @first_review
      first_review_link
    else
      reviewer_location
      reviewer_location_link
      reviewer_name
    end
    review_text
    rating
    absolutize_links
  end
end
