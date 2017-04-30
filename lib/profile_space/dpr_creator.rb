require_relative 'reduction_creator'

class DprCreator < ReductionCreator
  def self.expand_assignment(assignment, roles)
    assignment.map do |role_combination|
      role_name = role_combination[0]
      strategies = hasherize(role_combination.drop(1))
      strategies.map do |strategy, count|
        roles.map do |role|
          if role.name == role_name
            [role.name].concat(strategy_dehasherize(expand_for_target_strategy(
              strategy, strategies, role)))
          else
            combination = assignment.find { |rc| rc[0] == role.name }
            [role.name].concat(strategy_dehasherize(expand_role(hasherize(
              combination.drop(1)), role.count)))
          end
        end
      end
    end.flatten(1)
  end

  def self.sparse_expand_assignment(assignment, roles)
    assignment.map do |role_combination|
      role_name = role_combination[0]
      strategies = hasherize(role_combination.drop(1))
      deviating_strategies = strategies.find_all {|strategy, count| roles.find {|role| role.name == role_name}.deviating_strategies.include? strategy} # should only ever be 1 DS found
      deviating_strategies.map do |strategy, count|
        roles.map do |role|
          if role.name == role_name
            [role.name].concat(strategy_dehasherize(expand_for_target_strategy(
              strategy, strategies, role)))
          else
            combination = assignment.find { |rc| rc[0] == role.name }
            [role.name].concat(strategy_dehasherize(expand_role(hasherize(
              combination.drop(1)), role.count)))
          end
        end
      end
    end.flatten(1)
  end

  def self.expand_for_target_strategy(strategy, strategies, role)
    other_players = strategies.dup
    other_players[strategy] -= 1
    new_strategies = expand_role(other_players, role.count - 1)
    new_strategies[strategy] ||= 0
    new_strategies[strategy] += 1
    new_strategies
  end
end
