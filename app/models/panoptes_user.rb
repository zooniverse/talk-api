class PanoptesUser < ApplicationRecord
  self.table_name = 'users'
  establish_connection configurations.configs_for(env_name: "panoptes_#{Rails.env}")[0].configuration_hash
end
