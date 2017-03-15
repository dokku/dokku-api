class Key
  include DataMapper::Resource
  property :id, Serial
  property :api_key, String
  property :api_secret, String

  validates_uniqueness_of :api_key

  def self.generate
    loop do
      key = Key.create(
        api_key: generate_string(16),
        api_secret: generate_string(16)
      )
      break key if key.valid?
    end
  end

  def self.generate_string(len)
    SecureRandom.hex(len)
  end
end
