class ClarkKent::ApplicationController < ClarkKent.base_controller

  def clark_kent_user
    @clark_kent_user ||= send ClarkKent.current_user_method
  end

  helper_method :clark_kent_user
end
