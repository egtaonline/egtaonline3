# Adding numeric check to all objects, since we do a lot of translating between
# strings and data
class Object
  def numeric?
    true if Float(self) rescue false
  end
end
