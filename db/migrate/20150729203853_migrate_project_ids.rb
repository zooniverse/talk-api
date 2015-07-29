class MigrateProjectIds < ActiveRecord::Migration
  def up
    execute <<-SQL
      update announcements set project_id = substring(section from 'project-(\\d+)')::int;
      update boards set project_id = substring(section from 'project-(\\d+)')::int;
      update comments set project_id = substring(section from 'project-(\\d+)')::int;
      update discussions set project_id = substring(section from 'project-(\\d+)')::int;
      update notifications set project_id = substring(section from 'project-(\\d+)')::int;
      update tags set project_id = substring(section from 'project-(\\d+)')::int;
    SQL
  end
  
  def down
    
  end
end
