# Computes all the strategy combinations for a role specified by name and count
class RoleCombinationGenerator
  def self.combinations(name, strategies, count)
    strategies.repeated_combination(count).map { |c| [name].concat(c) }
  end
end
