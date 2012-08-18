desc "Parse restaurant information from restaurants.com"
task :parse_restaurants_info => :environment do
  collector = RestaurantsCollector.new('Charlotte NC')
  collector.collect
  collector.update!
end
