require "version"

module SqliteUlid
  class Error < StandardError; end
  def self.ulid_loadable_path
    File.expand_path('../ulid0', __FILE__)
  end
  def self.load(db)
    db.load_extension(self.ulid_loadable_path)
  end
end
