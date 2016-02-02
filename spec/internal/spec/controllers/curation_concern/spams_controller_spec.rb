# Generated via
#  `rails generate curate:work Spam`
require 'spec_helper'

describe CurationConcern::SpamsController do
  it_behaves_like 'is_a_curation_concern_controller', Spam, actions: :all
end
