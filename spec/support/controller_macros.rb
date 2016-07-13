module ControllerMacros
  def sign_in_user(usr = nil)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = usr.nil? ? FactoryGirl.create(:user) : usr
      sign_in user
    end
  end

  def sign_in_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      admin = FactoryGirl.create(:admin)
      sign_in admin
    end
  end
end