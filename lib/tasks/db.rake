def panoptes_config
  @panoptes_config ||= db_config("panoptes_#{ Rails.env }")
end

def talk_config
  @talk_config ||= db_config(Rails.env)
end

def db_config(key)
  config = Rails.configuration.database_configuration[key]
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
          private bool,
          launch_approved bool,
          launched_row_order int4
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

        create foreign table if not exists oauth_access_tokens (
          id int4,
          resource_owner_id int4,
          application_id int4,
          token text,
          refresh_token varchar(255),
          expires_in int4,
          revoked_at timestamp(6),
          created_at timestamp(6),
          scopes varchar
        ) server panoptes;
      SQL
    end

    desc 'Drops Panoptes foreign tables'
    task :drop_foreign_tables => :environment do
      Rake::Task['panoptes:db:drop_search_view'].invoke
      ActiveRecord::Base.establish_connection talk_config
      ActiveRecord::Base.connection.execute <<-SQL
        drop foreign table if exists projects, oauth_access_tokens, subjects, users;
      SQL
    end

    desc 'Recreates Panoptes foreign tables'
    task :recreate_foreign_tables => [:drop_foreign_tables, :create_foreign_tables, :create_search_view, :create_popular_tags_view]

    desc 'Creates the search view'
    task :drop_search_view => :environment do
      ActiveRecord::Base.establish_connection talk_config
      ActiveRecord::Base.connection.execute <<-SQL
        drop view if exists searches;
      SQL
    end

    desc 'Creates the search view'
    task :create_search_view => :environment do
      ActiveRecord::Base.establish_connection talk_config
      ActiveRecord::Base.connection.execute <<-SQL
        do language plpgsql $$
          begin
            create or replace view searches as
              select * from searchable_boards
              union all
              select * from searchable_comments
              union all
              select * from searchable_discussions;
          end;
        $$;
      SQL
    end

    desc 'Creates the popular tags view'
    task :create_popular_tags_view => :environment do
      ActiveRecord::Base.establish_connection talk_config

      # Unique tags for a section ordered by usages
      ActiveRecord::Base.connection.execute <<-SQL
        create or replace view popular_section_tags as
          select
            name || '-' || section as id,
            name,
            count(name) as usages,
            section,
            project_id
          from tags
          group by section, project_id, name
          order by usages desc, id asc
      SQL

      # Tags for a focus ordered by usages
      ActiveRecord::Base.connection.execute <<-SQL
        create or replace view popular_focus_tags as
          select
            name || '-' || taggable_id || '-' || taggable_type || '-' || section as id,
            name,
            count(name) as usages,
            taggable_type,
            taggable_id,
            section,
            project_id
          from tags
          where taggable_type is not null
          group by section, project_id, taggable_type, taggable_id, name
          order by usages desc, taggable_id asc
      SQL
    end

    desc 'Create Panoptes tables for testing'
    task :create_tables => :environment do
      local_environment!

      ActiveRecord::Base.establish_connection talk_config
      ActiveRecord::Base.connection.execute <<-SQL
        drop sequence if exists users_id_seq;
        create sequence users_id_seq start with 1 increment by 1 no minvalue no maxvalue cache 1;

        drop sequence if exists oauth_access_tokens_id_seq;
        create sequence oauth_access_tokens_id_seq start with 1 increment by 1 no minvalue no maxvalue cache 1;

        drop sequence if exists projects_id_seq;
        create sequence projects_id_seq start with 1 increment by 1 no minvalue no maxvalue cache 1;

        drop sequence if exists subjects_id_seq;
        create sequence subjects_id_seq start with 1 increment by 1 no minvalue no maxvalue cache 1;
      SQL

      ActiveRecord::Base.establish_connection panoptes_config
      ActiveRecord::Base.connection.execute <<-SQL
        do language plpgsql $$
          begin
            if (select count(*) from pg_extension where extname = 'pg_trgm') = 0 then
              create extension pg_trgm;
            end if;
          end;
        $$;
      SQL

      ActiveRecord::Base.connection.execute <<-SQL
        drop table if exists users;
        drop sequence if exists users_id_seq;
        create sequence users_id_seq start with 1 increment by 1 no minvalue no maxvalue cache 1;
        create table users (
          id integer primary key default nextval('users_id_seq'),
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
          uploaded_subjects_count integer default 0
        );

        drop table if exists oauth_access_tokens;
        drop sequence if exists oauth_access_tokens_id_seq;
        create sequence oauth_access_tokens_id_seq start with 1 increment by 1 no minvalue no maxvalue cache 1;
        create table oauth_access_tokens (
          id integer primary key default nextval('oauth_access_tokens_id_seq'),
          resource_owner_id int4 default null,
          application_id int4 default null,
          token text not null default null,
          refresh_token varchar default null,
          expires_in int4 default null,
          revoked_at timestamp(6) null default null,
          created_at timestamp(6) not null default null,
          scopes varchar default null
        );

        drop table if exists projects;
        drop sequence if exists projects_id_seq;
        create sequence projects_id_seq start with 1 increment by 1 no minvalue no maxvalue cache 1;
        create table projects (
          id integer primary key default nextval('projects_id_seq'),
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
          launch_approved boolean default false,
          launched_row_order integer,
          beta boolean default false,
          live boolean default false not null,
          urls jsonb default '[]'::jsonb,
          migrated boolean default false
        );

        drop table if exists subjects;
        drop sequence if exists subjects_id_seq;
        create sequence subjects_id_seq start with 1 increment by 1 no minvalue no maxvalue cache 1;
        create table subjects (
          id integer primary key default nextval('subjects_id_seq'),
          zooniverse_id character varying,
          metadata jsonb default '{}'::jsonb,
          created_at timestamp without time zone,
          updated_at timestamp without time zone,
          project_id integer,
          migrated boolean,
          lock_version integer default 0,
          upload_user_id character varying
        );
      SQL
    end

    desc 'Loads Panoptes database'
    task :setup => [:setup_fdw, :create_foreign_tables, :create_search_view, :create_popular_tags_view]
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
