# -*- encoding : utf-8 -*-
class Contract < ActiveRecord::Base
  belongs_to :enterprise
  has_many :contract_products, :dependent => :destroy
  has_many :contract_materials, :dependent => :destroy
  validates :enterprise_id, :presence => true, :numericality => true
  validates :operate_enterprise_code, :presence => true
  validates :trade_mode, :presence => true
  validates :manual, :presence => true, :uniqueness => true
  #validates :tax_kind, :presence => true
  validates :type_in_date, :presence => true
  
  def foreign_enterprise
    ForeignEnterprise.find_by_code(foreign_enterprise_code);
  end
  
  def operate_enterprise
    Enterprise.find_by_code(operate_enterprise_code);
  end


end
