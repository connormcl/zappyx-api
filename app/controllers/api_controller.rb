class ApiController < ApplicationController
  # Environment variables are automatically read, or can be overridden by any specified options. You can also
  # conveniently use `Houston::Client.development` or `Houston::Client.production`.
  APN = Houston::Client.development
  APN.certificate = File.read("/Users/connor/Documents/ios-apps-important-files/pushchat/ck.pem")
  APN.passphrase = "Pau1gibson*"

  def send_image
    # An example of the token sent back when a device registers for notifications
    token = "<190062ee 43d20a01 f9b5abbc 70f4017b 39eeeced c629f562 4b9c4f09 8f0c99f4>"

    # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    notification = Houston::Notification.new(device: token)
    notification.alert = "from Connor McLaughlin"

    # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    notification.badge = 57
    notification.sound = "sosumi.aiff"
    notification.category = "INVITE_CATEGORY"
    notification.content_available = true
    notification.custom_data = {foo: "bar"}

    # And... sent! That's all it takes.
    APN.push(notification)
    redirect_to action: "pushTest"
  end

  def pushTest
  end
end
