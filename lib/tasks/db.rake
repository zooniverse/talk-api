def panoptes_config
  return @config if @config
  key = "panoptes_#{ Rails.env }"
  config = YAML.load_file Rails.root.join('config/database.yml')
  raise "database.yml does not configure #{ key }\n\n" unless config
  @config = config[key]
end

namespace :panoptes do
  namespace :db do
    desc 'Setup postgres_fdw'
    task :setup_fdw => :environment do
      # Setup foreign data wrappers on Talk
      ActiveRecord::Base.connection.execute <<-SQL
        do language plpgsql $$
          begin
            if (select count(*) from pg_extension where extname = 'postgres_fdw') = 0 then
              create extension postgres_fdw;
            end if;
            
            if (select count(*) from pg_foreign_server where srvname = 'panoptes') = 0 then
              create server panoptes foreign data wrapper postgres_fdw options (
                host '#{ panoptes_config.fetch('host', 'localhost') }',
                dbname '#{ panoptes_config['database'] }',
                port '#{ panoptes_config.fetch('port', 5432) }'
              );
              
              create user mapping for #{ panoptes_config['username'] } server panoptes options (
                user '#{ panoptes_config['username'] }',
                password '#{ panoptes_config['password'] }'
              );
            end if;
          end;
        $$;
      SQL
    end
    
    desc 'Creates foreign tables from Panoptes'
    task :create_foreign_tables => :environment do
      ActiveRecord::Base.connection.execute <<-SQL
        create foreign table if not exists projects (
          id int4,
          name varchar(255),
          private bool
        ) server panoptes;
        
        create foreign table if not exists collections (
          id int4,
          name varchar(255),
          project_id int4,
          created_at timestamp(6),
          updated_at timestamp(6),
          display_name varchar(255),
          private bool
        ) server panoptes;
        
        create foreign table if not exists subjects (
          id int4,
          zooniverse_id varchar(255),
          metadata json,
          locations json,
          created_at timestamp(6),
          updated_at timestamp(6),
          project_id int4
        ) server panoptes;
        
        create foreign table if not exists users (
          id int4,
          email varchar(255),
          created_at timestamp(6),
          updated_at timestamp(6),
          display_name varchar(255),
          zooniverse_id varchar(255),
          credited_name varchar(255),
          admin bool,
          banned bool
        ) server panoptes;
      SQL
    end
    
    desc 'Creates the search view'
    task :create_search_view => :environment do
      ActiveRecord::Base.connection.execute <<-SQL
        do language plpgsql $$
          begin
            if (select count(*) from pg_matviews where matviewname = 'searchable_collections') = 0 then
              create materialized view searchable_collections as
              select
                collections.id as searchable_id,
                'Collection'::text as searchable_type,
                
                setweight(to_tsvector(collections.name), 'B') ||
                setweight(to_tsvector(coalesce(collections.display_name, '')), 'B') ||
                setweight(to_tsvector(string_agg(coalesce(tags.name, ''), ' ')), 'A') ||
                setweight(to_tsvector('C' || collections.id::text), 'A')
                as content,
                
                projects.id || '-' || projects.name as section
              from collections
                left join tags on tags.taggable_id = collections.id and tags.taggable_type = 'Collection'
                join projects on projects.id = collections.project_id
              where
                collections.private is not true and projects.private is not true
              group by
                collections.id, collections.name, collections.display_name, projects.id, projects.name;
              
              create unique index search_collections_id_index on searchable_collections using btree(searchable_id);
              create index search_collections_index on searchable_collections using gin(content);
              create index search_collections_section_index on searchable_collections using btree(section, searchable_type);
            end if;
            
            create or replace view searches as
              select * from searchable_boards
              union all
              select * from searchable_collections
              union all
              select * from searchable_comments
              union all
              select * from searchable_discussions;
          end;
        $$;
      SQL
    end
    
    desc 'Create Panoptes tables for testing'
    task :create_tables => :environment do
      raise 'This is only meant for test or development' unless Rails.env.test? || Rails.env.development?
      ActiveRecord::Base.establish_connection panoptes_config
      ActiveRecord::Base.connection.execute <<-SQL
        drop table if exists users;
        create table users (
          id serial,
          email varchar(255) default ''::character varying,
          encrypted_password varchar(255) not null default ''::character varying,
          reset_password_token varchar(255),
          reset_password_sent_at timestamp(6) null,
          remember_created_at timestamp(6) null,
          sign_in_count int4 not null default 0,
          current_sign_in_at timestamp(6) null,
          last_sign_in_at timestamp(6) null,
          current_sign_in_ip varchar(255),
          last_sign_in_ip varchar(255),
          created_at timestamp(6) null,
          updated_at timestamp(6) null,
          hash_func varchar(255) default 'bcrypt'::character varying,
          password_salt varchar(255),
          display_name varchar(255),
          zooniverse_id varchar(255),
          credited_name varchar(255),
          classifications_count int4 not null default 0,
          activated_state int4 not null default 0,
          languages varchar(255)[] not null default '{}'::character varying[],
          global_email_communication bool,
          project_email_communication bool,
          admin bool not null default false,
          banned bool not null default false,
          migrated bool default false,
          constraint users_pkey primary key (id)
        );
        
        drop table if exists projects;
        create table projects (
          id serial,
          name varchar(255),
          display_name varchar(255),
          user_count int4,
          created_at timestamp(6) null,
          updated_at timestamp(6) null,
          classifications_count int4 not null default 0,
          activated_state int4 not null default 0,
          primary_language varchar(255),
          avatar text,
          background_image text,
          private bool,
          lock_version int4 default 0,
          constraint projects_pkey primary key (id)
        );
        
        drop table if exists collections;
        create table collections (
          id serial,
          name varchar(255),
          project_id int4,
          created_at timestamp(6) null,
          updated_at timestamp(6) null,
          activated_state int4 not null default 0,
          display_name varchar(255),
          private bool,
          lock_version int4 default 0,
          constraint collections_pkey primary key (id)
        );
        
        drop table if exists subjects;
        create table subjects (
          id serial,
          zooniverse_id varchar(255),
          metadata json,
          locations json,
          created_at timestamp(6) null,
          updated_at timestamp(6) null,
          project_id int4,
          migrated bool,
          lock_version int4 default 0,
          upload_user_id varchar(255),
          constraint subjects_pkey primary key (id)
        );
      SQL
    end
    
    desc 'Loads Panoptes database'
    task :setup => [:setup_fdw, :create_foreign_tables, :create_search_view]
  end
end
