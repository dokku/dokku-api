class Command
  include DataMapper::Resource
  property :id, Serial
  property :token, String, length: 64
  property :command, String, length: 255
  property :result, Text
  property :created_at, DateTime
  property :ran_at, DateTime
  property :callback_url, String

  validates_uniqueness_of :token
  validates_presence_of :command

  before :create, :generate_unique_token

  def generate_unique_token
    loop do
      self.token = SecureRandom.hex(32)
      break unless Command.first(token: self.token)
    end
  end

  def result_data
    self.result ? JSON.parse(self.result) : nil
  end
end
