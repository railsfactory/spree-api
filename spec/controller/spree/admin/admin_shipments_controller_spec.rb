require 'spec_helper'

describe Spree::Admin::ShipmentsController ,:type => "controller" do
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(Spree::User, stubs).as_null_object
  end
  
  before(:each) do
    controller.stub!(:check_http_authorization).and_return(true)

    request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
    @current_user = 1
  end

  describe "GET index" do
    it "user To list OptionTypes units" do
      p @user = Spree::User.create(:email => 'sedin@railsfactory.org' , :password => '123456' , :password_confirmation => '123456')
      @auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
      @user.save
      p @order = Spree::Order.create(:email=>@user.email)
      @order.stub(:completed? => true)
      p current_order = Spree::Order.find_by_number(@order.number)
      #~ p	shipping_method = Spree::ShippingMethod.create( :name => "Shipping Method" , :zone_id => 1 , :display_on => "display")
      #~ @shipments = @shipping_method.shipments.build(:name => "Shipment" , :order_id => @order.id , :address_id => 1 , :number => "R23232")
      #~ get :index, :format=>:json
      response.code.should == "200"
    end
    it "user To list OptionTypes units with wrong value" do
      @user = Spree::User.create(:email => 'sedin@railsfactory.org' , :password => '123456' , :password_confirmation => '123456')
      @auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
      @user.save
      @order = Spree::Order.create(:email=>@user.email)
      @order.stub(:completed? => true)
      current_order = Spree::Order.find_by_number(20)
      response.code.should == "200"
    end
  end
  
  describe "GET Fire" do
    it "To fire the shipment" do
      @user=Spree::User.create(:email => "email@person.com", :password => "secret", :password_confirmation => "secret")
      @auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
      @user.save
      @order=Spree::Order.create(:email=>@user.email)
      p @order
      p @shipping_method = Spree::ShippingMethod.create(:name => "Shipping Method", :display_on =>"display")
      get :fire, {:id=>@order.id, :e=>"capture", :id=>@shipping_method.id, :format=> :json}
      response.code.should == "200"
    end
  end
  
end
