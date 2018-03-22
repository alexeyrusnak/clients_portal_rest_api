CREATE OR REPLACE TYPE T_MCSF_API_ORDER_DOC force
 as object (
  id number(10),                       -- �������������
  order_id number(10),                 -- ������������� ������
  type_id  number(5),                  -- ������������� ���� ���������
  doc_type varchar2(1000),             -- ������������ ���� ���������
  doc_date date,                       -- ���� ���������
  uploaded_at date,                    -- ���� �������� ���������
  owner varchar2(100),                  -- �������� ��������� 
  files tbl_mcsf_api_order_doc_files
 )
/
