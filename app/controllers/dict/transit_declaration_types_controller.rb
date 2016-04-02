# -*- encoding : utf-8 -*-
class Dict::TransitDeclarationTypesController < Dict::DictsController
  def model
    Dict::TransitDeclarationType  
  end
  
  def symbol    
    :dict_transit_declaration_type
  end
end
