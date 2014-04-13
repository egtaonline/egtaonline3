class CVPayoffAdjuster
  def self.adjust(payoff, observation_features, observation_cvs,
                  player_features, player_cvs)
    accumulator = payoff
    observation_cvs.each do |cv|
      return payoff unless observation_features[cv.name]
      value = Float(observation_features[cv.name])
      accumulator += cv.coefficient * (value - cv.expectation)
    end
    player_cvs.each do |cv|
      return payoff unless player_features[cv.name]
      value = Float(player_features[cv.name])
      accumulator += cv.coefficient * (value - cv.expectation)
    end
    accumulator
  end
end
