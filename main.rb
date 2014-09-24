load 'report.rb'

if __FILE__ == $0
  type = ARGV[0]
  if type.nil?
    puts "Usage: ruby main.rb <property_type>"
    puts "Ex: ruby main.rb sale"
  else
    report = Report.new(type: type)
    p report.json_data
  end

end