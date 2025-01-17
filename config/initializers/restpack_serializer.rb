# preload autoloaded serializers after database has been loaded
db_loaded = ::ActiveRecord::Base.connection_pool.with_connection(&:active?) rescue false

if db_loaded
  Dir[Rails.root.join('app/serializers/**/*.rb')].sort.each do |path|
    name = path.match(/serializers\/(.+)\.rb$/)[1]
    name.classify.constantize unless path =~ /serializers\/concerns/
  end
end