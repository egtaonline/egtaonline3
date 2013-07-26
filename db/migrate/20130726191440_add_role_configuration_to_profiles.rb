class AddRoleConfigurationToProfiles < ActiveRecord::Migration
  def up
    add_column :profiles, :role_configuration, :hstore, null: false
    execute "CREATE INDEX profiles_gin_role_configuration ON profiles USING GIN(role_configuration)"
    unless Rails.env == "test"
      Profile.all.each do |profile|
        role_configuration = {}
        profile.symmetry_groups.each do |sym|
          role_configuration[sym.role] ||= 0
          role_configuration[sym.role] += sym.count
        end
        profile.update_attributes(role_configuration: role_configuration)
      end
    end
  end

  def down
    remove_column :profiles, :role_configuration
    execute "DROP INDEX profiles_gin_role_configuration"
  end
end
