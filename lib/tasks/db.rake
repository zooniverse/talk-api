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
        
        create foreign table if not exists panoptes_users (
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
    
    desc 'Creates the search view'
    task :create_search_view do
      ActiveRecord::Base.connection.execute <<-SQL
        do language plpgsql $$
          begin
            if (select count(*) from pg_matviews where matviewname = 'searches') = 0 then
              create materialized view searches as
                select
                  boards.id as searchable_id,
                  'Board' as searchable_type,
                  
                  boards.title || ' ' ||
                  boards.description
                  as content,
                  
                  '' as tags,
                  boards.section as section
                from boards
                where boards.permissions ->> 'read' = 'all'
              
              union
                
                select
                  discussions.id as searchable_id,
                  'Discussion' as searchable_type,
                  
                  discussions.title
                  as content,
                  
                  '' as tags,
                  discussions.section as section
                from discussions
                  join boards on boards.id = discussions.board_id
                where boards.permissions ->> 'read' = 'all'
              
              union
                
                select
                  comments.id as searchable_id,
                  'Comment' as searchable_type,
                  
                  comments.body || ' ' ||
                  string_agg(panoptes_users.login, '') || ' ' ||
                  string_agg(panoptes_users.display_name, '')
                  as content,
                  
                  coalesce(string_agg(tags.name, ' '), '') as tags,
                  comments.section as section
                from comments
                  left join tags on tags.comment_id = comments.id
                  join discussions on discussions.id = comments.discussion_id
                  join boards on boards.id = discussions.board_id
                  join panoptes_users on panoptes_users.id = comments.user_id
                where
                  boards.permissions ->> 'read' = 'all'
                group by
                  comments.id
              
              union
                
                select
                  collections.id as searchable_id,
                  'Collection' as searchable_type,
                  
                  string_agg(collections.name, '') || ' ' ||
                  coalesce(string_agg(collections.display_name, ''), '')  || ' ' ||
                  'C' || string_agg(collections.id::text, '')
                  as content,
                  
                  coalesce(string_agg(tags.name, ' '), '') as tags,
                  string_agg(projects.id || '-' || projects.name, '') as section
                from collections
                  left join tags on tags.taggable_id = collections.id and tags.taggable_type = 'Collection'
                  join projects on projects.id = collections.project_id
                where
                  collections.private is not true and projects.private is not true
                group by
                  collections.id
              
              union
                
                select
                  subjects.id as searchable_id,
                  'Subject' as searchable_type,
                  
                  string_agg(subjects.id::text, '') || ' ' ||
                  'S' || string_agg(subjects.id::text, '')
                  as content,
                  
                  coalesce(string_agg(tags.name, ' '), '') as tags,
                  string_agg(projects.id || '-' || projects.name, '') as section
                from subjects
                  join tags on tags.taggable_id = subjects.id and tags.taggable_type = 'Collection'
                  join projects on projects.id = subjects.project_id
                where
                  projects.private is not true
                group by
                  subjects.id;
              
              create index search_index on searches using gin(
                setweight(to_tsvector('english', tags), 'A'),
                setweight(to_tsvector('english', content), 'B')
              );
              
              create index search_section_index on searches using btree(section);
            end if;
          end;
        $$;
      SQL
    end
    
    desc 'Loads Panoptes database'
    task :setup => [:setup_fdw, :create_foreign_tables, :create_search_view]
  end
end
