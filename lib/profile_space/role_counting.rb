# Adding a method to string that lets assignment strings report their role
# counts.  This should probably be changed to subclassing String or something
# similar.  I've done it this way because I don't want to add a new type for
# the database or ORM to know about.
# This is bad practice, but convenient
class String
  def role_counts
    role_hash = {}
    split('; ').each do |role_string|
      role, strategy_string = role_string.split(': ')
      role_hash[role] = strategy_string.split(', ').map do |s|
        s.split(' ')[0].to_i
      end.reduce(:+)
    end
    role_hash
  end
end
