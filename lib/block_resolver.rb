class BlockResolver
  def self.resolve(identifier, locals)
    File.read("src/themes/#{locals[:theme]}/blocks/#{identifier}.haml")
  end
end
Hamloft.block_resolver = BlockResolver
