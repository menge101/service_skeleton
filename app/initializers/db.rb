require 'sequel'
require 'yaml'
MIGRATION_LOC = File.expand_path(File.join(PROJECT_ROOT, 'db/migrate'), PROJECT_ROOT)
db_conf_file = YAML.load_file(File.expand_path(File.join(PROJECT_ROOT, 'config', 'database.yml'), PROJECT_ROOT))
DB_CONFIG = db_conf_file[RACK_ENV].freeze
DB ||= Sequel.connect DB_CONFIG
Sequel.extension :migration
begin
  Sequel::Migrator.check_current(DB, MIGRATION_LOC)
rescue Sequel::Migrator::Error => e
  raise e unless e.message == 'No target version available, probably because no migration files found or filenames don'\
                              "'t follow the migration filename convention"
  # TODO: should be logged, not put.
  puts 'No migrations were found.'
end
