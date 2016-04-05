# -*- encoding : utf-8 -*-
class PagesController < ApplicationController   
  def home
  end
  
  def dict
  end  
  
  def select_enterprise
    enterprise = Enterprise.find_by_id(params[:current_enterprise_id])
    if enterprise
      set_current_enterprise enterprise
      flash[:success] = "切换当前生产销售单位为：" + enterprise.name   
    end
    redirect_to params[:url]
  end

  def barcode
    require 'barby'
    require 'barby/barcode/code_39'
    require 'barby/outputter/png_outputter'
    barcode = Barby::Code39.new(params['code'], true)
    send_data barcode.to_png(:height => 30, :margin => 2), :type => 'image/png', :disposition => 'inline'
  end

end
