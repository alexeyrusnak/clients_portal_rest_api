create or replace type t_mcsf_api_invoice force as object
(
  id              number,                      -- ���������� ������������� �����
  total           number,                      -- ����� �����, �� ������� ��������� ����
  paid            number,                      -- �����, ���������� �� �����
  pay_to          date,                        -- ����, � ������� ����� �������� �������������
  currency        varchar2(100),               -- ������
  orders          tbl_mcsf_api_order_ids       -- ������ ��������������� �������, ���������� � ���� ������
);
/
