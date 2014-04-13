class String
  def assignment_sort
    roles = split('; ').map { |role| role.split(': ') }
    roles.sort.map { |role| role[0] + ': ' + role[1].strategy_sort }.join('; ')
  end

  def strategy_sort
    split(', ').sort { |x, y| x.split(' ')[1] <=> y.split(' ')[1] }.join(', ')
  end
end
