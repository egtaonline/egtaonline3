class FeatureProcessor
  def self.parse(feature_map)
    feature_map ||= {}
    features = {}
    extended_features = {}
    feature_map.each do |key, value|
      value.numeric? ? features[key] = value : extended_features[key] = value
    end
    { 'features' => features, 'extended_features' => extended_features }
  end
end
