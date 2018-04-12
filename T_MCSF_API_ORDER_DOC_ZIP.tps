CREATE OR REPLACE TYPE T_MCSF_API_ORDER_DOC_ZIP FORCE AS OBJECT (
  file_name varchar2(255),                       -- Имя файла
  file_size  number(10),                         -- Размер файла в байтах
  content blob                                   -- Zip содержимое
)
/
