# -*- encoding : utf-8 -*-
class DeclarationCargosController < ApplicationController
  before_filter :init
  
  def init
    if params[:id]
      @declaration_cargo = DeclarationCargo.find(params[:id])
      @declaration = @declaration_cargo.declaration
      @declaration_type = @declaration_cargo.declaration.declaration_type
    elsif params[:declaration_id]
      @declaration = Declaration.find(params[:declaration_id])
      @declaration_type = @declaration.declaration_type
    else
      @declaration = Declaration.find(params[:declaration_cargo][:declaration_id])
      @declaration_type = @declaration.declaration_type
    end
    @mark = @declaration_type
  end
  
  # GET /declaration_cargos
  # GET /declaration_cargos.json
  def index
    @declaration_cargos = @declaration.declaration_cargos.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @declaration_cargos }
    end
  end

  # GET /declaration_cargos/1
  # GET /declaration_cargos/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @declaration_cargo }
    end
  end

  # GET /declaration_cargos/new
  def new
    @declaration_cargo = DeclarationCargo.new(:declaration_id => @declaration.id,
                                              :quantity1 => 0,
                                              :quantity2 => 0,
                                              :no => @declaration.declaration_cargos.size + 1)

    if @declaration_cargo.no > 50
      redirect_to declaration_cargos_url(:declaration_id => @declaration.id),:flash => {:attention => '不能超过50项商品'}
    end

    if @declaration.contract
      if @declaration.declaration_type == "export"
        @declaration_cargo.currency = @declaration.contract.export_currency
      else
        @declaration_cargo.currency = @declaration.contract.import_currency
      end
    end

  end

  # GET /declaration_cargos/1/edit
  def edit
  end

  # POST /declaration_cargos
  # POST /declaration_cargos.json
  def create
    @declaration_cargo = DeclarationCargo.new(params[:declaration_cargo])

    respond_to do |format|
      if @declaration_cargo.save
        format.html { redirect_to new_declaration_cargo_url(:declaration_id => @declaration_cargo.declaration_id), :flash => {:success => '保存成功'} }
        format.json { render json: @declaration_cargo, status: :created, location: @declaration_cargo }
      else
        format.html { render action: "new" }
        format.json { render json: @declaration_cargo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /declaration_cargos/1
  # PUT /declaration_cargos/1.json
  def update
    respond_to do |format|
      if @declaration_cargo.update_attributes(params[:declaration_cargo])
        format.html { redirect_to @declaration_cargo, :flash => {:success => "修改成功"} }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @declaration_cargo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /declaration_cargos/1
  # DELETE /declaration_cargos/1.json
  def destroy
    @declaration_cargo.destroy

    respond_to do |format|
      format.html { redirect_to declaration_cargos_url(:declaration_id => @declaration_cargo.declaration_id), :flash => {:success => "删除成功"} }
      format.json { head :no_content }
    end
  end
end
