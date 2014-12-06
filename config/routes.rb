Rails.application.routes.draw do
  root 'welcome#index'
  post 'grab_url' => 'welcome#grub_url', as: :grub_url
end
