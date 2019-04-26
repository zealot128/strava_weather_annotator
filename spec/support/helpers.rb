module OmniauthMock
  def auth_mock
    OmniAuth.config.mock_auth[:twitter] = {
      'provider' => 'twitter',
      'uid' => '123545',
      'user_info' => {
        'name' => 'mockuser'
      },
      'credentials' => {
        'token' => 'mock_token',
        'secret' => 'mock_secret'
      }
    }
  end

  def signin
    visit root_path
    expect(page).to have_content("Sign in")
    auth_mock
    click_link "Sign in"
  end
end

RSpec.configure do |config|
  config.include OmniauthMock
end
OmniAuth.config.test_mode = true
