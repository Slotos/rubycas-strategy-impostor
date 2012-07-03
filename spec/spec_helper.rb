require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

def config
  @config ||= YAML.load_file( File.expand_path(File.dirname(__FILE__) + '/example_config.yml') )
end

def init_db!
  @database = config["strategies"]["database"]
  db = Sequel.connect(@database)
  db.create_table :users do
    primary_key :id
    String :email, :unique => true
  end
  db.create_table :roles do
    primary_key :id
    String :name
  end
  db.create_table :roles_users do
    foreign_key :user_id, :users
    foreign_key :role_id, :roles
  end
  db.disconnect
end

def add_user(email, *args)
  options = args.last.is_a?(Hash) ? args.pop : {}
  db = Sequel.connect(@database)

  user_id = db[:users].insert(:email => email)

  options[:roles] = [options[:role]] unless options[:roles]
  options[:roles].each do |role|
    role_id = db[:roles].insert(:name => role)
    db[:roles_users].insert(:user_id => user_id, :role_id => role_id)
  end

  db.disconnect
end

def truncate_database
  db = Sequel.connect(@database)
  db[:roles_users].delete
  db[:users].delete
  db[:roles].delete
  db.disconnect
end

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.after :all do
    FileUtils.rm_f(config["strategies"]["database"]["database"])
  end
  conf.before :all do
    init_db!
  end
end

class CASServer::Mock < Sinatra::Base
  set :config, config

  def self.uri_path
    ""
  end

  def validate_ticket_granting_ticket(tkt)
  end

  set :workhorse, config["strategies"]
  require File.expand_path(File.dirname(File.dirname(__FILE__)) + '/lib/rubycas-strategy-impostor')
  register CASServer::Strategy::Impostor
end

def app
  CASServer::Mock
end
