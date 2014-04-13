require "#{Rails.root}/lib/util"
require "#{Rails.root}/lib/profile_space"
require "#{Rails.root}/lib/data_processing"

DB = ActiveRecord::Base.connection

class ActiveRecord::Base

  # Execute SQL manually
  def self.exec_sql(*args)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, args)
    DB.execute(sql)
  end

  def exec_sql(*args)
    ActiveRecord::Base.exec_sql(*args)
  end
end
