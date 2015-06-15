namespace :data do
  desc 'changes section format from #{ project.id }-#{ project.name } to project-#{ project.id }'
  task migrate_section: :environment do
    connection = ActiveRecord::Base.connection
    
    connection.execute <<-SQL
      drop view searches;
      drop materialized view searchable_collections;
    SQL
    Rake::Task['panoptes:db:create_search_view'].invoke
    ::Collection.refresh!
    
    tables = %w(
      announcements boards comments discussions moderations notifications roles
      searchable_boards searchable_comments searchable_discussions tags
    )
    
    tables.each do |table|
      puts "updating #{ table }"
      connection.execute <<-SQL
        update #{ table }
        set section = 'project-' || split_part(section, '-', 1)
        where section <> 'zooniverse';
      SQL
    end
  end
end
