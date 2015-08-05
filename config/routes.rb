Rails.application.routes.draw do
  # root
  root 'api#index'

  # unprotected routes
  get 'api/index'
  post 'api/signup' => 'auth#signup'
  post 'api/auth' => 'auth#authenticate'

  # protected routes
  get 'api/unopened_photos'
  get 'api/get_photo'
  get 'api/get_users'
  post 'api/send_photo'
  post 'api/delete_account' => 'auth#delete_user'
end
