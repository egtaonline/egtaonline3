Dir[File.dirname(__FILE__) + '/analysis_backend/*.rb'].each do |file|
  require file
end
