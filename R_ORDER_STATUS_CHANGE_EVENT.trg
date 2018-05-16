CREATE OR REPLACE TRIGGER R_ORDER_STATUS_CHANGE_EVENT

/******************************************************************************
   NAME:       R_ORDER_STATUS_CHANGE_EVENT
   PURPOSE: Триггер для отпавки сообщений клиентам об изменении статуса заказа

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        27.01.2018  R-abik           Создан триггер.
   1.1        14.05.2018  R-abik           Рассылка всем контактам из карточки
   1.2        15.05.2018  R-abik           Устранение дублирования, если статус не изменился

******************************************************************************/

  BEFORE INSERT ON ORST_HISTORIES
  FOR EACH ROW

DECLARE
  lHoldId number;
  lClntId number;
  lOrdNumber varchar2(150);
  lOrdFreightDef varchar2(200);
  
  lMessTplDef varchar2(200) := 'Изменение статуса заказа <номер заявки>';
  lMessTplDef02 varchar2(200) := 'Заявка <номер заявки> принята в работу';
  
  lMess   varchar2(2000);
  lMessSubject varchar2(2000);

  lOrdId number;

  lOldOrstId number;
  lNewOrstId number;

  lOldStatusDef varchar2(200);
  lNewStatusDef varchar2(200);
  
  lArrTemp t_infinity_str;

BEGIN
  
  begin
    
    -- ИД нового статуса
    lNewOrstId := :new.orst_orst_id;
    
    -- Если новый статус заявки - 01, то ничего не отправляем
   if lNewOrstId = 1 then
      return;
   end if;
  
    -- ИД заказа
    lOrdId := :new.ord_ord_id;
    
    -- ИД предыдущего статуса
    begin
      select tt.orst_orst_id
        into lOldOrstId
        from (select t.*, max(t.orhs_id) over() as max_orhs_id
                from orst_histories t where t.ord_ord_id = lOrdId) tt
       where tt.orhs_id = max_orhs_id;
    exception
      when others then
        lOldOrstId := null;
    end;
    
    -- Если статус по факту не изменился, ничего не отправляем
    if lOldOrstId = lNewOrstId then
      return;
    end if;
  
    -- ИД холдинга
    select min(h.hold_id)
      into lHoldId
      from holding_dic h
     where h.del_date is null;
  
    -- ИД клиента
    select o.clnt_clnt_id into lClntId from orders o where o.ord_id = lOrdId;
       
    -- Номер заявки клиента
   select o.internal_number, fr.def
     into lOrdNumber, lOrdFreightDef
     from orders o, vOrd_Frgt vofr, freights fr
    where o.ord_id = lOrdId
      and o.ord_id = vofr.ord_ord_id(+)
      and vofr.frgt_frgt_id = fr.frgt_id(+);
      
   -- Если новый статус заявки - 02, то отдельный шаблон
   if lNewOrstId = 2 then
      lMessTplDef := lMessTplDef02;
   end if;
   
    -- Шаблон сообщения
    begin
      select t.def, t.messages_text
        into lMessSubject, lMess
        from templates_messages t, message_subscriptions ms
       where ms.tm_tm_id = t.tm_id
         and ms.clnt_clnt_id = lClntId
         and ms.del_user is null
         and ms.del_date is null
         and t.def = lMessTplDef;
    exception
      when others then
        -- Если нет шаблона или нет подписки на шаблон, выходим
        return;
    end;
    
    -- Предыдущий статус
    begin
      select t.def
        into lOldStatusDef
        from order_statuses t
       where t.orst_id = lOldOrstId;
    exception
      when others then
        lOldStatusDef := null;
    end;
    
    -- Удаляем лишний текст в статусе
    begin
      
      lArrTemp := r_helper.splitstring(lOldStatusDef,'-');
      
      if lArrTemp is not null then
        lOldStatusDef := lArrTemp(lArrTemp.LAST);
      end if;
      
    exception
      when others then
        null;
    end;
  
    -- Новый статус
    begin
      select t.def
        into lNewStatusDef
        from order_statuses t
       where t.orst_id = lNewOrstId;
    exception
      when others then
        lNewStatusDef := null;
    end;
    
    -- Удаляем лишний текст в статусе
    begin
      
      lArrTemp := r_helper.splitstring(lNewStatusDef,'-');
      
      if lArrTemp is not null then
        lNewStatusDef := lArrTemp(lArrTemp.LAST);
      end if;
      
    exception
      when others then
        null;
    end;
    
    -- Подготовка сообщения и темы
    lMessSubject := replace(lMessSubject, '<номер заявки>', lOrdNumber);
    
    lMess := replace(lMess, '<дата>', to_char(sysdate, 'dd.mm.yyyy'));
    lMess := replace(lMess, '<номер заявки>', lOrdNumber);
    lMess := replace(lMess, '<старый статус>', lOldStatusDef);
    lMess := replace(lMess, '<новый статус>', lNewStatusDef);
    lMess := replace(lMess, '<груз>', lOrdFreightDef);
    
    -- Запись сообщения в таблицу для рассылки
      insert into messages2customers
        (mscm_id,
         message_date,
         send_to,
         clnt_clnt_id,
         message_text,
         message_thema,
         ord_ord_id,
         delivery_type,
         hold_hold_id,
         send_date,
         store_days,
         event_id)
      values
        (mscm_seq.nextval,
         sysdate,
         'should be filled from order',
         lClntId,
         lMess,
         lMessSubject,
         lOrdId,
         0,
         lHoldId,
         null,
         3,
         lNewOrstId);
         
  exception
    when others then
      ins_sys_logs(ApplId   => SBC_MESSAGE.SET_ApplId,
                   Message  => 'R_ORDER_STATUS_CHANGE_EVENT' || SQLERRM,
                   IsCommit => FALSE);
  end;

END R_ORDER_STATUS_CHANGE_EVENT;
/
