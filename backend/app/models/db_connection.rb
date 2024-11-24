class DbConnection < ApplicationRecord
  attr_accessor :ssl_key_name, :ssl_cert_name, :ssl_ca_name, :ssl_key_file, :ssl_cert_file, :ssl_ca_file, :db_instance
  @@database_config = {
    :mysql => {
      :rubygem => "mysql2",
      :system_schemas => ["sys", "mysql", "information_schema", "performance_schema"]
    }
  }

  def self.system_schema? db_type, schema_name
    @@database_config[db_type.to_sym][:system_schemas].include? schema_name
  end

  def self.to_gem_name db_type
    @@database_config[db_type.to_sym][:rubygem]
  end

  def self.primary
    config_hash = ActiveRecord::Base.send(:resolve_config_for_connection, Rails.env.to_sym)
    ActiveRecord::Base.establish_connection config_hash
    yield if block_given?
  end


  validates :name, presence: { message: 'validate.required' }
  validates :host, presence: true
  validates :port, presence: true
  validates :default_database_name, presence: true
  validates :db_type, presence: true, inclusion: {in: ["MySQL", "postgreSQL", "Aurora MySQL", "Aurora postgreSQL"]}
  validates :login_name, presence: true
  validates :timeout, numericality: { only_integer: true }
  validates :use_ssl, inclusion: {in: [true, false]}
  validate :ssl_file_valid?

  def ssl_file_valid?
    return true unless self.use_ssl

    !self.ssl_key_name.blank? &&
    !self.ssl_key_file.blank? &&
    !self.ssl_cert_name.blank? &&
    !self.ssl_cert_file.blank? &&
    !self.ssl_ca_name.blank? &&
    !self.ssl_ca_file.blank
  end

  def build_ssl
    self.ssl_key = Rails.root.join("storage", self.id, self.ssl_key_name)
    self.ssl_cert = Rails.root.join("storage", self.id, self.ssl_cert_name)
    self.ssl_ca = Rails.root.join("storage", self.id, self.ssl_ca_name)
    [
      {:path => self.ssl_key, :file => self.ssl_key_file},
      {:path => self.ssl_cert, :file => self.ssl_cert_file},
      {:path => self.ssl_ca, :file => self.ssl_ca_file},
    ].each{|e|
      File.open(e[:path], 'w+b') do |file|
        file.write(e[:file].read)
      end
    }
  end

  def save!
    super
    return unless self.use_ssl
    build_ssl
    super
  end

  def save
    super
    return unless self.use_ssl
    build_ssl
    super
  end

  def self.create_connection id
    DbConnection.establish_primary
    settings = self.find(id)
    config = {
      :adapter => DbConnection::to_gem_name(settings.db_type), 
      :encoding => 'utf8',
      :database => 'information_schema',
      :pool => 1,
      :username => settings.login_name,
      :password => settings.password,
      :host => settings.host,
      :port => settings.port,
      :database_task => false
    }
    ActiveRecord::Base.establish_connection config
    yield ActiveRecord::Base.connection, settings.db_type
  end
end
