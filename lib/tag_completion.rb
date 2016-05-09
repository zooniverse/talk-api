# Finds similar (trigram) tags
# prioritized by similarity and usage
class TagCompletion
  def initialize(name, section, limit: 10)
    @name = name&.gsub /[^-\w\d]/, ''
    @section = sanitize section
    @limit = limit
  end

  def results
    return [] unless @name.present?
    @name = sanitize @name
    connection.execute(query).to_a
  end

  # Note:
  # Using `set_limit(n)` and `where name % 'foo'`
  # is about 20% faster than
  # `where similarity(name, 'foo') > n`
  def query
    <<-SQL
      select set_limit(0.01);

      select
        name

      from tags

      where
        section = #{ @section } and
        name % #{ @name }

      group by
        section, name

      order by
        similarity(name, #{ @name }) * count(distinct(user_id)) desc

      limit #{ @limit }
    SQL
  end

  def sanitize(string)
    connection.quote string
  end

  def connection
    ActiveRecord::Base.connection
  end
end
