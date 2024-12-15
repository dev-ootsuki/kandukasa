class DbConnection < ApplicationRecord
  TIMEOUT_MAX_VALUE = 1000 * 60 * 10
  attr_accessor :ssl_key_name, :ssl_cert_name, :ssl_ca_name, :ssl_key_file, :ssl_cert_file, :ssl_ca_file, :db_instance
  def self.primary
    config_hash = ActiveRecord::Base.send(:resolve_config_for_connection, Rails.env.to_sym)
    ActiveRecord::Base.establish_connection config_hash
    yield if block_given?
  end


  validates :name, presence: { message: 'validate.required' }, length: {maximum: 32, message: 'validate.length_to#32'}
  validates :host, presence: { message: 'validate.required' }, length: {maximum: 128, message: 'validate.length_to#128'}
  validates :port, presence: { message: 'validate.required' }, inclusion: { in: 1..99999, message: 'validate.range_from_to#1-99999' }
  validates :default_database_name, presence: {message: 'validate.required'}, length: {maximum: 64, message: 'validate.length_to#64'}
  validates :db_type, presence: {message: 'validate.required'}, inclusion: {in: DbStrategy::DB_STRATEGRY_SETTING.keys.map{|e| "#{e}"}, message: 'validate.select_from_puludown'}
  validates :login_name, presence: {message: 'validate.required'}, length: {maximum: 32, message: 'validate.length_to#32'}
  validates :password, length: {maximum: 64, message: 'validate.length_to#64'}
  validates :timeout, inclusion: { in:1..TIMEOUT_MAX_VALUE, message: "validate.range_from_to#1-#{TIMEOUT_MAX_VALUE}" }
  validates :description, length: {maximum: 1024, message: 'validate.length_to#1024'}
  validates :use_ssl, inclusion: {in: [true, false], message: 'validate.select_from_puludown'}
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

end
