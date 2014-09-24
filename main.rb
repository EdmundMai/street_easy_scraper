require 'json'
require 'open-uri'
require 'nokogiri'

def scrape(page_number)
  sales_listings = []
  doc = Nokogiri::HTML(open("http://streeteasy.com/for-sale/soho?page=#{page_number}sort_by=price_desc"))
  doc.css(".listing").each do |listing|
    full_street_address = listing.at_css(".details_title h5").text.split("#")
    
    listing_class = 'Sale'
    address = full_street_address.first.strip
    unit = full_street_address[1]
    price = listing.at_css(".price").text
    sales_listings << {listing_class: listing_class, address: address, unit: unit, price: price}
  end
  sales_listings.to_json
end
