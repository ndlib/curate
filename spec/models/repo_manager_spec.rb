require 'spec_helper'

RSpec.describe RepoManager do
  describe 'activity' do

    describe 'should be findable by user and' do
      let!(:active_repo_manager_user) { FactoryGirl.create(:user) }
      let!(:active_repo_manager) { FactoryGirl.create(:active_repo_manager, username: active_repo_manager_user.user_key) }

      it 'will return an object with #with_active_privileges' do
        expect(described_class.with_active_privileges(active_repo_manager_user)).to eq(active_repo_manager)
      end

      it 'will return a boolean with #with_active_privileges?' do
        expect(described_class.with_active_privileges?(active_repo_manager_user)).to be_truthy
      end
    end

    describe 'should be findable by username and' do
      let!(:active_repo_manager) { FactoryGirl.create(:active_repo_manager) }

      it 'will return an object with #with_active_privileges' do
        expect(described_class.with_active_privileges('ndlib')).to eq(active_repo_manager)
      end

      it 'will return a boolean with #with_active_privileges?' do
        expect(described_class.with_active_privileges?('ndlib')).to be_truthy
      end
    end
  end

  describe 'inactivity' do
    let(:inactive_repo_manager) { FactoryGirl.create(:inactive_repo_manager) }

    it 'should not be reported as active' do
      expect(described_class.with_active_privileges('inactive-ndlib')).to be_nil
      expect(described_class.with_active_privileges?('inactive-ndlib')).to be_falsy
    end
  end

  describe 'when nil' do
    it 'should not respond as active' do
      expect(described_class.with_active_privileges(nil)).to be_falsy
      expect(described_class.with_active_privileges?(nil)).to be_falsy
    end
  end

  describe 'usernames' do
    it { expect(described_class.usernames).to be_a(Enumerable) }
  end
end
