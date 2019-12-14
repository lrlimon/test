Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # resources :labels, only: [:detail, :report]
  get 'labels/report', to: 'labels#report', as: :labels_report
  get 'labels/detail', to: 'labels#detail', as: :labels_detail

  root 'labels#detail'

end
