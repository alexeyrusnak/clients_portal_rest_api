CREATE OR REPLACE TYPE T_MCSF_API_ORDER_DOC_FILE FORCE AS OBJECT (
  id number(10),                                 -- ID �����
  file_name varchar2(255),                       -- ��� �����
  file_size  number(10),                          -- ������ ����� � ������
  content clob
 )
/
