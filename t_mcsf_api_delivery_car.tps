create or replace type t_mcsf_api_delivery_car force as object
(
  driver_fio      varchar2(100),               -- ��� ��������
  car_number      varchar2(100),               -- ����� ����������
  driver_phone    varchar2(100)               -- ������� ��������
)
/
