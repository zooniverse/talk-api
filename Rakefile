require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

# In Rails 5.2 the `load_config` task was made dependent on `environment`
# to enable credentials reading, see https://github.com/rails/rails/pull/31135
# This causes the whole app to initialize before `db:create` and that
# causes a database connection for observers, sphinx, concerns, etc, that cant be established
# when DB does not exist yet.
# See SO: https://stackoverflow.com/questions/72147515/rails-5-2-load-order-breaks-dbcreate
# While clearing the environment prerequisite of load_config will help db:create
# and create the db, other tasks like db:schema:load and our panoptes talk rake tasks
# will actually need the prereq, and therefore we bring back the environment prereq
# for other rake tasks. We do this to keep our CI test workflows and local dev environment setup functional.

Rake::Task['db:load_config'].prerequisites.delete("environment")
Rake::Task.tasks.select { |task|
  next if task.name == "db:create"
  task.name.start_with?("db:") && task.prerequisites.include?("load_config")
}.each { |task|
  task.prerequisites.insert(task.prerequisites.index("load_config"), "environment")
}
Rake::Task.tasks.select { |task|
    task.prerequisites.include?("db:load_config")
}.each { |task|
  task.prerequisites.insert(task.prerequisites.index("db:load_config"), "environment")
}