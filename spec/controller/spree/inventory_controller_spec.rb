require 'spec_helper'
describe Spree::InventoryUnitsController ,:type=>"controller" do
  def mock_user(stubs={})
    @mock_user ||= mock_model(Spree::User, stubs).as_null_object
  end
  
  before(:each) do
    controller.stub!(:check_http_authorization).and_return(true)

    request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
    @current_user = 1
  end
  it "should get before_filtered for authenticate_user!" do
    controller.stub!(:check_http_authorization).and_return(true)
  end
  
  before(:each) do
    #~ @inventory=Spree::InventoryUnits.create(:lock_version=>1,:state=>"Completed", :variant_id=>2,:order_id=>1, :shipment_id=>3)
    @user=Spree::User.create(:email=>"sedin@railsfactory.org",:password=>"123456")
    Spree::User.current = @user
  end
  
  describe "GET index" do
    it "user To list inventory units" do
      get :index, :format=>:json
      response.code.should == "200"
    end
  end
  
  describe "GET show" do
    it "user To display particular items" do
      get :show,{:id=>20}, :format=>:json
      response.should be_success
    end
  end
  
end
