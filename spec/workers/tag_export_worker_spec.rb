require 'spec_helper'

RSpec.describe TagExportWorker, type: :worker do
  it_behaves_like 'a data export worker'
end
