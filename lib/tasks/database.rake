# This file contains rake tasks for working with database.
require 'yaml'

CONFIG_FILE = 'config/database.yml'.freeze

raise "Config file not found.  Config file must be located at project_root/#{CONFIG_FILE}" unless File.exist?(CONFIG_FILE)
CONFIG = YAML.load(File.open(CONFIG_FILE, 'r')).freeze

def user_credentials(source)
  source.keys.map { |key| { username: source[key]['username'], password: source[key]['password'] } }.
      uniq { |item| item[:username] }.compact.freeze
end

def db_credentials(source)
  source.keys.map { |key| { db_name: source[key]['database'], owner: source[key]['username'] } }.
      uniq { |item| item[:db_name] }.delete_if { |item| item[:db_name].nil? }.freeze
end

namespace :postgres do
  require 'pg'
  namespace :users do
    CREDENTIALS = user_credentials(CONFIG)
    task :create do
      con = PG.connect(dbname: 'postgres')
      CREDENTIALS.each do |creds|
        begin
          con.exec("CREATE USER #{creds[:username]} WITH PASSWORD '#{creds[:password]}'")
        rescue PG::DuplicateObject => e
          puts "USER #{creds[:username]} already exists"
        end
      end
    end
    task :drop do
      con = PG.connect(dbname: 'postgres')
      CREDENTIALS.each do |creds|
        begin
          con.exec("DROP USER IF EXISTS #{creds[:username]}")
        end
      end
    end
  end

  namespace :database do
    DBS = db_credentials(CONFIG)
    task :create do
      con = PG.connect(dbname: 'postgres')
      DBS.each do |db|
        begin
          con.exec("CREATE DATABASE #{db[:db_name]} WITH OWNER #{db[:owner]}")
        rescue PG::DuplicateDatabase => e
          puts "Database #{db[:db_name]} already exists"
        rescue PG::UndefinedObject => e
          puts "#{e.message.chomp} to own DB #{db[:db_name]}"
          puts 'Please run the postgres:users:create task first, and verify it is successful.'
        end
      end
    end
    task :drop do
      con = PG.connect(dbname: 'postgres')
      DBS.each { |db| con.exec("DROP DATABASE IF EXISTS #{db[:db_name]}") }
    end
  end
end
