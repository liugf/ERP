# -*- encoding : utf-8 -*-
class Dict::DictsController < ApplicationController
  def index
    authorize! :index, :dict
    @title = '字典列表'
    @items = modle.paginate(:page => params[:page],:per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
    end
  end
  
  def show
    authorize! :show, :dict
    @title = '字典详细'
    @item = modle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end  

  def new
    authorize! :new, :dict
    @title = '添加字典'
    @item = modle.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  def edit
    authorize! :edit, :dict
    @title = '修改字典'
    @item = modle.find(params[:id])
  end

  def create
    authorize! :create, :dict
    @item = modle.new(params[symbol])

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: '成功创建字典条目.' }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! :update, :dict
    @item = modle.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[symbol])
        format.html { redirect_to @item, notice: '修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, :dict
    @item = modle.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to action: 'index' }
      format.json { head :no_content }
    end
  end
  
end