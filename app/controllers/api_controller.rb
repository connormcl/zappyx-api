class ApiController < ApplicationController
  # Environment variables are automatically read, or can be overridden by any specified options. You can also
  # conveniently use `Houston::Client.development` or `Houston::Client.production`.
  APN = Houston::Client.development
  APN.certificate = File.read(Rails.root.join('app', 'assets', ENV["apn_certificate_name"]))
  APN.passphrase = ENV["apn_passphrase"]

  def send_photo
    if params[:photo] == nil
      render json: { error: 'no photo attached' }
      return
    end
    if params[:recipient_id] == nil
      render json: { error: 'no recipient specified' }
      return
    end
    uploads = "#{Rails.root}/public/uploads"
    FileUtils.mkdir_p(uploads) unless File.directory?(uploads)

    uploaded_io = params[:photo]
    photo = Photo.create({sender_id: @current_user.id, recipient_id: params[:recipient_id], content_type: uploaded_io.content_type})
    extension = "." + photo.content_type.split("/").last
    photo.update_attributes({path: Rails.root.join('public','uploads',photo.id.to_s + extension), filename: photo.id.to_s + extension})
    File.open(Rails.root.join('public', 'uploads', photo.path), 'wb') do |file|
      file.write(uploaded_io.read)
    end

    recipient = User.find(photo.recipient_id)
    recipient.unopened_photos << photo.id
    recipient.save

    # The token sent back when a device registers for notifications
    device_token = recipient.device_token

    # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    notification = Houston::Notification.new(device: device_token)
    notification.alert = "from " + @current_user.first_name + " " + @current_user.last_name

    # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    notification.badge = 1
    notification.sound = "sosumi.aiff"
    notification.category = "INVITE_CATEGORY"
    notification.content_available = true
    # notification.custom_data = {foo: "bar"}

    APN.push(notification)
    render json: { sent: 'true' }
  end

  def unopened_photos
    render json: { unopened_photos: @current_user.unopened_photos }
  end

  def load_photo
    if params[:photo_id] == nil
      render json: { error: 'no photo id provided' }
      return
    end

    if !@current_user.unopened_photos.include? params[:photo_id]
      render json: { error: 'requested photo not found'}
      return
    end

    photo = Photo.find(params[:photo_id])
    send_file photo.path, :type => photo.content_type, :disposition => 'inline'
  end

  def index
  end
end
