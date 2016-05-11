namespace :db do
  desc 'Create trigram indexes'
  task :create_trigram_indexes do
    ActiveRecord::Base.establish_connection talk_config
    ActiveRecord::Base.connection.execute <<-SQL
      do language plpgsql $$
        begin
          if (select count(*) from pg_extension where extname = 'pg_trgm') = 0 then
            create extension pg_trgm;
          end if;

          if (select count(*) from pg_class where relname = 'index_tags_name_trgm') = 0 then
            create index index_tags_name_trgm on tags using gin (name gin_trgm_ops);
          end if;
        end;
      $$;
    SQL
  end
end
