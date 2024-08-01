Rails.application.routes.draw do
  root to: proc { [404, {}, ["Not found."]] }
  get "buscar" => "companies#search"
  match "*path", to: proc { [404, {}, ['Not found.']] }, via: :all
end
