require 'spec_helper'

RSpec.describe CommentExportWorker, type: :worker do
  it_behaves_like 'a data export worker'
end
