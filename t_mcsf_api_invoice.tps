create or replace type t_mcsf_api_invoice force as object
(
  id              number,                      -- Уникальный идентификатор счета
  total           number,                      -- Общая сумма, на которую выставлен счет
  paid            number,                      -- Сумма, оплаченная по счету
  pay_to          date,                        -- Дата, к которой нужно погасить задолженность
  currency        varchar2(100),               -- Валюта
  orders          tbl_mcsf_api_order_ids       -- Массив идентификаторов заказов, включенных в этот инвойс
);
/
