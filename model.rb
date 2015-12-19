DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/accountables.sqlite3")

class User
  include DataMapper::Resource
  
  property :id              , Serial
  property :name            , String
  property :username        , String      , :length => 8..250
  property :habit           , String
  property :password        , BCryptHash
  property :current_streak  , Integer

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
