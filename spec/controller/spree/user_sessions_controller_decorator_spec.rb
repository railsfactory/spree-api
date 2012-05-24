require 'spec_helper' 

describe   Spree::UserSessionsController,:type=>"controller" do
  #include Devise::TestHelpers
  describe " UserSessionsController" do
    let(:user) { build(:user) }
    def mock_user(stubs={})
      @mock_user ||= mock_model(Spree::User, stubs).as_null_object
    end
    before(:each) do
      
      request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
      
      @current_user = 1
    end
    it "should be successful" do
      post :create,{:user=>{:email=>"spree@example.com", :password=>"1234564"}},:format=>:json
      response.code.should == "200"
    end
    it "it should destroy the user" do
      get :destroy, {:authentication_token=>""}, :format => :json
    end
  end
end
