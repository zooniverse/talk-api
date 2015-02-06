module HstoreUpdate
  extend ActiveSupport::Concern
  
  protected
  
  def hstore_concat(column, key_pairs)
    hstore_update column, "|| hstore(#{ hstore_escape key_pairs })"
  end
  
  def hstore_delete_key(column, key)
    hstore_update column, "- #{ hstore_sanitize key }::text"
  end
  
  def hstore_update(column, updater)
    updater = "#{ column } = #{ column } #{ updater }"
    self.class.where(id: id).update_all updater
    reload
  end
  
  def hstore_sanitize(string)
    self.class.sanitize string.to_s.gsub /["'=>\(\)]/, ''
  end
  
  def hstore_escape(key_pairs)
    key_pairs.collect do |pair|
      pair.collect{ |item| hstore_sanitize item }.join ', '
    end.join ', '
  end
end
