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
  function GetDocFiles(pDocId number default null, 
                       pFileId number default null,
                       pOrderId number default null,
                       pContent number default 0) 
    return tbl_mcsf_api_order_doc_files pipelined parallel_enable;
  
  /*
  Возвращает список id заказов для инфойса
  */
  function GetInvoiceOrderIds(pInvoiceId invoices.invc_id%type) return tbl_mcsf_api_order_ids pipelined parallel_enable;
  
  /*
  Проверяет принадлежность заказа клиенту
  */
  function CheckOwnerOrder(pId t_orders.ord_id%type, pClntId clients_dic.clnt_id%type) return boolean;
  
  function decode_base64(p_clob_in in clob) return blob;

  function encode_base64(p_blob_in in blob) return clob;

end MCSF_API_HELPER;
/
create or replace package body MCSF_API_HELPER is

  /*
  Возвращает список файлов документа
  */
  function GetDocFiles(pDocId number default null, 
                       pFileId number default null,
                       pOrderId number default null,
                       pContent number default 0) 
    return tbl_mcsf_api_order_doc_files pipelined parallel_enable is
    
    lFile t_mcsf_api_order_doc_file;
    
  begin
    
    if pDocId is null and pFileId is null and pOrderId is null then
      return;
    end if;
  
    for lCursor in (select dstr_id as file_id,
                       file_name,
                       dbms_lob.getlength(doc_data) as file_size,
                       doc_data
                  from doc_stores t
                 where (case when pDocId is null then 1 when pDocId is not null and t.dcmt_dcmt_id = pDocId then 1 else 0 end) = 1
                 and (case when pFileId is null then 1 when pFileId is not null and t.dstr_id = pFileId then 1 else 0 end) = 1
                 and (case when pOrderId is null then 1 when pOrderId is not null and t.dcmt_dcmt_id in (select dl.dcmt_dcmt_id from doc_links dl where dl.ord_ord_id = pOrderId) then 1 else 0 end) = 1
                 order by t.dstr_id) loop
                 
      if pContent = 1 then
        lFile := t_mcsf_api_order_doc_file(lCursor.file_id, lCursor.file_name, lCursor.file_size, encode_base64(lCursor.doc_data));
      else
        lFile := t_mcsf_api_order_doc_file(lCursor.file_id, lCursor.file_name, lCursor.file_size, null);
      end if;
      
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
  
  /*
  Проверяет принадлежность заказа клиенту
  */
  function CheckOwnerOrder(pId t_orders.ord_id%type, pClntId clients_dic.clnt_id%type) return boolean is
    
    ClntRqstId client_requests.clnt_clnt_id%type;
    
  begin
    
    select cl.clnt_clnt_id
      into ClntRqstId
      from client_requests cl, clrq_orders co
     where co.ord_ord_id = pId
       and cl.clrq_id = co.clrq_clrq_id;
    
    if ClntRqstId = pClntId then
      return true;
    else
      return false;
    end if;
    
  exception
    when no_data_found then
      return false;
      
  end;
  
  function decode_base64(p_clob_in in clob) return blob is
    v_blob blob;
    v_result blob;
    v_offset integer;
    v_buffer_size binary_integer := 48;
    v_buffer_varchar varchar2(48);
    v_buffer_raw raw(48);
  begin
    if p_clob_in is null then
      return null;
    end if;
    dbms_lob.createtemporary(v_blob, true);
    v_offset := 1;
    for i in 1 .. ceil(dbms_lob.getlength(p_clob_in) / v_buffer_size) loop
      dbms_lob.read(p_clob_in, v_buffer_size, v_offset, v_buffer_varchar);
      v_buffer_raw := utl_raw.cast_to_raw(v_buffer_varchar);
      v_buffer_raw := utl_encode.base64_decode(v_buffer_raw);
      dbms_lob.writeappend(v_blob, utl_raw.length(v_buffer_raw), v_buffer_raw);
      v_offset := v_offset + v_buffer_size;
    end loop;
    v_result := v_blob;
    dbms_lob.freetemporary(v_blob);
    return v_result;
  end decode_base64;

  function encode_base64(p_blob_in in blob) return clob is
    v_clob clob;
    v_result clob;
    v_offset integer;
    v_chunk_size binary_integer := (48 / 4) * 3;
    v_buffer_varchar varchar2(48);
    v_buffer_raw raw(48);
  begin
    if p_blob_in is null then
      return null;
    end if;
    dbms_lob.createtemporary(v_clob, true);
    v_offset := 1;
    for i in 1 .. ceil(dbms_lob.getlength(p_blob_in) / v_chunk_size) loop
      dbms_lob.read(p_blob_in, v_chunk_size, v_offset, v_buffer_raw);
      v_buffer_raw := utl_encode.base64_encode(v_buffer_raw);
      v_buffer_varchar := utl_raw.cast_to_varchar2(v_buffer_raw);
      dbms_lob.writeappend(v_clob, length(v_buffer_varchar), v_buffer_varchar);
      v_offset := v_offset + v_chunk_size;
    end loop;
    v_result := v_clob;
    dbms_lob.freetemporary(v_clob);
    return v_result;
  end encode_base64;
  
end MCSF_API_HELPER;
/
