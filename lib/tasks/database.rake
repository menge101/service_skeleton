# This file contains rake tasks for working with database.
require 'yaml'

def find_project_root
  `git rev-parse --show-cdup`.chomp
end

def db_uri
  dbconf = CONFIG[ENVIRONMENT]
  uri = "postgres://#{dbconf['username']}"
  uri << ":#{dbconf['password']}" if dbconf['password']
  uri << "@#{dbconf['host']}"
  uri << ":#{dbconf['port']}" if dbconf['port']
  uri << "/#{dbconf['database']}"
end

def schema_version(db)
  db.tables.include?(:schema_info) ? db[:schema_info].first[:version] : 0
end

def build_blank_migration
  "Sequel.migration do\n  up{}\n  down{}\nend"
end

def next_migration_prefix
  Dir.entries(MIGRATION_LOCATION).sort.last.to_i + 1
end

CONFIG_FILE = (find_project_root + 'config/database.yml').freeze
raise "Config file not found.
Config file must be located at project_root/#{CONFIG_FILE}" unless File.exist?(CONFIG_FILE)
CONFIG = YAML.load(File.open(CONFIG_FILE, 'r')).freeze
ENVIRONMENT = ENV['RACK_ENV'] || 'development'
MIGRATION_LOCATION = (find_project_root + 'db/migrate').freeze

namespace :pg do
  require 'pg'

  namespace :users do
    desc 'Creates database user defined for environment in config/databse.yml'
    task :create do
      con = PG.connect(dbname: 'postgres')
      begin
        con.exec("CREATE USER #{CONFIG[ENVIRONMENT]['username']} WITH PASSWORD '#{CONFIG[ENVIRONMENT]['password']}'")
      rescue PG::DuplicateObject
        puts "USER #{CONFIG[ENVIRONMENT]['username']} already exists"
      end
    end

    desc 'Drops the database user deinfed in config/database.yml'
    task :drop do
      con = PG.connect(dbname: 'postgres')
      begin
        con.exec("DROP USER IF EXISTS #{CONFIG[ENVIRONMENT]['username']}")
      rescue PG::DependentObjectsStillExist => e
        puts e.message
      end
    end
  end

  namespace :db do
    desc 'Creates Database'
    task :create do
      con = PG.connect(dbname: 'postgres')
      begin
        con.exec("CREATE DATABASE #{CONFIG[ENVIRONMENT]['database']} WITH OWNER #{CONFIG[ENVIRONMENT]['username']}")
      rescue PG::DuplicateDatabase
        puts "Database #{CONFIG[ENVIRONMENT]['database']} already exists"
      rescue PG::UndefinedObject => e
        puts "#{e.message.chomp} to own DB #{CONFIG[ENVIRONMENT]['database']}"
        puts 'Please run the postgres:users:create task first, and verify it is successful.'
      end
    end

    desc 'Drops Database'
    task :drop do
      con = PG.connect(dbname: 'postgres')
      con.exec("DROP DATABASE IF EXISTS #{CONFIG[ENVIRONMENT]['database']}")
    end
  end

  namespace :migrations do
    require 'sequel'
    Sequel.extension :migration
    DB = Sequel.connect(db_uri)
    version = schema_version DB

    desc 'Executes all unrun migrations'
    task :migrate do
      Sequel::Migrator.run(DB, MIGRATION_LOCATION)
      Rake::Task['pg:migrations:version'].execute
    end

    desc 'Rollback the specified number of migrations'
    task :rollback, [:count] do |_t, args|
      args.with_defaults(count: 1)
      Sequel::Migrator.run(DB, MIGRATION_LOCATION, target: (version.to_i - args[:count].to_i))
      Rake::Task['pg:migrations:version'].execute
    end

    desc 'Rollback all migrations'
    task :reset do
      Sequel::Migrator.run(DB, MIGRATION_LOCATION, target: 0)
      Rake::Task['pg:migrations:version'].execute
    end

    desc 'Generates a new database migration file'
    task :generate, [:desc] do |_t, args|
      raise 'Database migration must have a description' if args[:desc].nil?
      file_prefix = format('%03d', next_migration_prefix)
      file = File.new("#{MIGRATION_LOCATION}/#{file_prefix}_#{args[:desc]}", 'w+')
      file.print build_blank_migration
      file.close
    end

    desc 'Prints current schema version'
    task :version do
      version = schema_version DB
      puts "Schema Version: #{version}"
    end
  end
end
