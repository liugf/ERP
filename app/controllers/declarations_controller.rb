# -*- encoding : utf-8 -*-
class DeclarationsController < ApplicationController
  include ApplicationHelper, DeclarationsHelper, PrintHelper
  before_filter :init

  def init
    if params[:id]
      @declaration = Declaration.find(params[:id])
      @declaration_type = @declaration.declaration_type
    else
      @declaration_type = params[:declaration_type] || params[:declaration][:declaration_type] rescue nil
    end
    @mark = @declaration_type
  end

  # GET /declarations
  # GET /declarations.json
  def index
    if current_enterprise
      @declarations = Declaration.where("enterprise_id = ? and declaration_type = ?", current_enterprise.id, @declaration_type).page(params[:page]).order("updated_at DESC")
    else
      @declarations = Enterprise.new.declarations.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @declarations }
    end
  end

  # GET /declarations/1
  # GET /declarations/1.json
  def show
    authorize! :show, @declaration
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @declaration }
    end
  end

  def print_declaration
    authorize! :show, @declaration
    @declaration_cargos = @declaration.declaration_cargos.order("no")
    @groups = Array.new((@declaration_cargos.size - 1) / 5 + 1) { Array.new }
    @declaration_cargos.each_with_index do |declaration_cargo, index|
      @groups[index / 5][index % 5] = declaration_cargo
    end
    @title = '打印报关单'
    render :layout => 'print'
  end

  def print_contract
    authorize! :show, @declaration
    @declaration_cargos = @declaration.declaration_cargos.order("no")
    @title = '打印合同'
    render :layout => 'print'
  end

  def print_contract2
    authorize! :show, @declaration
    @declaration_cargos = @declaration.declaration_cargos.order("no")
    @title = '打印合同2'
    render :layout => 'print'
  end

  def print_tax_invoice
    authorize! :show, @declaration
    @declaration_cargos = @declaration.declaration_cargos.order("no")
    @title = '打印国税发票'
    render :layout => 'print'
  end

  def print_invoice
    authorize! :show, @declaration
    @declaration_cargos = @declaration.declaration_cargos.order("no")
    @title = '打印发票'
    render :layout => 'print'
  end

  def print_normal
    authorize! :show, @declaration
    @declaration_cargos = @declaration.declaration_cargos.order("no")
    @title = '打印规范发票'
    render :layout => 'print'
  end

  def print_packing1
    authorize! :show, @declaration
    @declaration_packings = @declaration.declaration_packings.order("no")
    @title = '打印装箱单'
    render :layout => 'print'
  end

  def print_packing2
    authorize! :show, @declaration
    @declaration_packings = @declaration.declaration_packings.order("no")
    @title = '打印装箱明细单'
    render :layout => 'print'
  end

  def print_packing3
    authorize! :show, @declaration
    @declaration_cargos = @declaration.declaration_cargos.order("no")
    @title = '打印凤岗装箱单'
    render :layout => 'print'
  end

  # GET /declarations/1/declare.json
  def declare
    authorize! :declare, @declaration
    if generate_declaration_xml(@declaration.id)
      result = {:type => "success", :content => "已经成功生成报文，请稍后再查询申报结果"}
    else
      result = {:type => "error", :content => "生成报文失败"}
    end
    respond_to do |format|
      format.json { render json: result }
    end
  end

  # GET /declarations/new
  # GET /declarations/new.json
  def new
    if current_enterprise
      pre_entry_no = Time.now.strftime('%Y%m%d%H%M%S') + system_serial_no
      @declaration = Declaration.new(:enterprise_id => current_enterprise.id,
                                     :declaration_type => @declaration_type,
                                     :pre_entry_no => pre_entry_no,
                                     :pay_way => "7",
                                     :destination => "44199",
                                     :deal_mode => @declaration_type == "export" ? "3" : "1",
                                     :declare_enterprise_code => "4419980074",
                                     :transit_type => "001",
                                     :declaration_mode => "003",
                                     :created_by => current_user.username)
      @declaration.declaration_transit_information = DeclarationTransitInformation.new(:local_transport_mode => 4)
    else
      redirect_to declarations_path(:declaration_type => @declaration_type), notice: '请选择要操作的企业'
    end
  end

  # GET /declarations/1/edit
  def edit
    authorize! :edit, @declaration
  end

  # POST /declarations
  # POST /declarations.json
  def create
    @declaration = Declaration.new(params[:declaration])
    authorize! :create, @declaration

    respond_to do |format|
      if @declaration.save
        Finance.create!(:declaration_id => @declaration.id,
                        :is_made => false,
                        :review => 1,
        )
        format.html { redirect_to @declaration, :flash => { :success => '成功保存报关单'} }
        format.json { render json: @declaration, status: :created, location: @declaration }
      else
        format.html { render action: "new", :declaration_type => 1 }
        format.json { render json: @declaration.errors, status: :unprocessable_entity }
      end
    end
  end

  def copy
    pre_entry_no = Time.now.strftime('%Y%m%d%H%M%S') + system_serial_no
    #@new_declaration = Declaration.new(@declaration.attributes.merge({}))
    @new_declaration = @declaration.dup
    @new_declaration.pre_entry_no = pre_entry_no
    @new_declaration.entry_no = ''
    @new_declaration.declare_date = Time.now.strftime('%Y-%m-%d')
    @new_declaration.is_finish = false
    @new_declaration.declaration_transit_information = DeclarationTransitInformation.new(:local_transport_mode => 4)
    authorize! :create, @new_declaration

    respond_to do |format|

      if @new_declaration.save
        Finance.create!(:declaration_id =>  @new_declaration.id,
                        :is_made => false,
                        :review => 1,
        )
        #复制出口成品、进口料件
        @declaration.declaration_cargos.each do |cargo|
          new_cargo = cargo.dup
          new_cargo.declaration_id = @new_declaration.id
          new_cargo.save
        end
        #复制集装箱
        @declaration.declaration_containers.each do |container|
          new_container = container.dup
          new_container.declaration_id = @new_declaration.id
          new_container.save
        end
        #复制装箱单明细
        @declaration.declaration_packings.each do |packing|
          new_packing = packing.dup
          new_packing.declaration_id = @new_declaration.id
          new_packing.save
        end
        format.html { redirect_to  declarations_url(:declaration_type => @declaration_type), :flash => { :success => '成功复制报关单'} }
        format.json { render json: @new_declaration, status: :created, location: @new_declaration }
      else
        format.html { render action: "new", :declaration_type => 1 }
        format.json { render json: @new_declaration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /declarations/1
  # PUT /declarations/1.json
  def update
    authorize! :update, @declaration
    respond_to do |format|
      if @declaration.update_attributes(params[:declaration])
        format.html { redirect_to @declaration, :flash => { :success => '成功修改报关单'} }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @declaration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /declarations/1
  # DELETE /declarations/1.json
  def destroy
    authorize! :destory, @declaration
    @declaration.destroy

    respond_to do |format|
      format.html { redirect_to declarations_url(:declaration_type => @declaration_type), :flash => { :success => '删除成功'}}
      format.json { head :no_content }
    end
  end

  def print_attorney
    authorize! :show, @declaration
    @declaration_cargos = @declaration.declaration_cargos.order("no")
    @major_cargo = nil
    @major_cargo_price = 0
    @total_price = 0
    @declaration_cargos.each do |cargo|
      tem = cargo.total_price
      @total_price += tem
      if tem > @major_cargo_price
        @major_cargo = cargo
      end
    end
    @title = '代理报关委托书'
    render :layout => 'print'
  end

  def manage
    respond_to do |format|
      format.html
      format.json {
        declarations =  find_declarations_by_ent_cont_type_time
        cache_name =  "manage_declarations_#{Time.new.to_i}"
        Rails.cache.write(cache_name, declarations)
        if declarations.size > 0
          declarations[0][:cache_name] = cache_name
        end
        render json: declarations
      }
    end
  end

  def toggle
    respond_to do |format|
      format.json {
        if params[:type] == 'review_type'
          render json: {result: Declaration.find(params[:id]).update_attribute(params[:type], params[:is_yes] == 'true' ? 0 : 3)}
        else
          render json: {result: Declaration.find(params[:id]).update_attribute(params[:type], params[:is_yes] == 'true' ? false : true)}
        end

      }
    end
  end

  def print_declarations
    @declarations = Rails.cache.read(params[:cache_name])
    @title = '报关单预入库管理查询结果'
    @enterprise_name = params[:enterprise_name]
    @manual = params[:manual]
    @from = params[:from]
    @to = params[:to]
    render :layout => 'print'
  end

  def statistic
    respond_to do |format|
      format.html
      format.json {
        opt = {}
        statistic = {}
        result = {}
        if  params[:current_enterprise_id] != ''
          opt[:enterprise_id] = params[:current_enterprise_id]
        end
        if  params[:contract_id] != ''
          opt[:contract_id] = params[:contract_id]
        end
        opt[:review_type] = %w[1 3]
        #报关单数   报关单金额
        opt[:declaration_type] = 'import'
        import_declarations = Declaration.where(opt)
        statistic[:import_sum] = import_declarations.count
        statistic[:import_price] = import_declarations.joins(:declaration_cargos).sum('unit_price * quantity')
        opt[:declaration_type] = 'export'
        export_declarations = Declaration.where(opt)
        statistic[:export_sum] = export_declarations.count
        statistic[:export_price] = export_declarations.joins(:declaration_cargos).sum('unit_price * quantity')
        cache_name =  "statistic_#{Time.new.to_i}"
        Rails.cache.write(cache_name, statistic)
        statistic[:cache_name] = cache_name
        result[:statistic] = statistic
        render json: result
      }
    end
  end

  def print_statistic
    @title = '加工贸易合同核销申请表'
    @contract = Contract.find(params[:contract_id])
    @statistic = Rails.cache.read(params[:cache_name])
    cache_name_2 = params[:cache_name_2].split(",")
    @statistic_pro_mat_con = {}
    @statistic_pro_mat_con[:materials] = Rails.cache.read(cache_name_2[0])
    @statistic_pro_mat_con[:products] = Rails.cache.read(cache_name_2[1])
    @statistic_pro_mat_con[:consumptions] = Rails.cache.read(cache_name_2[2])
    render :layout => 'print'
  end

  def statistic_pro_mat_con
    respond_to do |format|
      format.json {
        statistic_pro_mat_con = {}
        contract = Contract.find(params[:contract_id])
        #单损耗  按合同算
        statistic_pro_mat_con[:products] =  contract.contract_products
        statistic_pro_mat_con[:materials] =  contract.contract_materials

        opt = {}
        opt[:enterprise_id] = current_enterprise.id
        opt[:contract_id] = params[:contract_id]
        opt[:review_type] = %w[1 3]
        opt[:declaration_type] = 'export'
        export_declarations = Declaration.where(opt)
        opt[:declaration_type] = 'import'
        import_declarations = Declaration.where(opt)

        #成品 按报关单算   begin
        statistic_pro_mat_con[:products].each_with_index { |product, i|

          #出口总数量
          #trade_mode = %w[9900 1300 0214 0255 0466 4400 0615 0715 1215 4600 0744 0110 0633 1200 1234 1215 6033 1233 9700 0400 0654]
          trade_mode = %w[0214 0255 0615 0654 0715 4400 4600 0110 1200 1215 1233 1234 6033]
          statistic_pro_mat_con[:products][i][:export_sum] = export_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', product.no ,trade_mode).sum('quantity')
          #深加工结转出口数量
          trade_mode = %w[0255 0654]
          statistic_pro_mat_con[:products][i][:transfer_sum] = export_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', product.no ,trade_mode).sum('quantity')
          #成品放弃数量
          trade_mode = %w[0400]
          statistic_pro_mat_con[:products][i][:quit_sum] = export_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', product.no ,trade_mode).sum('quantity')
          #成品退换进口数量  -- 用进口报关单统计
          trade_mode = %w[4400 4600]
          statistic_pro_mat_con[:products][i][:import_change_sum] = import_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', product.no ,trade_mode).sum('quantity')
          #成品退换出口数量
          trade_mode = %w[4400 4600]
          statistic_pro_mat_con[:products][i][:export_change_sum] = export_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', product.no ,trade_mode).sum('quantity')
        }
        #成品 按报关单算   end

        #料件 按报关单算   begin
        statistic_pro_mat_con[:materials].each_with_index { |material, i|
          #进口总数量
          trade_mode = %w[9900 1300 0214 0255 0300 0245 0258 0615 0715 1215 0700 0657 0644 0654 0110 0633 1200 1234 1215 6033 1233 9700 0420 0245 2025 2225]
          statistic_pro_mat_con[:materials][i][:import_sum] = import_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
          #深加工结转进口数量
          #trade_mode = %w[0255 0654]
          statistic_pro_mat_con[:materials][i][:transfer_sum] = import_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
          #产品总耗用量
          statistic_pro_mat_con[:materials][i][:consum_sum] = ContractConsumption.joins(:contract_product).where('contract_material_id = ?',material.id).sum('contract_products.quantity * used + wasted')
          #内销数量
          trade_mode = %w[0245 0644]
          statistic_pro_mat_con[:materials][i][:domestic_sum] = import_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
          #退运出口数量
          trade_mode = %w[0265 0664]
          statistic_pro_mat_con[:materials][i][:quit_transfer_sum] = import_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
          #复出数量    -- 用出口报关单统计
          trade_mode = %w[0300 0265 0700 0664]
          statistic_pro_mat_con[:materials][i][:again_sum] = export_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
          #料件放弃数量
          trade_mode = %w[0200]
          statistic_pro_mat_con[:materials][i][:quit_sum] = import_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
          #边角料数量
          trade_mode = %w[0845 0844]
          tem1 = import_declarations.where(:trade_mode=>trade_mode).joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
          #边角料数量      -- 用出口报关单统计
          trade_mode = %w[0865 0864]
          tem2 = export_declarations.where(:trade_mode=>trade_mode).joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
          statistic_pro_mat_con[:materials][i][:side_sum] = tem1.to_f + tem2.to_f
          #余料结转数量   -- 用出口报关单统计
          trade_mode = %w[0657 0258]
          statistic_pro_mat_con[:materials][i][:remain_sum] = export_declarations.joins(:declaration_cargos)
          .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
          #余料剩余数量
          statistic_pro_mat_con[:materials][i][:remain2_sum] =  statistic_pro_mat_con[:materials][i][:import_sum].to_f
          - statistic_pro_mat_con[:materials][i][:domestic_sum].to_f - statistic_pro_mat_con[:materials][i][:quit_transfer_sum].to_f
          - statistic_pro_mat_con[:materials][i][:consum_sum].to_f
        }
        #料件 按报关单算   end
        cache_name1 =  "statistic_mat#{Time.new.to_i}"
        Rails.cache.write(cache_name1, statistic_pro_mat_con[:materials])
        #test1 = Rails.cache.read(cache_name1)
        cache_name2 =  "statistic_pro#{Time.new.to_i}"
        Rails.cache.write(cache_name2, statistic_pro_mat_con[:products])
        #test2 = Rails.cache.read(cache_name2)
        statistic_pro_mat_con[:consumptions] = []
        statistic_pro_mat_con[:products].each_with_index { |product, i|
          statistic_pro_mat_con[:consumptions][i] = product.contract_consumptions.joins(:contract_product, :contract_material).select(
              'contract_products.no as contract_product_no , contract_materials.no as contract_material_no,
          contract_products.name as contract_product_name , contract_materials.name as contract_material_name,
           contract_consumptions.used, contract_consumptions.wasted, contract_products.quantity').all
        }
        cache_name3 =  "statistic_con#{Time.new.to_i}"
        Rails.cache.write(cache_name3, statistic_pro_mat_con[:consumptions])
        #test3 = Rails.cache.read(cache_name3)
        statistic_pro_mat_con[:cache_name_2] = "#{cache_name1},#{cache_name2},#{cache_name3}"
        render json: statistic_pro_mat_con
      }
    end
  end

  def balance
    respond_to do |format|
      format.html
      format.json {
        result = []
        if  params[:contract_id] != ''

          contract = Contract.find(params[:contract_id])
          result = contract.contract_materials
          contract_products =  contract.contract_products

          opt = {}
          opt[:enterprise_id] = current_enterprise.id
          opt[:contract_id] = params[:contract_id]
          opt[:review_type] = %w[1 3]
          opt[:declaration_type] = 'import'
          if params[:from] !='' and params[:to] != ''
            opt[:declare_date] = params[:from]..params[:to]
          end
          import_declarations = Declaration.where(opt)


          result.each_with_index { |material, i|
            #实际进口数量
            trade_mode = %w[9900 1300 0214 0255 0300 0245 0258 0615 0715 1215 0700 0657 0644 0654 0110 0633 1200 1234 1215 6033 1233 9700 0420 0245 2025 2225]
            result[i][:import_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #进口金额
            result[i][:import_price] = result[i][:import_sum].to_f * material.unit_price
            #成品所需量
            result[i][:need_sum] = ContractConsumption.joins(:contract_product).where('contract_material_id = ?',material.id).sum('contract_products.quantity * used + wasted')
            #出口成品金额
            result[i][:need_sum_price] =  result[i][:need_sum] * material.unit_price
            #合同余数
            result[i][:remains_sum] = material.quantity - result[i][:import_sum].to_f
            #剩余数量
            result[i][:remains2_sum] = result[i][:import_sum].to_f - result[i][:need_sum].to_f
            #剩余金额
            result[i][:remains2_sum_price] = result[i][:remains2_sum].to_f * material.unit_price
          }

        end
        cache_name =  "material_balance#{Time.new.to_i}"
        Rails.cache.write(cache_name, result)
        if result.size > 0
          result[0][:cache_name] = cache_name
        end
        render json: result
      }
    end
  end

  def print_material_balance
    @materials = Rails.cache.read(params[:cache_name])
    render :layout => 'print'
  end

  def weight
    respond_to do |format|
      format.html
      format.json {
        declarations = find_declarations_by_ent_cont_type_time
        total_price = 0
        declarations.each{|declaration|
          declaration.declaration_cargos.each{|cargo|
            total_price += cargo.total_price
          }
          declaration[:total_price] = total_price
        }
        cache_name =  "weight_prices_#{Time.new.to_i}"
        Rails.cache.write(cache_name, declarations)
        if declarations.size > 0
          declarations[0][:cache_name] = cache_name
        end
        render json: declarations
      }
    end
  end

  def print_weight
    declaration_type_hash = {'1'=>'进 出 口','2'=>'进 口','3'=>'出 口'}
    @custom_name = params[:custom]
    @enterprise_name = params[:enterprise_name]
    @manual = params[:manual]
    @from = params[:from]
    @to = params[:to]
    @declaration_type= declaration_type_hash[params[:declaration_type]]
    @weight_prices = Rails.cache.read(params[:cache_name])
    render :layout => 'print'
  end

  def statistics
    respond_to do |format|
      format.html
      format.json {
        statistic_declarations=find_declarations_by_ent_cont_type_time
        cache_name =  "statistic_declarations#{Time.new.to_i}"
        Rails.cache.write(cache_name, statistic_declarations)
        if statistic_declarations.size > 0
          statistic_declarations[0][:cache_name] = cache_name
        end
        render json:statistic_declarations
      }
    end
  end

  def print_declaration_statistic
    declaration_type_hash = {'1'=>'进 出 口','2'=>'进 口','3'=>'出 口'}
    @custom_name = params[:custom]
    @enterprise_name = params[:enterprise_name]
    @manual = params[:manual]
    @from = params[:from]
    @to = params[:to]
    @declaration_type= declaration_type_hash[params[:declaration_type]]
    @statistic_declarations = Rails.cache.read(params[:cache_name])
    render :layout => 'print'
  end

  def details1
    respond_to do |format|
      format.html
      format.json {
        result = []
        if  params[:contract_id] != ''

          opt = {}
          opt[:enterprise_id] = current_enterprise.id
          opt[:contract_id] = params[:contract_id]
          opt[:review_type] = %w[1 3]
          opt[:declaration_type] = 'import'
          if params[:from] !='' and params[:to] != ''
            opt[:declare_date] = params[:from]..params[:to]
          end
          if !params[:custom].nil? and  params[:custom] != ''
            opt[:load_port] = params[:custom]
          end
          @import_declarations = Declaration.where(opt).all

          count = 0
          accumulation = {}
          @import_declarations.each {|declaration|
            declaration.declaration_cargos.each{|material|
              result[count] = material
              result[count][:declare_date] = declaration.declare_date
              result[count][:entry_no] =  declaration.entry_no
              result[count][:trade_mode] =  declaration.trade_mode
              accumulation[material.no_in_contract] = accumulation[material.no_in_contract] ? accumulation[material.no_in_contract] + material.quantity : material.quantity
              result[count][:accumulation] = accumulation[material.no_in_contract]
              count += 1
            }
          }
        end
        cache_name =  "materials_#{Time.new.to_i}"
        Rails.cache.write(cache_name, result)
        if result.size > 0
          result[0][:cache_name] = cache_name
        end
        #$materials = result
        render json: result
      }
    end
  end

  def details2
    respond_to do |format|
      format.html
      format.json {
        result = []
        if  params[:contract_id] != ''

          opt = {}
          opt[:enterprise_id] = current_enterprise.id
          opt[:contract_id] = params[:contract_id]
          opt[:review_type] = %w[1 3]
          opt[:declaration_type] = 'export'
          if params[:from] !='' and params[:to] != ''
            opt[:declare_date] = params[:from]..params[:to]
          end
          if !params[:custom].nil? and  params[:custom] != ''
            opt[:load_port] = params[:custom]
          end
          export_declarations = Declaration.where(opt).all

          count = 0
          accumulation = {}
          export_declarations.each {|declaration|
            declaration.declaration_cargos.each{|product|
              result[count] = product
              result[count][:declare_date] = declaration.declare_date
              result[count][:entry_no] =  declaration.entry_no
              result[count][:trade_mode] =  declaration.trade_mode
              accumulation[product.no_in_contract] = accumulation[product.no_in_contract] ? accumulation[product.no_in_contract] + product.quantity : product.quantity
              result[count][:accumulation] = accumulation[product.no_in_contract]
              count += 1
            }
          }

        end
        cache_name =  "products_#{Time.new.to_i}"
        Rails.cache.write(cache_name, result)
        if result.size > 0
          result[0][:cache_name] = cache_name
        end
        #$products = result
        render json: result
      }
    end
  end

  def details3
    respond_to do |format|
      format.html
      format.json {
        details3_declarations=find_declarations_by_ent_cont_type_time
        details3_declarations.each_with_index do |declaration, i|
          enterprise =  Enterprise.find(declaration.enterprise_id)
          details3_declarations[i][:enterprise_name] = enterprise.name
          details3_declarations[i][:enterprise_code] = enterprise.code
        end
        cache_name =  "details3_declarations#{Time.new.to_i}"
        Rails.cache.write(cache_name, details3_declarations)
        if details3_declarations.size > 0
          details3_declarations[0][:cache_name] = cache_name
        end
        render json:details3_declarations
      }
    end
  end

  def print_details1
    declaration_type_hash = {'1'=>'进 出 口','2'=>'进 口','3'=>'出 口'}
    @custom_name = params[:custom]
    @enterprise_name = params[:enterprise_name]
    @manual = params[:manual]
    @from = params[:from]
    @to = params[:to]
    @declaration_type= declaration_type_hash[params[:declaration_type]]
    @materials = Rails.cache.read(params[:cache_name])
    render :layout => 'print'
  end

  def print_details2
    declaration_type_hash = {'1'=>'进 出 口','2'=>'进 口','3'=>'出 口'}
    @custom_name = params[:custom]
    @enterprise_name = params[:enterprise_name]
    @manual = params[:manual]
    @from = params[:from]
    @to = params[:to]
    @declaration_type= declaration_type_hash[params[:declaration_type]]
    @products = Rails.cache.read(params[:cache_name])
    render :layout => 'print'
  end

  def print_details3
    @enterprise_name = params[:enterprise_name]
    @to = params[:to]
    @details3_declarations = Rails.cache.read(params[:cache_name])

    #excel
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '报关单明细表'
    #sheet1[0,0] = '申报企业名称（盖章）：'
    #sheet1[0,1] = @enterprise_name

    #format the spreadsheet
    sheet1.column(0).width = 5
    sheet1.column(1).width = 20
    sheet1.column(2).width = 30
    sheet1.column(3).width = 14
    sheet1.column(4).width = 10

    #set spreadsheet data
    sheet1.row(0).replace %w[序号 报关单号 企业名称 企业编码 仓库类型]
    @details3_declarations.each_with_index do |details3_declaration,i|
      sheet1.row(i+1).push i+1 ,details3_declaration.entry_no ,details3_declaration.enterprise_name ,details3_declaration.enterprise_code, details3_declaration.warehouse_no
    end
    #@filename = "#{@enterprise_name}#{(@to.nil? or @to == '') ? Time.new.strftime("%Y-%m") : @to}.xls"
    @filename = "#{Time.new.strftime("%Y%m%d%H%M%S")}.xls"
    @export_file_path = ['public','excels' ,@filename].join("/")
    book.write @export_file_path
    #send_file @export_file_path, :content_type => "application/vnd.ms-excel", :disposition => 'inline'

    render :layout => 'print'
  end

  def export_details3
    details3_declarations = Rails.cache.read(params[:cache_name])
    enterprise_name = params[:enterprise_name]
    to = params[:to]
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => '报关单明细表'
    sheet1[1,1] = '申报企业名称（盖章）：'
    sheet1[1,2] = enterprise_name
    sheet1.row(2) << %w[1 2 3]
    puts  RAILS.root
    export_file_path = [Rails.root , 'excels',   "test.xls"].join("/")
    book.write export_file_path
    send_file export_file_path, :content_type => "application/vnd.ms-excel", :disposition => 'attachment'
    #render :nothing => true
  end

  def materials
    respond_to do |format|
      format.html
      format.json {
        result = {}
        if  params[:contract_id] != ''

          contract = Contract.find(params[:contract_id])
          result = contract.contract_materials
          contract_products =  contract.contract_products

          opt = {}
          opt[:enterprise_id] = current_enterprise.id
          opt[:contract_id] = params[:contract_id]
          opt[:review_type] = %w[1 3]
          opt[:declaration_type] = 'import'
          if params[:from] !='' and params[:to] != ''
            opt[:declare_date] = params[:from]..params[:to]
          end
          if !params[:custom].nil? and  params[:custom] != ''
            opt[:load_port] = params[:custom]
          end
          import_declarations = Declaration.where(opt)


          result.each_with_index { |material, i|
            #进口总数量
            trade_mode = %w[9900 1300 0214 0255 0300 0245 0258 0615 0715 1215 0700 0657 0644 0654 0110 0633 1200 1234 1215 6033 1233 9700 0420 0245 2025 2225]
            result[i][:import_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #可进口数量
            result[i][:can_import_sum] = material.quantity - result[i][:import_sum].to_f
            #退运数量
            trade_mode = %w[0265 0664]
            result[i][:quit_transfer_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #转入数量
            trade_mode = %w[0285 0657]
            result[i][:transfer_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #进口率
            result[i][:import_rate] = material.quantity ==0 ? 0 : result[i][:import_sum].to_f / material.quantity
            #合同单价金额
            result[i][:contract_price] = result[i][:import_sum].to_f * material.unit_price
            #报关单统计总金额
            trade_mode = %w[9900 1300 0214 0255 0300 0245 0258 0615 0715 1215 0700 0657 0644 0654 0110 0633 1200 1234 1215 6033 1233 9700 0420 0245 2025 2225]
            result[i][:import_price] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity*unit_price')
            #金额差
            result[i][:diff_price] = result[i][:contract_price].to_f -  result[i][:import_price].to_f
          }

        end
        cache_name =  "materials_#{Time.new.to_i}"
        Rails.cache.write(cache_name, result)
        if result.size > 0
          result[0][:cache_name] = cache_name
        end
        #$materials = result
        render json: result
      }
    end
  end

  def products
    respond_to do |format|
      format.html
      format.json {
        result = {}
        if  params[:contract_id] != ''

          contract = Contract.find(params[:contract_id])
          result = contract.contract_products
          #contract_materials =  contract.contract_materials

          opt = {}
          opt[:enterprise_id] = current_enterprise.id
          opt[:contract_id] = params[:contract_id]
          opt[:review_type] = %w[1 3]
          opt[:declaration_type] = 'export'
          if params[:from] !='' and params[:to] != ''
            opt[:declare_date] = params[:from]..params[:to]
          end
          if !params[:custom].nil? and  params[:custom] != ''
            opt[:load_port] = params[:custom]
          end
          export_declarations = Declaration.where(opt)
          opt[:declaration_type] = 'import'
          import_declarations = Declaration.where(opt)


          declaration_hash = {}
          declaration_cargos_hash = {}

          declaration_hash[:export_sum_price] = []
          declaration_cargos_hash[:export_sum_price] = []
          trade_modes = %w[9900 1300 0214 0255 0466 4400 0615 0715 1215 4600 0744 0110 0633 1200 1234 1215 6033 1233 9700 0400 0654]
          trade_modes.each do |trade_mode|
            declaration_hash[:export_sum_price].concat  export_declarations.select('id').where('trade_mode = ?',trade_mode).all
          end
          declaration_hash[:export_sum_price].each do |declaration|
            declaration_cargos_hash[:export_sum_price].concat  DeclarationCargo.find_all_by_declaration_id(declaration.id)
          end

          declaration_hash[:rework_import_sum] = []
          declaration_cargos_hash[:rework_import_sum] = []
          trade_modes = %w[4400 4600]
          trade_modes.each do |trade_mode|
            declaration_hash[:rework_import_sum].concat import_declarations.select('id').where('trade_mode = ?', trade_mode)
          end
          declaration_hash[:rework_import_sum].each do |declaration|
            declaration_cargos_hash[:rework_import_sum].concat  DeclarationCargo.find_all_by_declaration_id(declaration.id)
          end

          declaration_hash[:rework_again_sum] = []
          declaration_cargos_hash[:rework_again_sum] = []
          trade_modes = %w[4400 4600]
          trade_modes.each do |trade_mode|
            declaration_hash[:rework_again_sum].concat export_declarations.select('id')
                                                       .where('trade_mode = ?', trade_mode)
          end
          declaration_hash[:rework_again_sum].each do |declaration|
            declaration_cargos_hash[:rework_again_sum].concat  DeclarationCargo.find_all_by_declaration_id(declaration.id)
          end

          declaration_hash[:transfer_sum] = []
          declaration_cargos_hash[:transfer_sum] = []
          trade_modes = %w[0255 0654]
          trade_modes.each do |trade_mode|
            declaration_hash[:transfer_sum].concat export_declarations.select('id')
                                                   .where('trade_mode = ?', trade_mode)
          end
          declaration_hash[:transfer_sum].each do |declaration|
            declaration_cargos_hash[:transfer_sum].concat  DeclarationCargo.find_all_by_declaration_id(declaration.id)
          end

          result.each_with_index { |product, i|
            #出口总数量       #报关单统计总金额
            result[i][:export_sum] = 0
            result[i][:export_price] = 0
            declaration_cargos_hash[:export_sum_price].each do |cargo|
              if cargo.no_in_contract == product.no
                result[i][:export_sum] += cargo.quantity
                result[i][:export_price] +=  cargo.total_price
              end
            end

            #可出口数量
            result[i][:can_export_sum] = product.quantity - result[i][:export_sum].to_f

            #返工进口数量  -- 按进口报关单统计
            result[i][:rework_import_sum] = 0
            declaration_cargos_hash[:rework_import_sum].each do |cargo|
              if cargo.no_in_contract == product.no
                result[i][:rework_import_sum] += cargo.quantity
                #result[i][:rework_import_sum] +=  cargo.total_price
              end
            end

            #返工复出数量
            result[i][:rework_again_sum] = 0
            declaration_cargos_hash[:rework_again_sum].each do |cargo|
              if cargo.no_in_contract == product.no
                result[i][:rework_again_sum] += cargo.quantity
                #result[i][:rework_import_sum] +=  cargo.total_price
              end
            end

            #转厂数量
            result[i][:transfer_sum] = 0
            declaration_cargos_hash[:transfer_sum].each do |cargo|
              if cargo.no_in_contract == product.no
                result[i][:transfer_sum] += cargo.quantity
                #result[i][:rework_import_sum] +=  cargo.total_price
              end
            end

            #出口率
            result[i][:export_rate] = product.quantity==0? 0: result[i][:export_sum].to_f / product.quantity

            #合同单价金额
            result[i][:contract_price] = result[i][:export_sum].to_f * product.unit_price

            #金额差
            result[i][:diff_price] = result[i][:contract_price].to_f -  result[i][:export_price].to_f
          }

        end
        cache_name =  "products_#{Time.new.to_i}"
        Rails.cache.write(cache_name, result)
        if result.size > 0
          result[0][:cache_name] = cache_name
        end
        #$products = result
        render json: result
      }
    end
  end

  def print_materials
    declaration_type_hash = {'1'=>'进 出 口','2'=>'进 口','3'=>'出 口'}
    @custom_name = params[:custom]
    @enterprise_name = params[:enterprise_name]
    @manual = params[:manual]
    @from = params[:from]
    @to = params[:to]
    @declaration_type= declaration_type_hash[params[:declaration_type]]
    @materials = Rails.cache.read(params[:cache_name])
    render :layout => 'print'
  end

  def print_products
    declaration_type_hash = {'1'=>'进 出 口','2'=>'进 口','3'=>'出 口'}
    @custom_name = params[:custom]
    @enterprise_name = params[:enterprise_name]
    @manual = params[:manual]
    @from = params[:from]
    @to = params[:to]
    @declaration_type= declaration_type_hash[params[:declaration_type]]
    @products = Rails.cache.read(params[:cache_name])
    render :layout => 'print'
  end

  def source
    respond_to do |format|
      format.html
      format.json {
        result = []
        if  params[:contract_id] != ''

          contract = Contract.find(params[:contract_id])
          result = contract.contract_materials
          contract_products =  contract.contract_products

          opt = {}
          opt[:enterprise_id] = current_enterprise.id
          opt[:contract_id] = params[:contract_id]
          opt[:review_type] = %w[1 3]
          opt[:declaration_type] = 'import'
          if params[:from] !='' and params[:to] != ''
            opt[:declare_date] = params[:from]..params[:to]
          end
          import_declarations = Declaration.where(opt)


          result.each_with_index { |material, i|
            #进口总数量
            trade_mode = %w[9900 1300 0214 0255 0300 0245 0258 0615 0715 1215 0700 0657 0644 0654 0110 0633 1200 1234 1215 6033 1233 9700 0420 0245 2025 2225]
            result[i][:import_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #直接进口数量
            trade_mode = %w[0124 0615 0715]
            result[i][:direct_import_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #结转进口数量
            trade_mode = %w[0255 0654]
            result[i][:transfer_import_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #余料结转进口数量
            trade_mode = %w[0258 0657]
            result[i][:remain_transfer_import_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #内销数量
            trade_mode = %w[0245 0644]
            result[i][:domestic_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #退运出口数量
            trade_mode = %w[0265 0664]
            result[i][:quit_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #边角料内销数量
            trade_mode = %w[0844 0845]
            result[i][:remain_domestic_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')
            #边角料复出数量
            trade_mode = %w[0864 0865]
            result[i][:remain_again_sum] = import_declarations.joins(:declaration_cargos)
            .where('declaration_cargos.no_in_contract = ? AND trade_mode IN (?)', material.no ,trade_mode).sum('quantity')

            trade_mode = %w[9900 1300 0214 0255 0300 0245 0258 0615 0715 1215 0700 0657 0644 0654 0110 0633 1200 1234 1215 6033 1233 9700 0420 0245 2025 2225]
            #出口成品总耗用
            #result[i][:used_wasted_sum] = ContractConsumption.joins(:contract_product).where('contract_material_id = ?',material.id).sum('contract_products.quantity * used + wasted')
            #出口成品总净耗
            #result[i][:used_sum] = ContractConsumption.joins(:contract_product).where('contract_material_id = ?',material.id).sum('contract_products.quantity * used ')
            #出口成品总损耗
            #result[i][:wasted_sum] = ContractConsumption.joins(:contract_product).where('contract_material_id = ?',material.id).sum('wasted')

            trade_mode = %w[0124 0615 0715]
            #直接出口成品总损耗
            result[i][:direct_used_wasted_sum]
            #直接出口成品总净耗
            result[i][:direct_used_sum]
            #直接出口成品总损耗
            result[i][:direct_wasted_sum]

            trade_mode = %w[0255 0654]
            #结转出口成品总耗用
            result[i][:transfer_used_wasted_sum]
            #结转出口成品总净耗
            result[i][:transfer_used_sum]
            #结转出口成品总损耗
            result[i][:transfer_wasted_sum]


          }

        end
        cache_name =  "sources_#{Time.new.to_i}"
        Rails.cache.write(cache_name, result)
        if result.size > 0
          result[0][:cache_name] = cache_name
        end
        #$sources = result
        render json: result
      }
    end
  end

  def print_source
    @sources = Rails.cache.read(params[:cache_name])
    render :layout => 'print'
  end




  def driver_paper

  end

  def print_driver_paper_1
    @title = '打印大陆司机纸'
    init_driver_paper
    render :layout => 'print'
  end

  def print_driver_paper_2
    @title = '打印香港司机纸'
    init_driver_paper
    render :layout => 'print'
  end

  private

  def init_driver_paper
    transport_tool = params[:transport_tool]
    pre_entry_no = params[:pre_entry_no]
    #找出具有相同运输工具名称的报关单
    if !transport_tool.blank?
      declarations = Declaration.where("transport_tool = ? ", transport_tool)
    else
      declarations = Declaration.where("pre_entry_no = ? ", pre_entry_no)
    end

    if declarations.blank?
      return
    end

    #取出第一个方便打印用
    @declaration = declarations.first

    @truck = Dict::Truck.find_by_code(@declaration.truck)

    #所有报关货物
    @declaration_cargos = []

    @package_amount = 0
    @gross_weight = 0
    @net_weight = 0
    declarations.each do |declaration|
      @declaration_cargos.concat declaration.declaration_cargos
      @package_amount += declaration.package_amount
      @gross_weight += declaration.gross_weight
      @net_weight += declaration.net_weight
    end

    @total_price = 0
    @declaration_cargos.each do |declaration_cargo|
      @total_price += declaration_cargo.total_price
    end

    @declaration_container = @declaration.declaration_containers.first

  end



end
