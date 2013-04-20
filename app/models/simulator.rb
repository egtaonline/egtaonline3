class Simulator < ActiveRecord::Base
  attr_accessible :email, :name, :source, :version
  serialize :configuration, ActiveRecord::Coders::Hstore
  serialize :role_configuration, ActiveRecord::Coders::Hstore
  mount_uploader :source, SimulatorUploader

  has_many :simulator_instances, dependent: :destroy, inverse_of: :simulator

  validates_presence_of :email, :name, :version, :source
  validates_uniqueness_of :version, scope: :name
  validates_format_of :name, with: /\A\w+\z/, message: 'can contain only letters, numbers, and underscores'

  before_validation(if: :source_changed?) do
    FileUtils.rm_rf location

    begin
      system("unzip -uqq #{source.path} -d #{location}")
    rescue
      errors.add(:source, 'Upload could not be unzipped')
      return
    end

    if File.exists?("#{location}/#{name}/defaults.json")
      begin
        self.configuration = MultiJson.load(File.new("#{location}/#{name}/defaults.json"))["configuration"]
      rescue MultiJSON::LoadError
        errors.add(:source, 'The defaults.json file was malformed.')
      end
    else
      errors.add(:source, "Could not find defaults.json in folder #{name}.")
    end
    if errors.messages.empty?
      Backend.prepare_simulator(self)
    end
  end

  def fullname
    name + '-' + version
  end

  private

  def location
    File.join(Rails.root, 'simulator_uploads', fullname)
  end
end
