class Restaurant < ActiveRecord::Base
  attr_accessible :address, :name, :other, :rating, :review_text, :reviewer_location, :reviewer_name, :zip,
                  :link, :twitter_link, :facebook_link, :map_link, :new_review_link, :email_link,
                  :image_link, :first_review_link, :reviewer_location_link

  store :other, accessors: [:link, :twitter_link, :facebook_link, :map_link, :new_review_link, :email_link,
                            :image_link, :first_review_link, :reviewer_location_link]
end
