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
  property :visible,      Boolean, :default => false
  property :oneliner,     Boolean, :default => false

  has n, :comments
  has n, :tags, :through => Resource

  ### methods

  # create or update a post
  def commit(params)
    # we set default values for checkboxes
    [:visible, :oneliner].each {|key| params[key] = "f" if !params[key] }

    # we set properties
    params_without_tags = params.reject {|k,v| k == 'tags'}
    #params_without_tags.each {|key,val| attributes[key] = val}
    self.attributes = params_without_tags
    
    # we extract and retrieve/tags,
    # while removing blank spaces before and after them
    self.tags = [] # we use a clean slate
    if params[:tags] != "" and !params[:tags].nil? then
      tags_raw = params[:tags].split /[ ]*,[ ]*/
      tags_collection = tags_raw.collect {|t| Tag.first_or_new(:name => t)}
      tags_collection.each {|tag| self.tags << tag}
    end
    
    save
  end

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


