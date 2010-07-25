# vim: set softtabstop=2 shiftwidth=2 expandtab :
# (c) 2010 KissCool & Madtree

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'

# helpers
require File.join(File.dirname(__FILE__), 'helpers.rb')

# entry point
class App < Sinatra::Base
  helpers MyHelpers
  set :static, true
  set :public, 'public/'

  # loading the db model
  require File.join(File.dirname(__FILE__), 'model.rb')

  before do
    content_type :html, 'charset' => 'utf-8'
  end

  get '/' do
    haml :index
  end

  get '/test' do
    'bla bla'
  end

  # listing of all posts
  get '/posts' do
    @posts = Post.all(:visible => true)
    haml :posts
  end

  # post initial creation
  post '/posts' do
    # we set the date
    params[:created_at] = Time.now
    # we set properties
    @post = Post.new(params.reject {|k,v| k == 'tags'} )

    # we extract and retrieve/tags, 
    # while removing blanc spaces before and after them
    if params[:tags] != "" and !params[:tags].nil? then
      tags = params[:tags].split /[ ]*,[ ]*/
      tags_collection = tags.collect {|t| Tag.first_or_new(:name => t)}
      tags_collection.each {|tag| @post.tags << tag}
    end
    
    @post.save

    # finaly we redirect towards the article
    redirect "/post/#{@post.short_title}"
  end

  # give the form to create new post
  get '/posts/new' do
    haml :post_new
  end

  # show individual article
  get '/post/:short_title' do
    @post = Post.first(:short_title => params[:short_title])
    not_found if !@post
    haml :post
  end

  # update an article
  # should be a 'put', but seems to work only as a post method
  post '/post/:short_title' do
    @post = Post.first_or_new(:short_title => params[:short_title])
    #not_found if !@post

    # we set properties
    params_without_tags = params.reject {|k,v| k == 'tags'}
    p params_without_tags
    params_without_tags.each {|key,val| @post[key] = val}

    # we extract and retrieve/tags, 
    # while removing blanc spaces before and after them
    if params[:tags] != "" and !params[:tags].nil? then
      tags = params[:tags].split /[ ]*,[ ]*/
      tags_collection = tags.collect {|t| Tag.first_or_new(:name => t)}
      tags_collection.each {|tag| @post.tags << tag}
    end

    @post.save
    
    # finaly we redirect towards the article
    redirect "/post/#{@post.short_title}"
  end

  # we get the form in order to edit an article
  get '/post/:short_title/edit' do
    @post = Post.first(:short_title => params[:short_title])
    not_found if !@post
    haml :edit
  end

  # this is the new shit, baby
  get '/stylesheet.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :stylesheet
  end

end
