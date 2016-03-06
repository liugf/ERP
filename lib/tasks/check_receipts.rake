# -*- encoding : utf-8 -*-
require "rexml/document"
require "iconv"

include FileUtils

namespace :receipt do

  desc "process the receipt"
  task :check_receipts => :environment do
    puts "process the receipt"  + Time.new.strftime(" %Y-%m-%d, %H:%M:%S")
    dir_path = Settings['dispatch_paths']['download_temp']
    Dir.new(dir_path).each do |file_name|
      if file_name != '.' and file_name != '..'
        file = File.new(dir_path + '/' + file_name)
        doc = REXML::Document.new(file)
        message_type = REXML::XPath.first(doc, "//MessageType" ).text  rescue ''
        if message_type == 'TcsFlow201Response'
          message_id = REXML::XPath.first(doc, "//MessageId" ).text  rescue ''
          request_message_id = REXML::XPath.first(doc, "//RequestMessageId" ).text   rescue ''
          task_id = REXML::XPath.first(doc, "//TaskId" ).text    rescue ''
          note = REXML::XPath.first(doc, "//ResponseList//ResultValue" ).text rescue nil
          note = note || (REXML::XPath.first(doc, "//TcsFlow201Response//ResultValue" ).text rescue '')
          dispatch_record_generate = DispatchRecord.where("message_id = ? AND channel = ?", request_message_id, '000').last
          if dispatch_record_generate
            dispatch_record_generate.task_id = task_id
            dispatch_record_generate.save
            dispatch_record_new = DispatchRecord.new({:declaration_id => dispatch_record_generate.declaration_id,
              :message_id => message_id,
              :task_id => task_id,
              :note => note})
            dispatch_record_new.save
          end
        elsif message_type == 'TcsFlow201'
          message_id = REXML::XPath.first(doc, "//MessageId" ).text     rescue ''
          task_id = REXML::XPath.first(doc, "//TaskId" ).text     rescue ''
          channel = REXML::XPath.first(doc, '//Channel | //CHANNEL' ).text     rescue ''
          note = REXML::XPath.first(doc, "//Note | //NOTE" ).text.to_s rescue ''
          note += (REXML::XPath.first(doc, "//ResultInformation" ).text.to_s rescue '')
          dispatch_record_generate = DispatchRecord.where("task_id = ? AND channel = ?", task_id, '000').last
          if dispatch_record_generate
            dispatch_record_new = DispatchRecord.new({:declaration_id => dispatch_record_generate.declaration_id,
              :message_id => message_id,
              :channel => channel,
              :task_id => task_id,
              :note => note})
            dispatch_record_new.save
            if channel == '016' or channel == '025'
              eport_no = REXML::XPath.first(doc, "//EportNo" ).text  rescue ''
              entry_no = REXML::XPath.first(doc, "//EntryId" ).text  rescue ''
              declaration = Declaration.find(dispatch_record_generate.declaration_id)
              if declaration
                declaration.eport_no = eport_no
                declaration.entry_no = entry_no
                declaration.is_finish = true
                declaration.review_type = 1
                declaration.save
                if !Finance.find_by_declaration_id(declaration.id)
                  Finance.create!(:declaration_id => declaration.id,
                    :is_made => false,
                    :review => 1,
                    )
                end
              end
              Message.new({:subject => '报关单申报成功', :body => '报关单<a href="' + Settings['ERP_path'] + '/declarations/' + declaration.id.to_s + '" >' + declaration.pre_entry_no + '</a>申报成功！'}
                ).send_message(:system, declaration.created_by)
            end

          end
        end

        file.close
        FileUtils.mv file, Settings["dispatch_paths"]["download"] + "/" + File.basename(file)

      end

    end
  end


  desc "process the application and bill receipt"
  task :app_bill_check_receipts => :environment do
    puts "process the application and bill receipt"  + Time.new.strftime(" %Y-%m-%d, %H:%M:%S")
    dir_path = Settings['app_bill_dispatch_paths']['download_temp']
    Dir.new(dir_path).each do |file_name|
      if file_name != '.' and file_name != '..'
        #file = File.open(dir_path + '/' + file_name)
        convert_gb2312_to_utf8( dir_path + '/' + file_name)
        file = File.open(dir_path + '/tmp.xml','r')

        doc = REXML::Document.new(file)
        #先取出xml里的值
        seq_no = REXML::XPath.first(doc, "//SEQ_NO" ).text rescue ''
        custome_no = REXML::XPath.first(doc, "//CUSTOMS_NO" ).text rescue ''
        cop_no = REXML::XPath.first(doc, "//COP_NO" ).text rescue ''
        trade_code = REXML::XPath.first(doc, "//TRADE_CODE" ).text rescue ''
        ret_type = REXML::XPath.first(doc, "//RET_TYPE" ).text rescue ''
        sort_flag = REXML::XPath.first(doc, "//SORT_FLAG" ).text rescue ''
        ret_no = REXML::XPath.first(doc, "//RET_NO" ).text rescue ''
        chk_status = REXML::XPath.first(doc, "//CHK_STATUS" ).text rescue ''
        notice_date = REXML::XPath.first(doc, "//NOTICE_DATE" ).text rescue ''
        note = REXML::XPath.first(doc, "//NOTE" ).text rescue ''
        ret_content = REXML::XPath.first(doc, "//RET_CONTENT" ).text rescue ''

        if chk_status == '5'
          puts "入数据中心库失败:#{note}"
          next
        elsif chk_status == '9'
          puts "入海关库失败:#{note}"
          next
        end

        dispatch_record_generate = AppBillDispatchRecord.where("ret_no = ? ", ret_no).last
        if dispatch_record_generate
          #生成新的record
          record_hash = {:ret_type => ret_type,
           :sort_flag => sort_flag,
           :ret_no => ret_no,
           :chk_status => chk_status,
           :notice_date => notice_date,
           :note => note,
           :ret_content => ret_content}
           if ret_type == '1'
            record_hash[:application_id] =  dispatch_record_generate.application_id
          else
            record_hash[:bill_id] =  dispatch_record_generate.bill_id
          end
          dispatch_record_new = AppBillDispatchRecord.new(record_hash)
          dispatch_record_new.save

          #更新application,bill表           处理申请表、收发货单、退货单三种情况
          if ret_type == '1'
            app_or_bill =  Application.find(dispatch_record_generate.application_id)
          else
            app_or_bill =  Bill.find(dispatch_record_generate.bill_id)
          end

          if app_or_bill
            app_or_bill.seq_no = seq_no
            app_or_bill.app_no = custome_no
            if sort_flag == 0
              app_or_bill.is_out_finish = true
            else
              app_or_bill.is_finish = true
            end
            app_or_bill.save
          end

        end

        file.close
        FileUtils.mv file, Settings["app_bill_dispatch_paths"]["download"] + "/" + File.basename(file)

      end
    end
  end

  def convert_gb2312_to_utf8(file)
    temp_file = File.new('public/tmp.xml','w')
    File.readlines(file).each_with_index do |line, index|
      if index == 0
        next
      end
      temp_file.puts Iconv.iconv('utf-8','gb2312',line)
    end
    temp_file.close
  end

end
