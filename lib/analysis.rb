Dir[File.dirname(__FILE__) + '/analysis/*.rb'].each do |file|
  require file
end
