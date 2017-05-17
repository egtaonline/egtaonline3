class Simulator < ActiveRecord::Base
  extend Searchable

  mount_uploader :source, SimulatorUploader
  serialize :role_configuration, JSON
  has_many :simulator_instances, dependent: :destroy, inverse_of: :simulator

  validates_presence_of :email, :name, :version, :source
  validates_uniqueness_of :version, scope: :name
  validates_format_of :name, with: /\A\w+\z/, message: 'can contain only ' \
    'letters, numbers, and underscores'

  before_validation :setup_simulator, if: :source_changed?

  def setup_simulator
    FileUtils.rm_rf location
    begin
      system("unzip -uqq #{source.path} -d #{location}")
    rescue
      errors.add(:source, 'Upload could not be unzipped')
      return
    end
    unless File.exist?("#{location}/#{name}/script/batch")
      errors.add(:source, 'did not find script/batch within' \
        " #{location}/#{name}")
    end
    if File.exist?("#{location}/#{name}/defaults.json")
      begin
        self.configuration = MultiJson.load(
          File.new("#{location}/#{name}/defaults.json"))['configuration']
      rescue MultiJson::LoadError
        errors.add(:source, 'defaults.json file is malformed.')
      end
    else
      errors.add(:source, "did not have defaults.json in folder #{name}")
    end
    Backend.prepare_simulator(self) if errors.messages.empty?
  end

  def fullname
    name + '-' + version
  end

  def add_strategy(role, strategy)
    role_configuration[role] ||= []
    strategy.strip!
    role_configuration[role] << strategy
    role_configuration[role].sort!
    self.save!
  end

  def remove_strategy(role, strategy)
    role_configuration[role].delete(strategy)
    self.save!
  end

  def add_role(role)
    if role =~ /\A\w+\z/
      role.strip!
      role_configuration[role] ||= []
      simulator_instances.each do |si|
        si.control_variables.each do |cv|
          RoleCoefficient.find_or_create_by(control_variable_id: cv.id,
                                            role: role)
        end
      end
      self.save!
    end
  end

  def remove_role(role)
    role_configuration.delete(role)
    self.save!
  end

  def default_search_column
    "name"
  end

  private

  def location
    File.join(Rails.root, 'simulator_uploads', fullname)
  end

  def self.general_search(search)
    return name_search(search)
  end

  def self.column_filter(results, filters)
    if filters.key?("name")
      results = name_filter(results, filters["name"])
    end
    if filters.key?("version")
      results = results.where("UPPER(version) = ?", filters["version"])
    end
    return results
  end
end
