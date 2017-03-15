class Command
  include DataMapper::Resource
  property :id, Serial
  property :command_hash, String, length: 64
  property :command, String
  property :result, Text
  property :created_at, DateTime
  property :ran_at, DateTime

  validates_uniqueness_of :command_hash
  validates_presence_of :command

  before :create, :generate_unique_key

  def generate_unique_key
    loop do
      self.command_hash = SecureRandom.hex(32)
      break unless Command.first(command_hash: self.command_hash)
    end
  end
end
