require 'spec_helper'

RSpec.describe RepoManager do
  it { expect(described_class.usernames).to be_a(Enumerable) }
end
