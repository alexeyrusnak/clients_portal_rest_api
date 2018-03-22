CREATE OR REPLACE TYPE T_MCSF_API_ORDER_DOC force
 as object (
  id number(10),                       -- Идентификатор
  order_id number(10),                 -- идентификатор заказа
  type_id  number(5),                  -- Идентификатор типа документа
  doc_type varchar2(1000),             -- Наименование типа документа
  doc_date date,                       -- Дата документа
  uploaded_at date,                    -- Дата загрузки документа
  owner varchar2(100),                  -- Владелец документа 
  files tbl_mcsf_api_order_doc_files
 )
/
