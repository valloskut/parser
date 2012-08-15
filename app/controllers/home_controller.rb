class HomeController < ApplicationController
  def index
    base = 'http://www.restaurants.com'
    url = '/listing/search/empty/where/Charlotte+NC/screen/1'
    doc = Nokogiri::HTML(open(base+url))
    @title = doc.at_css("title").text
    @restaurants = []
    doc.css("div.listing_summary").each do |item|
      fields = {}
      #name
      name = item.at_css("h3 a")
      fields[:name] = name.text
      fields[:link] = name['href']
      #share links
      fields[:twitter_link] = item.at_css("a.listing_summary_icon_twitter")["href"]
      fields[:facebook_link] = item.at_css("a.listing_summary_icon_facebook")["href"]
      #action links
      actions = item.at_css("ul.listing_summary_share_actions")
      fields[:map_link] = actions.at_css("li:nth-child(1) a")["href"]
      fields[:new_review_link] = actions.at_css("li:nth-child(2) a")["href"]
      fields[:email_link] = actions.at_css("li:nth-child(3) a")["href"]
      #address
      address = item.at_css("p.listing_summary_body_content_address")
      fields[:zip] = address.at_css("span.zip").remove.text
      fields[:address] = address.text.split(/\s+/).reject(&:empty?).join(" ")
      #image
      fields[:image_link] = item.at_css("img.listing_summary_image")['src']
      #review
      review = item.at_css("div.listing_summary_body_content_review")
      first_review = review.at_css("div.listing_summary_first_review a")
      if first_review
        fields[:first_review_link] = first_review["href"]
      else
        reviewer_location = review.at_css("span.reviewer_location").remove.at_css("a")
        fields[:reviewer_location] = reviewer_location.text
        fields[:reviewer_location_link] = reviewer_location["href"]
        fields[:reviewer_name] = review.at_css("span.reviewer_name").remove.text
      end
      fields[:review_text] = review.text.strip.chomp(' -')
      #rating
      fields[:rating] = item.css('img[src$="star_gold.png"]').count
      #making links absolute
      fields.keys.select { |k| k =~ /link/ }.map! { |k| fields[k] = base + fields[k] if fields[k].start_with?('/') }
      @restaurants << fields
    end
  end
end
