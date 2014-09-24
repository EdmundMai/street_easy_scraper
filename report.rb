require 'json'
require 'csv'
require 'mechanize'

class Report
  TYPES = ['sale', 'rental']
  
  attr_accessor :limit
  attr_reader :agent, :signed_in, :type
  
  def initialize(args={})
    self.type = args.fetch(:type) { TYPES[0] }
    self.limit = args.fetch(:limit) { 20 }
  end
  
  def type=(assigned_type)
    raise(ArgumentError, "Allowed types: #{TYPES.join(', ')}") if !TYPES.include?(assigned_type)
    @type = assigned_type
  end
  
  def sign_in
    # minimize the amount of external requests
    return if signed_in
    
    @agent ||= Mechanize.new
    page = @agent.get("https://streeteasy.com/nyc/user/sign_in")
    login_form = page.forms.last
    login_form.field_with(name: 'login').value = "secretusername@yahoo.com"
    login_form.field_with(name: 'password').value = "secretpassword"
    login_form.submit
    @signed_in = true
  end
  
  def data_location
    "http://streeteasy.com/nyc/process/#{type}s/xls/area:107?sort_by=price_desc"
  end
  
  def filename
    "#{type}_data.csv"
  end
  
  def grab_file
    sign_in
    @agent.pluggable_parser.default = Mechanize::Download
    
    # cache file locally to minimize external requests
    @agent.get(data_location).save(filename)
  end
  
  def json_data
    grab_file if !File.exists?(filename)
    listings = []
    
    amount_of_rows_to_skip = 2
    row_count = 0
    CSV.foreach(filename, col_sep: "\t") do |row|
      row_count = row_count + 1
      next if row_count <= amount_of_rows_to_skip
      
      break if listings.size >= limit
      listing_class = type.capitalize
      address = row[7]
      unit = row[8]
      price = row[2]
      url = row[0]
      listings << {listing_class: listing_class, address: address, unit: unit, url: url, price: price}
    end
    listings.to_json
  end
  
end



