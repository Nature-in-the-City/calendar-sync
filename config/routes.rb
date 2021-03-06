Rails.application.routes.draw do
  resource :calendar, only: [:show]
  root 'calendars#show'

  devise_for :users, skip: [:registrations]

  as :user do
    get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    put 'users/:id' => 'devise/registrations#update', as: 'user_registration'
  end

  resources :events do
    get 'suggest', on: :new
    get "events/edit_event_form" => 'events#edit_event_form', :as => :edit_form
    collection do
      get 'search_events', :as => :search
      get 'third_party'
      post 'third_party'
      post 'pull_third_party'
    end
  end
  
  resources :syncs do
    collection do
      get 'update'
      post 'add_calendar'
      delete 'destroy_multiple'
    end
  end
  
  resources :guests, only: [:new, :create]

  resources :accounts
  
  resources :syncs
  
  
end
