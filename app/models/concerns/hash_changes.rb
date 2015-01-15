module HashChanges
  extend ActiveSupport::Concern
  
  def added_to(key)
    changes_for(key) do |was, is|
      is.dup.reject{ |key, val| was.has_key? key }
    end
  end
  
  def removed_from(key)
    changes_for(key) do |was, is|
      was.dup.reject{ |key, val| is.has_key? key }
    end
  end
  
  protected
  
  def changes_for(key)
    return { } unless changes[key]
    yield *changes[key]
  end
end
