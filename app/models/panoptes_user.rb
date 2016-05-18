class PanoptesUser < ActiveRecord::Base
  self.table_name = 'users'
  establish_connection configurations["panoptes_#{ Rails.env }"]
end
