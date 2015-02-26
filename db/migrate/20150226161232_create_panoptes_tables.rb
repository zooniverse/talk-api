require 'yaml'

class CreatePanoptesTables < ActiveRecord::Migration
  def up
    raise "database.yml does not configure panoptes_#{ Rails.env }\n\n" unless panoptes_config
    
    execute <<-SQL
      drop extension if exists postgres_fdw cascade;
      create extension postgres_fdw;
      create server panoptes foreign data wrapper postgres_fdw options (host '#{ panoptes_config.fetch('host', 'localhost') }', dbname '#{ panoptes_config['database'] }', port '#{ panoptes_config.fetch('port', 5432) }');
      create user mapping for #{ panoptes_config['username'] } server panoptes options (user '#{ panoptes_config['username'] }', password '#{ panoptes_config['password'] }');
      
      create foreign table projects (
        id int4,
        name varchar(255),
        private bool
      ) server panoptes;
      
      create foreign table collections (
        id int4,
        name varchar(255),
        project_id int4,
        created_at timestamp(6),
        updated_at timestamp(6),
        display_name varchar(255),
        private bool
      ) server panoptes;
      
      create foreign table subjects (
        id int4,
        zooniverse_id varchar(255),
        metadata json,
        locations json,
        created_at timestamp(6),
        updated_at timestamp(6),
        project_id int4
      ) server panoptes;
      
      create foreign table panoptes_users (
        id int4,
        email varchar(255),
        login varchar(255),
        display_name varchar(255),
        zooniverse_id varchar(255),
        admin bool,
        banned bool
      ) server panoptes options (table_name 'users');
    SQL
  end
  
  def down
    execute <<-SQL
      drop foreign table projects;
      drop foreign table collections;
      drop foreign table subjects;
      drop foreign table panoptes_users;
      drop user mapping for #{ panoptes_config['username'] } server panoptes;
      drop server panoptes cascade;
      drop extension postgres_fdw cascade;
    SQL
  end
  
  def panoptes_config
    return @config if @config
    key = "panoptes_#{ Rails.env }"
    config = YAML.load_file 'config/database.yml'
    raise "database.yml does not configure #{ key }\n\n" unless config
    @config = config[key]
  end
end
