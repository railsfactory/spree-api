require 'spec_helper' 

describe   Spree::CheckoutController,:type=>"controller" do
  #include Devise::TestHelpers
  describe " CheckoutController" do
    let(:user) { build(:user) }
    def mock_user(stubs={})
      @mock_user ||= mock_model(Spree::User, stubs).as_null_object
    end
    before(:each) do
      @user=Spree::User.create(:email => "email@person.com", :password => "secret", :password_confirmation => "secret")
      @auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
      @user.save
      @order=Spree::Order.create(:email=>@user.email)
      request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
      
      @current_user = 1
    end
    it "should get before_filter" do
      controller.stub!(:check_http_authorization).and_return(true)
    end
    it "should be successful" do
      put :update,:order=>{:bill_address_attributes=>{:firstname=>"ram", :lastname=>"d", :address1=>"123 west street ", :address2=>"", :city=>"los angles", :country_id=>"214", :state_id=>"969722173", :zipcode=>"10001", :phone=>"7884516642"}, :use_billing=>"1"},:format=>:json
      response.code.should == "200"
    end
    it "should be successful for shipment" do
      put :update,:order=>{:shipping_method_id=>"574015644"},:format=>:json
      response.code.should == "200"
    end
    #~ it "should be successful for payment" do
    #~ put :update,:order=>{{:payments_attributes=>[{:payment_method_id=>"732545999"}]}, :payment_source=>{:193416319=>{:number=>"", :month=>"5", :year=>"2012", :verification_value=>"", :first_name=>"ram", :last_name=>"d"}}},:format=>:json
    #~ response.code.should == "302"
    #~ end
  end
end
