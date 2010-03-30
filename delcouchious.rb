require 'sinatra'
require 'json'
require 'builder'
require 'lib/bookmark'
require 'yaml'

config = YAML.load_file("config.yml")

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  "Application error"
end

helpers do
  def output_bookmark(mark)
    erb :bookmark, {:layout => false, :locals => {:mark => mark}}
  end

  def mobile?
    request.user_agent =~ /Mobile|webOS/
  end

  def format_date(date)
    return "" if date.nil?
    date = Time.parse(date) if date.is_a? String
    date.strftime("%d/%m/%Y %H:%M")
  end
end

get '/posts/add' do
  tags = params["tags"] || ""
  doc = {
          :href => params["url"],
          :notes => params["extended"],
          :short_url => nil,
          :tags => tags.split(" "),
          :title => params["description"],
          :date_created => Time.new.utc
  }
  Bookmark.new(doc).save
  '<result code="done" />'
end

get '/posts/update' do
  recent = Bookmark.find_recent(1)
  date_created = recent.nil? ? Time.new.utc : recent.first.date_created
  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    xml.update :time => date_created, :inboxnew => '0'
  end
end

get '/posts/all' do
  all = Bookmark.all
  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    # <posts user="blimpindustries" update="2009-08-17T14:30:00Z" tag="" total="509">
    xml.posts :user => "#{config['username']}", :update => all.last.date_created.to_json, :tag => "", :total => all.count do
      all.each do |mark|
        # <post href="http://interface.khm.de/" hash="3a145fb2dbcf22f882850ea2fe3a5214" description="Lab3 - Laboratory for Experimental Computer Science" tag="arduino programming hardware" time="2009-08-12T04:43:22Z" extended="This example shows how to make use of the Watchdog and Sleep functions provided by the ATMEGA 168 chip . These functions are useful if you want to build  low power consuming devices operated by battery or solar power." meta="" />
        tags = mark.tags.join(" ")
        xml.post :href => mark.href, :hash => mark._id, :description => mark.title, :tag => tags, :time => mark.date_created.to_json, :extended => mark.description, :meta => ""
      end
    end
  end
end

get '/posts/recent' do
  bookmarks = Bookmark.find_recent(100)
  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    # <posts user="username" update="2009-08-17T14:30:00Z" tag="" total="509">
    xml.posts :user => "#{config['username']}", :update => bookmarks.last.date_created do
      bookmarks.each do |mark|
        # <post href="http://interface.khm.de/" hash="3a145fb2dbcf22f882850ea2fe3a5214" description="Lab3 - Laboratory for Experimental Computer Science" tag="arduino programming hardware" time="2009-08-12T04:43:22Z" extended="This example shows how to make use of the Watchdog and Sleep functions provided by the ATMEGA 168 chip . These functions are useful if you want to build  low power consuming devices operated by battery or solar power." meta="" />
        tags = mark.tags.join(" ")
        xml.post :href => mark.href, :hash => mark._id, :description => mark.title, :tag => tags, :time => mark.date_created.to_json, :extended => mark.description, :meta => ""
      end
    end
  end
end

get '/' do
  @speed_dial = Bookmark.find_by_tag("speeddial")
  @to_read = Bookmark.find_by_tag("toread")
  @recent = Bookmark.find_recent(10)
  @tag_cloud, @hidden_count = get_tag_cloud
  erb :index
end

get '/:tag' do
  @tag = params[:tag]
  @bookmarks = Bookmark.find_by_tag(@tag)
  erb :tag
end

private

def get_tag_cloud
  tags = Bookmark.tag_counts || []
  counts = []
  hidden_count = 0
  tags.each do |tag|
    below_threshold = tag['value'].to_i < 5
    hidden_count = hidden_count.next if below_threshold
    counts << {:name => tag['key'], :count => tag['value'], :display => (below_threshold ? "hidden" : "") }
  end
  [counts, hidden_count]
end
