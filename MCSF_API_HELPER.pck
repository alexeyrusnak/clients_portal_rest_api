create or replace package MCSF_API_HELPER is

  -- �������� � ��������� ��� ������
  
  /*
  ��� order_doc_rec
  */
  type t_mcsf_api_order_doc_rec is record(
        id documents.dcmt_id%type,            -- ������������� ���������
        order_id doc_links.ord_ord_id%type,   -- ������������� ������
        type_id doc_types_dic.dctp_id%type,   -- ������������� ���� ���������
        doc_type doc_types.def%type,          -- ������������ ���� ���������
        doc_date documents.doc_date%type,     -- ���� ���������
        uploaded_at documents.navi_date%type, -- ���� ��������
        owner documents.navi_user%type        -- �������� ���������
   );
   
   /*
  ��� order_doc_rec
  */
  type t_mcsf_api_order_doc_file_rec is record(
       id number,
       file_name varchar2(255),
       file_size number
  );
  
  /*
  ���������� ������ ������ ���������
  */
  function GetDocFiles(pDocId doc_stores.dcmt_dcmt_id%type) return tbl_mcsf_api_order_doc_files pipelined parallel_enable;
  
  /*
  ���������� ������ id ������� ��� �������
  */
  function GetInvoiceOrderIds(pInvoiceId invoices.invc_id%type) return tbl_mcsf_api_order_ids pipelined parallel_enable;
  
  /*
  ��������� �������������� ������ �������
  */
  function CheckOwnerOrder(pId t_orders.ord_id%type, pClntId clients_dic.clnt_id%type) return boolean;

end MCSF_API_HELPER;
/
create or replace package body MCSF_API_HELPER is

  /*
  ���������� ������ ������ ���������
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
  ���������� ������ id ������� ��� �������
  */
  function GetInvoiceOrderIds(pInvoiceId invoices.invc_id%type) return tbl_mcsf_api_order_ids pipelined parallel_enable is
  begin
    
    for lCursor in (select t.ord_ord_id from invoice_details t where t.invc_invc_id = pInvoiceId) loop
      
      pipe row(lCursor.ord_ord_id);
     
    end loop;
  end;
  
  /*
  ��������� �������������� ������ �������
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
  
end MCSF_API_HELPER;
/
