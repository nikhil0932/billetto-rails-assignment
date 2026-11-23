require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'helper methods are properly declared' do
    it 'declares current_user as a helper method' do
      expect(ApplicationController._helper_methods).to include(:current_user)
    end

    it 'declares user_signed_in? as a helper method' do
      expect(ApplicationController._helper_methods).to include(:user_signed_in?)
    end
  end

  describe 'private authentication methods exist' do
    it 'has authenticate_user! private method' do
      expect(ApplicationController.private_instance_methods).to include(:authenticate_user!)
    end

    it 'has current_user private method' do
      expect(ApplicationController.private_instance_methods).to include(:current_user)
    end

    it 'has user_signed_in? private method' do
      expect(ApplicationController.private_instance_methods).to include(:user_signed_in?)
    end

    it 'has clerk_user_id private method' do
      expect(ApplicationController.private_instance_methods).to include(:clerk_user_id)
    end
  end
end




