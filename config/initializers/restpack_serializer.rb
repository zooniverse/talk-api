# preload autoloaded serializers
Dir[Rails.root.join('app/serializers/**/*.rb')].sort.each do |path|
  name = path.match(/serializers\/(.+)\.rb$/)[1]
  name.classify.constantize unless path =~ /serializers\/concerns/
end
