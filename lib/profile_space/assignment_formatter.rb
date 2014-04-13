class AssignmentFormatter
  def self.format_assignments(assignments)
    assignments.map { |a| format_assignment(a) }
  end

  def self.format_assignment(assignment)
    formatted = assignment.sort { |x, y| x[0] <=> y[0] }.map do |rc|
      format_role_combination(rc)
    end
    formatted.join('; ')
  end

  def self.format_role_combination(role_combination)
    strategies = role_combination.drop(1)
    formatted = strategies.uniq.sort.map { |s| "#{strategies.count(s)} #{s}" }
    "#{role_combination[0]}: " + formatted.join(', ')
  end
end
