class PanoptesUser < ApplicationRecord
  self.table_name = 'users'
  establish_connection configurations["panoptes_#{ Rails.env }"]
end
