# -*- encoding : utf-8 -*-
class Declaration < ActiveRecord::Base

  self.per_page = 30

  belongs_to :enterprise
  belongs_to :contract
  has_one :declaration_transit_information, :dependent => :destroy
  has_many :declaration_cargos, :dependent => :destroy
  has_many :declaration_containers, :dependent => :destroy
  has_many :declaration_packings, :dependent => :destroy
  has_many :dispatch_records, :dependent => :destroy
  has_many :finances, :dependent => :destroy
  has_many :checkout_enterprises, :through => :finances
  accepts_nested_attributes_for :declaration_transit_information
  
  scope :export, where(:declaration_type => "export")
  scope :import, where(:declaration_type => "import")
  
  validates :enterprise_id, :presence => true, :numericality => true
  validates :declaration_type, :presence => true
  validates :pre_entry_no, :presence => true, :uniqueness => true
  validates :operate_enterprise_code, :presence => true
  validates :declare_enterprise_code, :presence => true
  validates :declare_date, :presence => true
  validates :custom, :presence => true
  validates :custom_code, :presence => true
  validates :load_port, :presence => true
  validates :declare_date, :presence => true
  validates :package_amount, :presence => true, :numericality => true
  validates :net_weight, :presence => true, :numericality => true
  validates :gross_weight, :presence => true, :numericality => true
  validates_numericality_of :gross_weight, :greater_than_or_equal_to => :net_weight
  validates_numericality_of :net_weight, :less_than_or_equal_to => :gross_weight
  validates :transit_type, :presence => true
  #validates :transport_tool, :presence => true, :length => { :maximum => 14 }
  validates :transport_tool,  :length => { :maximum => 14 }

  before_validation :process_data

  def process_data
    self.attachments_mark = self.attachments_mark.gsub(/ +/, ' ')
  end
  
  def attachments
    hash = Hash.new
    if !self.attachments_mark.blank?
      self.attachments_mark.split(' ').each{|item|
        key_value = item.split(':')
        if key_value.size == 2
          hash[key_value[0]] = key_value[1]
        end
      }
    end
    hash    
  end
  
  def operate_enterprise=(enterprise)
    operate_enterprise_code = enterprise.code
  end
  
  def operate_enterprise
    Enterprise.find_by_code(operate_enterprise_code)
  end
  
  def declare_enterprise=(enterprise)
    declare_enterprise_code = enterprise.code
  end
  
  def declare_enterprise
    Enterprise.find_by_code(declare_enterprise_code)
  end

  def foreign_enterprise=(enterprise)
    foreign_enterprise_code = enterprise.code
  end

  def foreign_enterprise
    ForeignEnterprise.find_by_code(foreign_enterprise_code);
  end

end
