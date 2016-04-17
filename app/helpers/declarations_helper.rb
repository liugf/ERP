# -*- encoding : utf-8 -*-
module DeclarationsHelper
  include  FileUtils, ApplicationHelper

  def generate_declaration_xml(id, version)
    begin
      declaration = Declaration.find(id)

      serial_no = system_serial_no
      message_id = declaration.enterprise.enterprise_custom_option.platform_id.to_s + serial_no

      action_view = ActionView::Base.new(Rails.root.join('app', 'views'))
      action_view.class_eval do
        include ApplicationHelper, DeclarationsHelper, PrintHelper
      end
      file_name = declaration.pre_entry_no + "_" + version + ".xml"
      action_view.assign({:declaration => declaration, :serial_no => serial_no})
      file = File.new(Settings["dispatch_paths"]["temp"] + "/" + file_name, 'w')
      file.puts(action_view.render(:template => "misc/declaration"+ version +".xml.erb"))
      
      file.close
      FileUtils.mv file, Settings["dispatch_paths"]["upload_temp"] + "/" + file_name
      DispatchRecord.new({:declaration_id => id,
                          :message_id => message_id,
                          :channel => '000',
                          :note => version + '版本报文生成成功'}).save
      true
    rescue
      logger.error $!
      false
    end
  end

  def tcs(attribute, value)
    if value.blank?
      "<#{attribute} xsi:nil=\"true\" />"
    else
      "<#{attribute}>#{value}</#{attribute}>"
    end
  end

  def tcs_with_tcs_keyword(attribute, value)
    if value.blank?
      "<tcs:#{attribute} xsi:nil=\"true\" />"
    else
      "<tcs:#{attribute}>#{value}</tcs:#{attribute}>"
    end
  end

  def ith_result_material_balance(contract,i)
    ith_result = []
    @materials = contract.contract_materials
    @materials.each_with_index { |material,j|
      ith_result[j] = {}
      @same_contract_materials = ContractMaterial.where(:code => material.code )
      ith_result[j][:contract_num] = @same_contract_materials.count('contract_id',:distinct => true)
      material[:quantity] = @same_contract_materials.sum('quantity')
      ith_result[j][:material] = material
      tem_import_price = 0
      tem_export_price = 0
      @same_contract_materials.each { |material|
        opt = {}
        opt[:enterprise_id] = current_enterprise.id
        opt[:contract_id] = material.contract.id
        opt[:review_type] =  %w[1 3]
        opt[:declaration_type] = 'import'
        tem1 = Declaration.where(opt).joins(:declaration_cargos).sum('unit_price * quantity')
        tem_import_price = tem_import_price +  Integer(tem1)
        opt[:declaration_type] = 'export'
        tem2 = Declaration.where(opt).joins(:declaration_cargos).sum('unit_price * quantity')
        tem_export_price = tem_export_price + Integer(tem2)
      }
      ith_result[j][:import_price] = tem_import_price
      ith_result[j][:export_price] = tem_export_price
    }
    return ith_result
  end

  def find_declarations_by_ent_cont_type_time
    opt = {}
    if  params[:current_enterprise_id] != '' and  params[:current_enterprise_id] != '044199'
      opt[:enterprise_id] = params[:current_enterprise_id]
    end
    if  params[:contract_id] != ''
      opt[:contract_id] = params[:contract_id]
    end
    opt[:declaration_type] = params[:declaration_type]== '' ? %w[import  export] : params[:declaration_type]
    if params[:review_type] != "1"
      opt[:review_type] = params[:review_type] == "2" ?  %w[1 2 3 4]: 0
    end
    if params[:from] !='' and params[:to] != ''
      opt[:declare_date] = params[:from]..params[:to]
    end
    if !params[:custom].nil? and  params[:custom] != ''
      opt[:load_port] = params[:custom]
    end
    if params[:current_enterprise_id] == '044199'
      return Declaration.where(opt).order('declare_date').joins('LEFT OUTER JOIN enterprises ON enterprises.id = declarations.enterprise_id').where("enterprises.code like '44199%'")
    end
    return  Declaration.where(opt).order('declare_date')
  end



end
