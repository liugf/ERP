# -*- encoding : utf-8 -*-
class Dict::BillTypesController < Dict::DictsController
  def model
    Dict::BillType  
  end
  
  def symbol    
    :dict_bill_type
  end
end
