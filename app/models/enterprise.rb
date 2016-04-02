# -*- encoding : utf-8 -*-
class Enterprise < ActiveRecord::Base
  has_one :enterprise_custom_option, :dependent => :destroy
  accepts_nested_attributes_for :enterprise_custom_option
  validates_associated :enterprise_custom_option
  
  has_many :cargos, :dependent => :destroy
  has_many :contracts, :dependent => :destroy
  has_many :declarations, :dependent => :destroy
  has_many :applications, :dependent => :destroy
  has_many :in_applications, foreign_key: "in_enterprise_id",
           class_name:  "Application",:dependent => :destroy
  has_many :enterprise_fees, :dependent => :destroy


  validates :code, :presence => true, :uniqueness => true, :length => { :is => 18 }
  validates :organization_code, :presence => true, :uniqueness => true, :length => { :is => 9 }
  validates :name, :presence => true
  
  def build_enterprise_customs_option
    enterprise_custom_option = EnterpriseCustomOption.create(
                                    :enterprise_id => self.id, 
                                    :custom_code => "0000",
                                    :proxy_unit_price => 0,
                                    :service_unit_price =>0)
    self.enterprise_custom_option = enterprise_custom_option
  end
  
end
