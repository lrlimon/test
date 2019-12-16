Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'labels/report', to: 'labels#report', as: :labels_report
  get 'labels/input', to: 'labels#input', as: :labels_input

  root 'labels#input'

end
