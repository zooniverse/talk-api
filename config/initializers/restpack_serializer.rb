# preload autoloaded serializers after database has been loaded
# See: https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots

Rails.application.config.to_prepare do
  db_loaded = ::ActiveRecord::Base.connection_pool.with_connection(&:active?) rescue false

  if db_loaded
    Dir[Rails.root.join('app/serializers/**/*.rb')].sort.each do |path|
      name = path.match(/serializers\/(.+)\.rb$/)[1]
      name.classify.constantize unless path =~ /serializers\/concerns/
    end
  end
end
