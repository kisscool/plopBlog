# vim: set softtabstop=2 shiftwidth=2 expandtab :
require 'rubygems'
require 'dm-core'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/blog.sqlite3")

class Post
  include DataMapper::Resource
  property :id,           Serial
  property :title,        String
  property :short_title,  String
  property :created_at,   DateTime
  property :author,       String
  property :body,         Text
  property :visible,    Boolean, :default => false
  property :oneliner,     Boolean, :default => false

  has n, :comments
  has n, :tags, :through => Resource
end

class Comment
  include DataMapper::Resource
  property :id,           Serial
  property :created_at,   DateTime
  property :author,       String
  property :email,        String
  property :body,         Text

  belongs_to :post
end

class Tag
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String

  has n, :posts, :through => Resource
end

# check and initialise properties
DataMapper.finalize


