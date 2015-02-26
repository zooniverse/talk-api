class CreateSearch < ActiveRecord::Migration
  def up
    execute <<-SQL
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
          subjects.id
    SQL
  end
  
  def down
    execute 'drop materialized view searches;'
  end
end
