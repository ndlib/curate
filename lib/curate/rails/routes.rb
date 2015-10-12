module ActionDispatch::Routing

  class Mapper
    extend Deprecation

    def curate_for opts=nil
      Deprecation.warn Mapper, "curate_for no longer accepts any arguments. You provided: #{opts.inspect}" if opts
      mount BrowseEverything::Engine => '/remote_files/browse'
      scope module: 'curate' do
        resources 'collections', 'profiles', 'profile_sections', controller: 'collections' do
          collection do
            get :add_member_form
            put :add_member
            put :remove_member
          end
        end
        resources 'people', only: [:show, :index] do
          resources :depositors, only: [:index, :create, :destroy]
        end
        match 'profile' => 'user_profiles#show', via: :get, as: 'user_profile'
      end
      #resources :downloads, only: [:show]

      match 'collections' => 'collections#index', via: :get, as: 'curation_concern_collections'
      get 'collection/:id', to: redirect('collections/%{id}')
      match 'collections/:id' => 'collections#show', via: :get, as: 'curation_concern_collection'
      match 'people/:id' => 'people#show', via: :get, as: 'curation_concern_person'
      match 'people' => 'people#index', via: :get, as: 'curation_concern_people'

      namespace :curation_concern, path: :concern do
        Curate.configuration.registered_curation_concern_types.map(&:tableize).each do |container|
          resources container, except: [:index]
        end
        resources( :permissions, only:[]) do
          member do
            get :confirm
            post :copy
          end
        end
        resources( :linked_resources, only: [:new, :create], path: 'container/:parent_id/linked_resources')
        resources( :linked_resources, only: [:show, :edit, :update, :destroy])
        resources( :generic_files, only: [:new, :create], path: 'container/:parent_id/generic_files')
        resources( :generic_files, only: [:show, :edit, :update, :destroy]) do
          member do
            get :versions
            put :rollback
          end
        end
      end

      resources :terms_of_service_agreements, only: [:new, :create]
      resources :help_requests, only: [:new, :create]
      resources :classify_concerns, only: [:new, :create]
      resources :etd_vocabularies

      match "etd_vocabularies/type/:type" => "etd_vocabularies#index", via: :get, as: "etd_vocabularies_by_type"
      match "show/:id" => "common_objects#show", via: :get, as: "common_object"
      match "show/stub/:id" => "common_objects#show_stub_information", via: :get, as: "common_object_stub_information"
      match 'users/:id/edit' => 'users#edit', via: :get, as: 'edit_user'
      match 'downloads/:id(/:datastream_id)(.:format)' => 'downloads#show', via: :get, as: 'download'

      #scope module: 'hydramata' do
      namespace :hydramata do
        resources 'groups'
      end
      resource :repo_manager, only: [:edit, :update]
    end
  end
end
