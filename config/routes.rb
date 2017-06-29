Wedding::Application.routes.draw do
  get '/invite/:inviteid.php' => 'main#invite', :as => :showinvite
  post '/invite/:inviteid/approve.php' => 'main#approve', :as => :approve
  root 'main#index'
end
