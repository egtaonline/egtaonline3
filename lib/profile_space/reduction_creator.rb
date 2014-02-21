class ReductionCreator
  def self.expand_assignments(assignments, roles)
    assignments.collect { |assignment| expand_assignment(assignment, roles) }.flatten(1)
  end

  private

  def self.expand_role(strategy_hash, player_count)
    player_multiple = strategy_hash.values.reduce(:+)
    reduction_factor = (player_multiple == 0 || player_multiple == nil) ? 0 : player_count.to_f/player_multiple
    {}.tap do |full_role|
      strategy_hash.each { |strategy, count| full_role[strategy] = count == 0 ? 0 : count * player_count / player_multiple }
      current_count = full_role.values.reduce(:+)
      current_count ||= 0
      while current_count < player_count
        full_role[max_key(full_role, reduction_factor, strategy_hash)] += 1
        current_count = full_role.values.reduce(:+)
      end
    end
  end

  def self.hasherize(strat_array)
    {}.tap do |strat_hash|
      strat_array.uniq.each { |strat| strat_hash[strat] = strat_array.count(strat) }
    end
  end

  def self.strategy_dehasherize(strategy_hash)
    strategy_array = []
    strategy_hash.each do |strategy, count|
      count.times{ strategy_array << strategy }
    end
    strategy_array.sort
  end
  
  private
  
  def self.max_key(full_role, reduction_factor, strategy_hash)
    entry = full_role.max do |x, y|
      first_check = (reduction_factor*strategy_hash[x[0]]-full_role[x[0]]) <=> (reduction_factor*strategy_hash[y[0]]-full_role[y[0]]) 
      if first_check == 0
        first_check = full_role[x[0]] <=> full_role[y[0]]
      end
      first_check
    end
    entry[0]
  end
end