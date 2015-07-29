def panoptes_config
  @panoptes_config ||= db_config("panoptes_#{ Rails.env }")
end

def talk_config
  @talk_config ||= db_config(Rails.env)
end

def db_config(key)
  config = YAML.load_file(Rails.root.join('config/database.yml'))[key]
  raise "database.yml does not configure #{ key }\n\n" unless config
  config
end

def local_environment!
  raise 'This is only meant for test or development' unless Rails.env.test? || Rails.env.development?
end

namespace :panoptes do
  namespace :db do
    desc 'Setup postgres_fdw'
    task :setup_fdw => :environment do
      # Setup foreign data wrappers on Talk
      ActiveRecord::Base.establish_connection talk_config
      ActiveRecord::Base.connection.execute <<-SQL
        do language plpgsql $$
          begin
            if (select count(*) from pg_extension where extname = 'postgres_fdw') = 0 then
              create extension postgres_fdw;
            end if;
            
            if (select count(*) from pg_foreign_server where srvname = 'panoptes') = 0 then
              create server panoptes foreign data wrapper postgres_fdw options (
                host 'localhost',
                dbname '#{ panoptes_config['database'] }',
                port '#{ panoptes_config.fetch('port', 5432) }',
                use_remote_estimate 'true'
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
      ActiveRecord::Base.establish_connection talk_config
      ActiveRecord::Base.connection.execute <<-SQL
        create foreign table if not exists projects (
          id int4,
          display_name varchar(255),
          slug varchar(255),
          private bool
        ) server panoptes;
        
        create foreign table if not exists collections (
          id int4,
          name varchar(255),
          slug varchar(255),
          project_id int4,
          created_at timestamp(6),
          updated_at timestamp(6),
          display_name varchar(255),
          private bool
        ) server panoptes;
        
        create foreign table if not exists collection_subjects (
          id int4,
          subject_id int4,
          collection_id int4
        ) server panoptes;
        
        create foreign table if not exists media (
          id int4,
          type varchar(255),
          linked_id int4,
          linked_type varchar(255),
          content_type varchar(255),
          src text,
          path_opts text[],
          private bool,
          external_link bool,
          created_at timestamp(6),
          updated_at timestamp(6)
        ) server panoptes;
        
        create foreign table if not exists subjects (
          id int4,
          zooniverse_id varchar(255),
          metadata json,
          created_at timestamp(6),
          updated_at timestamp(6),
          project_id int4
        ) server panoptes;
        
        create foreign table if not exists users (
          id int4,
          email varchar(255),
          login varchar(255),
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
      ActiveRecord::Base.establish_connection talk_config
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
                
                'project-' || projects.id as section
              from collections
                left join tags on tags.taggable_id = collections.id and tags.taggable_type = 'Collection'
                join projects on projects.id = collections.project_id
              where
                collections.private is not true and projects.private is not true
              group by
                collections.id, collections.name, collections.display_name, projects.id;
              
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
      local_environment!
      ActiveRecord::Base.establish_connection panoptes_config
      ActiveRecord::Base.connection.execute <<-SQL
        drop table if exists users;
        create table users (
          id serial not null,
          email character varying default ''::character varying,
          encrypted_password character varying default ''::character varying not null,
          reset_password_token character varying,
          reset_password_sent_at timestamp without time zone,
          remember_created_at timestamp without time zone,
          sign_in_count integer default 0 not null,
          current_sign_in_at timestamp without time zone,
          last_sign_in_at timestamp without time zone,
          current_sign_in_ip character varying,
          last_sign_in_ip character varying,
          created_at timestamp without time zone,
          updated_at timestamp without time zone,
          hash_func character varying default 'bcrypt'::character varying,
          password_salt character varying,
          login character varying not null,
          display_name character varying not null,
          zooniverse_id character varying,
          credited_name character varying,
          classifications_count integer default 0 not null,
          activated_state integer default 0 not null,
          languages character varying[] default '{}'::character varying[] not null,
          global_email_communication boolean,
          project_email_communication boolean,
          admin boolean default false not null,
          banned boolean default false not null,
          migrated boolean default false,
          valid_email boolean default true not null,
          uploaded_subjects_count integer default 0,
          constraint users_pkey primary key (id)
        );
        
        drop table if exists projects;
        create table projects (
          id serial not null,
          name character varying,
          display_name character varying,
          slug character varying,
          user_count integer,
          created_at timestamp without time zone,
          updated_at timestamp without time zone,
          classifications_count integer default 0 not null,
          activated_state integer default 0 not null,
          primary_language character varying,
          private boolean,
          lock_version integer default 0,
          configuration jsonb,
          approved boolean default false,
          beta boolean default false,
          live boolean default false not null,
          urls jsonb default '[]'::jsonb,
          migrated boolean default false,
          constraint projects_pkey primary key (id)
        );
        
        drop table if exists collections;
        create table collections (
          id serial not null,
          name character varying,
          project_id integer,
          slug character varying,
          created_at timestamp without time zone,
          updated_at timestamp without time zone,
          activated_state integer default 0 not null,
          display_name character varying,
          private boolean,
          lock_version integer default 0,
          constraint collections_pkey primary key (id)
        );
        
        drop table if exists subjects;
        create table subjects (
          id serial not null,
          zooniverse_id character varying,
          metadata jsonb default '{}'::jsonb,
          created_at timestamp without time zone,
          updated_at timestamp without time zone,
          project_id integer,
          migrated boolean,
          lock_version integer default 0,
          upload_user_id character varying,
          constraint subjects_pkey primary key (id)
        );
        
        drop table if exists collection_subjects;
        create table collection_subjects (
          id serial not null,
          subject_id int4 not null,
          collection_id int4 not null,
          constraint collection_subjects_pkey primary key (id)
        );
        
        drop table if exists media;
        create table media (
          id serial not null,
          type character varying,
          linked_id integer,
          linked_type character varying,
          content_type character varying,
          src text,
          path_opts text[] default '{}'::text[],
          private boolean default false,
          external_link boolean default false,
          created_at timestamp without time zone not null,
          updated_at timestamp without time zone not null,
          constraint media_pkey primary key (id)
        );
      SQL
    end
    
    desc 'Loads Panoptes database'
    task :setup => [:setup_fdw, :create_foreign_tables, :create_search_view]
  end
end

namespace :db do
  desc 'Loads development data'
  task :seed_dev => :environment do
    local_environment!
    
    print "This will clear all data in the #{ Rails.env } environment, continue? (y/n): "
    unless STDIN.gets =~ /y/i
      puts 'aborting'
      exit
    end
    
    ActiveRecord::Base.establish_connection talk_config
    Rake::Task['db:resync'].invoke
    load Rails.root.join('db/dev_seeds.rb')
  end
  
  desc 'Reloads and setups the database'
  task :resync => :environment do
    local_environment!
    ActiveRecord::Base.establish_connection talk_config
    ActiveRecord::Base.connection.execute 'drop extension postgres_fdw cascade;'
    Rake::Task['db:schema:load'].invoke
    Rake::Task['panoptes:db:create_tables'].invoke
    Rake::Task['panoptes:db:setup'].invoke
  end
end
