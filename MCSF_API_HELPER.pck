create or replace package MCSF_API_HELPER is

  -- Помощник к основному АПИ пакету
  
  /*
  Тип order_doc_rec
  */
  type t_mcsf_api_order_doc_rec is record(
        id documents.dcmt_id%type,            -- Идентификатор документа
        order_id doc_links.ord_ord_id%type,   -- Идентификатор заказа
        type_id doc_types_dic.dctp_id%type,   -- Идентификатор типа документа
        doc_type doc_types.def%type,          -- Наименование типа документа
        doc_date documents.doc_date%type,     -- Дата документа
        uploaded_at documents.navi_date%type, -- Дата загрузки
        owner documents.navi_user%type        -- Владелец документа
   );
   
   /*
  Тип order_doc_rec
  */
  type t_mcsf_api_order_doc_file_rec is record(
       id number,
       file_name varchar2(255),
       file_size number
  );
  
  /*
  Возвращает список файлов документа
  */
  function GetDocFiles(pDocId doc_stores.dcmt_dcmt_id%type) return tbl_mcsf_api_order_doc_files pipelined parallel_enable;
  
  /*
  Возвращает список id заказов для инфойса
  */
  function GetInvoiceOrderIds(pInvoiceId invoices.invc_id%type) return tbl_mcsf_api_order_ids pipelined parallel_enable;

end MCSF_API_HELPER;
/
create or replace package body MCSF_API_HELPER is

  /*
  Возвращает список файлов документа
  */
  function GetDocFiles(pDocId doc_stores.dcmt_dcmt_id%type) return tbl_mcsf_api_order_doc_files pipelined parallel_enable is
    
    lFile t_mcsf_api_order_doc_file;
    
  begin
    
    for lCursor in (select dstr_id as file_id,
                       file_name,
                       dbms_lob.getlength(doc_data) as file_size
                  from doc_stores
                 where dcmt_dcmt_id = pDocId
                 order by dstr_id) loop
                 
      lFile := t_mcsf_api_order_doc_file(
            lCursor.file_id,
            lCursor.file_name,
            lCursor.file_size
      );
      
      pipe row(lFile);
     
    end loop;
  end;
  
 /*
  Возвращает список id заказов для инфойса
  */
  function GetInvoiceOrderIds(pInvoiceId invoices.invc_id%type) return tbl_mcsf_api_order_ids pipelined parallel_enable is
  begin
    
    for lCursor in (select t.ord_ord_id from invoice_details t where t.invc_invc_id = pInvoiceId) loop
      
      pipe row(lCursor.ord_ord_id);
     
    end loop;
  end;
  
end MCSF_API_HELPER;
/
