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

  # some kind of magic
  before do
    content_type :html, 'charset' => 'utf-8'
  end

  ############ Indexes
  #
  get '/' do
    haml :index
  end

  # listing of all visible posts
  get '/posts' do
    @posts = Post.all(:visible => true)
    haml :posts
  end

  # listing of all unfinished posts
  get '/drafts' do
    @posts = Post.all(:visible => false)
    haml :posts
  end

  ############ Edition of posts
  #

  # give the form to create new post
  get '/posts/new' do
    #haml :post_new
    haml :edit
  end

  # get the form in order to edit an article
  get '/post/:short_title/edit' do
    @post = Post.first(:short_title => params[:short_title])
    not_found if !@post
    haml :edit
  end


  # create a new article
  post '/posts' do
    @post = Post.first_or_new(:short_title => params[:short_title])
    if @post.saved?
      # if the article already exists, we will not overwrite it*
      error "An article with the same name already exists !"
    end
    # we set the date
    params[:created_at] = Time.now

    if @post.commit(params)
      # finaly we redirect towards the article
      redirect "/post/#{@post.short_title}"
    else
      error "Error during commit of the article in database"
    end
  end

  # update a new article
  # should be a 'put' for update, but seems to work only as a post method
  post '/post/:short_title' do
    p params
    @post = Post.first_or_new(:short_title => params[:short_title])
    # if we are trying to update an article, we verify first its existence
    not_found if !@post.saved?
    
    if @post.commit(params)
      # finaly we redirect towards the article
      redirect "/post/#{@post.short_title}"
    else
      error "Error during commit of the article in database"
    end
  end

  ############# Individual posts
  #

  # show individual article
  get '/post/:short_title' do
    @post = Post.first(:short_title => params[:short_title])
    not_found if !@post
    haml :post
  end

  ############ Misc
  #

  # this is the new shit, baby
  get '/stylesheet.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :stylesheet
  end

end
