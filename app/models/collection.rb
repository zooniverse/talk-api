class Collection < ActiveRecord::Base
  include Focusable
  include Searchable::Querying
  
  class_attribute :searchable_klass
  self.searchable_klass = SearchableCollection
  
  moderatable_with :destroy, by: [:moderator, :admin]
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
  moderatable_with :watch, by: [:moderator, :admin]
  
  def self.refresh!
    connection.execute 'refresh materialized view concurrently searchable_collections;'
  end
  
  def projects
    Project.where id: project_ids
  end
end
