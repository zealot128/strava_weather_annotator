class SignedInController < ApplicationController
  before_action :authenticate_user!
end
