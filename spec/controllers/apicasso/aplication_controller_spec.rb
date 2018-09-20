require 'rails_helper'

RSpec.describe Apicasso::ApplicationController, type: :controller do

  describe "#current_ability" do
    it "instantiates a @current_ability object" do
      Apicasso::ApplicationController.current_ability
      expect(@current_ability).not_to be nil
    end
  end

  describe "#restrict_access" do
    it "instantiates an @api_key object" do
      Apicasso::ApplicationController.current_ability
      expect(@api_key).not_to be nil
    end
  end
end
