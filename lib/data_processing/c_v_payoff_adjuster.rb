class CVPayoffAdjuster
  def self.adjust(payoff, observation_features, observation_cvs, player_features, player_cvs)
    accumulator = payoff
    observation_cvs.each do |cv|
      return payoff if observation_features[cv.name] == nil
      accumulator += cv.coefficient * (Float(observation_features[cv.name]) - cv.expectation)
    end
    player_cvs.each do |cv|
      return payoff if player_features[cv.name] == nil
      accumulator += cv.coefficient * (Float(player_features[cv.name]) - cv.expectation)
    end
    accumulator
  end
end