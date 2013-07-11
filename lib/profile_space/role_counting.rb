class String
  def role_counts
    role_hash = {}
    self.split("; ").each do |role_string|
      role, strategy_string = role_string.split(": ")
      role_hash[role] = strategy_string.split(", ").map do |s|
        s.split(" ")[0].to_i
      end.reduce(:+)
    end
    role_hash
  end
end