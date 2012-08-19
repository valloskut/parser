#encoding: utf-8
require "spec_helper"

describe RestaurantParser do
  let(:base) { "http://www.restaurants.com" }
  let(:doc) { Nokogiri::HTML(open("spec/lib/Charlotte+NC.html")) }
  let(:items) { doc.css("div.listing_summary") }

  context "restaurant general information" do
    before(:each) do
      @rp = RestaurantParser.new(items[0], base)
    end
    it "should initialize with empty fields" do
      @rp.fields.should be_empty
      @rp.fields.should be_empty
    end
    it "should parse a name of the restaurant" do
      @rp.name
      @rp.fields.should include name: "Adam's Restaurant at Ballantyne"
    end
    it "should parse a link to the restaurant" do
      @rp.link
      @rp.fields.should include link: "http://www.restaurants.com/north-carolina/charlotte/adams-restaurant-at-ballantyne"
    end
    it "should parse a twitter link for the restaurant" do
      @rp.twitter_link
      @rp.fields.should include twitter_link: "http://twitter.com/?status=http://www.restaurants.com/north-carolina/charlotte/adams-restaurant-at-ballantyne"
    end
    it "should parse a facebook link for the restaurant" do
      @rp.facebook_link
      @rp.fields.should include facebook_link: "http://www.facebook.com/sharer.php?u=http://www.restaurants.com/north-carolina/charlotte/adams-restaurant-at-ballantyne"
    end
    it "should parse a map link for the restaurant" do
      @rp.map_link
      @rp.fields.should include map_link: "http://www.restaurants.com/north-carolina/charlotte/adams-restaurant-at-ballantyne#mapTab"
    end
    it "should parse a link to a new review for the restaurant" do
      @rp.new_review_link
      @rp.fields.should include new_review_link: "/listing/reviewformpopup.php?item_type=listing&item_id=265119&keepThis=true&TB_iframe=true&width=740&height=470"
    end
    it "should parse an email link for the restaurant" do
      @rp.email_link
      @rp.fields.should include email_link:"/listing/emailform.php?id=265119&receiver=friend&KeepThis=true&TB_iframe=true&width=600&height=455"
    end
    it "should parse a zip of the restaurant" do
      @rp.zip
      @rp.fields.should include zip: "28277"
    end
    it "should parse an address of the restaurant" do
      @rp.address
      @rp.fields.should include address: "13735 Conlan Circle Charlotte, North Carolina"
    end
    it "should parse a link to image for the restaurant" do
      @rp.image_link
      @rp.fields.should include image_link: "/custom/domain_1/theme/restaurants2/images/noPhoto.png"
    end
  end

  context "restaurant with a review" do
    before(:each) do
      @rp_review = RestaurantParser.new(items[1], base)
    end
    it "should parse a reviewer location" do
      @rp_review.reviewer_location
      @rp_review.fields.should include reviewer_location: "Citysearch"
    end
    it "should parse a reviewer location link" do
      @rp_review.reviewer_location_link
      @rp_review.fields.should include reviewer_location_link: "http://charlotte.citysearch.com/review/616261220?reviewId=177087361"
    end
    it "should parse a reviewer name" do
      @rp_review.reviewer_name
      @rp_review.fields.should include reviewer_name: "the stud"
    end
    it "should parse a review text" do
      @rp_review.review_text
      @rp_review.fields.should include review_text: "\"WOW! I may have been misinformed about this place before I went; I didn't realize this was a NICE restaurant. Actually, I wasn't misinformed. It's not a NICE restaurant. It's a decent restaurant, but it's not nearly as nice as they…\""
    end
  end

  context "restaurant without a review" do
    before(:each) do
      @rp_no_review = RestaurantParser.new(items[0], base)
    end

    it "should parse a link to the first review" do
      @rp_no_review.first_review_link
      @rp_no_review.fields.should include first_review_link: "/listing/reviewformpopup.php?item_type=listing&item_id=265119&keepThis=true&TB_iframe=true&width=740&height=470"
    end
  end

  context "restaurant with rating" do
    before(:each) do
      @rp_rating = RestaurantParser.new(items[1], base)
    end

    it "should parse a rating of the restaurant" do
      @rp_rating.rating
      @rp_rating.fields[:rating].should == 7
    end
  end
  context "restaurant without rating" do
    before(:each) do
      @rp_no_rating = RestaurantParser.new(items[0], base)
    end

    it "should be with 0 rating" do
      @rp_no_rating.rating
      @rp_no_rating.fields[:rating].should == 0
    end
  end

end