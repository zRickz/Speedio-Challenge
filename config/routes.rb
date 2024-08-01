Rails.application.routes.draw do
  root to: proc { [404, {}, ["Not found."]] }
  get "buscar" => "companies#search"
end
