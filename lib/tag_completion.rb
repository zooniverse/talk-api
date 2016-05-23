# Finds similar (trigram) tags
# prioritized by
#   - team suggested
#   - similarity
#   - usage
class TagCompletion
  def initialize(name, section, limit: 10)
    @name = name&.gsub /[^-\w\d]/, ''
    @section = sanitize section
    @limit = limit
  end

  def results
    if @name.present?
      @name = sanitize @name
      connection.execute(query).to_a.map do |tag|
        tag.except 'score'
      end
    else
      connection.execute(suggested_tags).to_a
    end
  end

  # Note:
  # Using `set_limit(n)` and `where name % 'foo'`
  # is about 20% faster than
  # `where similarity(name, 'foo') > n`
  def query
    <<-SQL
      select set_limit(0.1);

      select
        name,
        score

      from
        (#{ unique_matching_tags }) unique_matching_tags

      order by
        score desc,
        name asc

      limit
        #{ @limit }
    SQL
  end

  def unique_matching_tags
    <<-SQL
      select
        distinct on (name)
        name,
        score

      from
        (#{ matching_tags }) matching_tags
    SQL
  end

  def matching_tags
    <<-SQL
      select
        name,
        score

      from
        (#{ matching_suggested_tags }) matching_suggested_tags

      union

      select
        name,
        score

      from
        (#{ popular_matching_tags }) popular_matching_tags

      order by
        score desc
    SQL
  end

  def popular_matching_tags
    <<-SQL
      select
        name,
        similarity(name, #{ @name }) * count(distinct(user_id)) score

      from
        tags

      where
        section = #{ @section } and
        name % #{ @name }

      group by
        section, name

      order by
        score desc
    SQL
  end

  def matching_suggested_tags
    <<-SQL
      select
        name,
        50 score

      from
        suggested_tags

      where
        section = #{ @section } and
        name % #{ @name }

      order by
        score desc
    SQL
  end

  def suggested_tags
    <<-SQL
      select
        name

      from
        suggested_tags

      where
        section = #{ @section }

      order by
        name

      limit
        #{ @limit }
    SQL
  end

  def sanitize(string)
    connection.quote string
  end

  def connection
    ActiveRecord::Base.connection
  end
end
