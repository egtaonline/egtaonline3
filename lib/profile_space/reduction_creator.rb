# Class focused on expanding reduced game profiles into full game assignments
class ReductionCreator
  def self.expand_assignments(assignments, roles)
    assignments.flat_map { |assignment| expand_assignment(assignment, roles) }
  end

  def self.expand_role(strategy_hash, player_count)
    player_multiple = strategy_hash.values.reduce(:+)
    r_factor = reduction_factor(player_multiple, player_count)
    assignment = expand_evenly(strategy_hash, player_multiple, player_count)
    current_count = assignment.values.reduce(:+)
    current_count ||= 0
    while current_count < player_count
      assignment[max_key(assignment, r_factor, strategy_hash)] += 1
      current_count += 1
    end
    assignment
  end

  def self.expand_evenly(strategy_hash, player_multiple, player_count)
    {}.tap do |f|
      strategy_hash.each do |strategy, count|
        if player_multiple == 0
          f[strategy] = 0
        else
          f[strategy] = count * player_count / player_multiple
        end
      end
    end
  end

  def self.reduction_factor(player_multiple, player_count)
    if player_multiple == 0 || player_multiple.nil?
      0
    else
      player_count.to_f / player_multiple
    end
  end

  def self.hasherize(strat_array)
    {}.tap do |strat_hash|
      strat_array.uniq.each do |strat|
        strat_hash[strat] = strat_array.count(strat)
      end
    end
  end

  def self.strategy_dehasherize(strategy_hash)
    strategy_array = []
    strategy_hash.each do |strategy, count|
      count.times { strategy_array << strategy }
    end
    strategy_array.sort
  end

  def self.max_key(full_role, r_factor, strategy_hash)
    entry = full_role.max do |x, y|
      first_check = (
        satisfaction(r_factor, strategy_hash, full_role, x[0]) <=>
        satisfaction(r_factor, strategy_hash, full_role, y[0]))
      first_check == 0 ? full_role[x[0]] <=> full_role[y[0]] : first_check
    end
    entry[0]
  end

  def self.satisfaction(r_factor, desired, assigned, strategy)
    r_factor * desired[strategy] - assigned[strategy]
  end
end
