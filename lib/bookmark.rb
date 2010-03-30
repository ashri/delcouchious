require 'json'
require 'httparty'
require 'ostruct'
require 'yaml'

class Time
  def to_json; self.strftime('"%Y/%m/%d %H:%M:%S +0000"'); end
end

class Bookmark < OpenStruct

  def self.database_name
    config = YAML.load_file("config.yml")
    config["database"]
  end

  include HTTParty
  format :json
  base_uri "localhost:5984/#{database_name}"

  def initialize(params={})
    super
    self.date_created = Time.now if !self._rev
    self
  end

  def self.all
    response = get("/_design/documents/_view/by_date")
    response['rows'].map { |p| new(p['value']) } if response['rows']
  end

  def self.find_recent(limit)
    response = get("/_design/documents/_view/by_date?descending=true&limit=#{limit}")
    response['rows'].map { |p| new(p['value']) } if response['rows']
  end

  def self.find_by_tag(tag)
    response = get("/_design/tags/_view/documents?key=%22#{tag}%22")
    response['rows'].map { |p| new(p['value']) } if response['rows']
  end

  def self.find(id)
    new get('/'+id)
  end

  def self.tag_counts
    response = get("/_design/tags/_view/count?group=true")
    response['rows']
  end

  def save
    @table.delete(:_id) if self._id.nil? || self._id.empty?
    @table.delete(:_rev) if self._rev.nil? || self._rev.empty?
    if !self._id.nil?
      response = self.class.put("/#{self._id}", :body => self.to_json)
    else
      response = self.class.post('/', :body => self.to_json)
    end
    if response.code.to_s == '201'
      self._rev = JSON.parse(response.body)['rev']
      self
    else
      raise Exception, response.body
    end
  end

  def to_json
    @table.to_json
  end

end
