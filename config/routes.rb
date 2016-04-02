# -*- encoding : utf-8 -*-
ERP::Application.routes.draw do



  resources :check_methods

  resources :enterprise_fees do
    get 'search', :on => :collection
  end


  resources :app_bill_dispatch_records

  resources :bill_cargos

  get "bill/print_bill"

  resources :bills do
    get 'print_bill', :on => :member
    get 'declare', :on => :member
    get 'sign', :on => :member
  end

  resources :application_cargos

  resources :applications  do
    get 'print_application', :on => :member
    get 'declare', :on => :member
    get 'sign', :on => :member
  end

  namespace :dict do resources :transit_types end

  resources :declaration_packings
  resources :declaration_containers

  resources :messages do 
    get 'unread', :on => :collection
    post 'read', :on => :member
    get 'search', :on => :collection
  end

  resources :declaration_cargos

  resources :declarations do 
    get 'search', :on => :collection
    get 'declare', :on => :member
    get 'copy', :on => :member
    get 'dispatch_record', :on => :member
    get 'driver_paper', :on => :collection
    get 'print_driver_paper_1', :on => :collection
    get 'print_driver_paper_2', :on => :collection
    get 'print_declarations', :on => :collection
    get 'print_statistic', :on => :collection
    get 'print_declaration', :on => :member
    get 'print_contract', :on => :member
    get 'print_contract2', :on => :member
    get 'print_tax_invoice', :on => :member
    get 'print_invoice', :on => :member
    get 'print_normal', :on => :member
    get 'print_packing1', :on => :member
    get 'print_packing2', :on => :member
    get 'print_packing3', :on => :member
    get 'print_attorney', :on => :member
    get 'manage', :on => :collection
    post 'toggle', :on => :collection
    get 'statistic', :on => :collection
    get 'balance', :on => :collection
    get 'print_material_balance', :on => :collection
    get 'statistic_pro_mat_con', :on => :collection
    get 'weight', :on => :collection
    get 'print_weight', :on => :collection
    get 'statistics', :on => :collection
    get 'print_declaration_statistic', :on => :collection
    get 'details1', :on => :collection
    get 'details2', :on => :collection
    get 'details3', :on => :collection
    get 'materials', :on => :collection
    get 'products', :on => :collection
    get 'print_materials', :on => :collection
    get 'print_products', :on => :collection
    get 'print_details1', :on => :collection
    get 'print_details2', :on => :collection
    get 'print_details3', :on => :collection
    get 'source', :on => :collection
    get 'print_source', :on => :collection
  end

  resources :cargos do
    get 'search', :on => :collection
    get 'print_cargos', :on => :collection
  end

  resources :contract_consumptions

  resources :contract_materials do
    get 'search', :on => :collection
  end

  resources :contract_products do
    get 'search', :on => :collection
  end

  resources :contracts do
    get 'print_contract', :on => :member
    get 'import', :on => :collection
    post 'upload', :on => :collection
  end

  resources :manage_relationships

  match '/options', :to => 'options#index'
  match '/options/update', :to => 'options#update'

  resources :sessions, :only => [:new, :create, :destroy]
  match '/signin', :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'
  
  match '/me', :to => 'users#me'
  match '/me/modify', :to => 'users#modify'
  match '/me/change', :to => 'users#change'
  match '/me/enterprises', :to => 'users#my_enterprises'  
  match '/select_enterprise', :to => 'pages#select_enterprise'  
  match '/barcode', :to => 'pages#barcode'
  

  resources :users do
    get 'search', :on => :collection
    get 'enterprises', :on => :member
  end
  
  resources :enterprises, :foreign_enterprises do
    get 'search', :on => :collection
    get 'show_by_code', :on => :member
    get 'contracts_array', :on => :member
  end
  
  match '/dict', :to => 'pages#dict'  
  namespace :dict do
    resources :attachments,
              :brackets,
              :bring_in_modes,
              :containers,
              :countries,
              :currencies,
              :customs,
              :deal_modes,
              :declare_modes,
              :districts,
              :goods,
              :investment_modes,
              :load_ports,
              :metal_cabinets,
              :pay_ways,
              :ports,
              :process_types,
              :receipt_statuses,
              :tax_kinds,
              :tax_modes,
              :trade_modes,
              :transport_modes,
              :trucks,
              :units,
              :usages,
              :transit_types,
              :transit_declaration_types,
              :wrap_types,
              :fees do
      get 'search', :on => :collection
      get 'show_by_code', :on => :member
    end
  end


  resources :checkout_enterprises

  resources :finance_fees

  resources :finances do
    get 'pay', :on => :collection
    get 'search', :on => :collection
    get 'search2', :on => :collection
    get 'multisearch2', :on => :collection
    get 'search3', :on => :collection
    post 'combine', :on => :collection
    post 'uncombine', :on => :collection
    get 'print', :on => :collection
    get 'print2', :on => :collection
    get 'check', :on => :collection
    get 'income', :on => :collection
    get 'cancel', :on => :member
    get 'make', :on => :member
    get 'review', :on => :member
  end

  root :to => 'pages#home'
end
