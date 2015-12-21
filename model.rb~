DataMapper.setup(:default, ENV['DATABASE_URL'] ||"sqlite://#{Dir.pwd}/db/accountables.sqlite3")

configure :development do
  set :database, "sqlite3:///database.db"
  require 'dm-sqlite-adapter'
end

configure :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
  require 'dm-postgres-adapter'
end

class User
  include DataMapper::Resource
  
  property :id              , Serial
  property :name            , String
  property :username        , String      , :length => 8..250
  property :habit           , String
  property :password        , BCryptHash
  property :current_streak  , Integer
  property :last_updated    , DateTime

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
