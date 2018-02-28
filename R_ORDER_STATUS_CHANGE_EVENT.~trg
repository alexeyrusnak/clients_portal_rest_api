CREATE OR REPLACE TRIGGER R_ORDER_STATUS_CHANGE_EVENT

/******************************************************************************
   NAME:       R_ORDER_STATUS_CHANGE_EVENT
   PURPOSE: Триггер для отпавки сообщений клиентам об изменении статуса заказа

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        27.01.2018  R-abik           1. Создан триггер.

******************************************************************************/

  BEFORE INSERT OR UPDATE OF ORST_ORST_ID ON ORST_HISTORIES
  FOR EACH ROW

DECLARE
  lHoldId number;
  lEmail  varchar2(100);
  lClntId number;
  lOrdNumber varchar2(150);
  lOrdFreightDef varchar2(200);
  
  lMessTplDef varchar2(200) := 'Изменение статуса заказа';
  lMessTplDef02 varchar2(200) := 'Заявка принята в работу';
  
  lMess   varchar2(2000);
  lMessSubject varchar2(2000);

  lOrdId number;

  lOldOrstId number;
  lNewOrstId number;

  lOldStatusDef varchar2(200);
  lNewStatusDef varchar2(200);

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
  
    -- ИД холдинга
    select min(h.hold_id)
      into lHoldId
      from holding_dic h
     where h.del_date is null;
  
    -- Почтовый ящик и ИД клиента
    select cl.email, o.clnt_clnt_id
      into lEmail, lClntId
      from client_contacts cl, orders o
     where o.ord_id = lOrdId
       and cl.clcn_id(+) = o.clcn_clcn_id;
       
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
      select t.subject, t.message_text
        into lMessSubject, lMess
        from event_templates t
       where t.def = lMessTplDef;
    exception
      when others then
        ins_sys_logs(ApplId   => SBC_MESSAGE.SET_ApplId,
                     Message  => 'R_ORDER_STATUS_CHANGE_EVENT - Не найден шаблон сообщения',
                     IsCommit => FALSE);
        return;
    end;
  
    -- ИД предыдущего статуса
    begin
      select tt.orst_orst_id
        into lOldOrstId
        from (select t.*, max(t.orhs_id) over() as max_orhs_id
                from orst_histories t) tt
       where tt.orhs_id = max_orhs_id;
    exception
      when others then
        lOldOrstId := null;
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
    
    -- Подготовка сообщения и темы
    lMessSubject := replace(lMessSubject, '<номер заявки>', lOrdNumber);
    
    lMess := replace(lMess, '<дата>', to_char(sysdate, 'dd.mm.yyyy hh24:mi'));
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
       lEmail,
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

  /*
  CREATE TRIGGER UPD_TMTB_MES_KONOSAMENTS2
  BEFORE INSERT OR UPDATE OF POT_DATE
    ON KONOSAMENTS
  FOR EACH ROW
    declare
    V_HOLD_HOLD_ID number;
    V_EMAIL        varchar2(100);
    V_CLNT_CLNT_ID number;
    mess           varchar2(2000);
    Str            varchar2(100);
  begin
    -- Строка выключения триггера при репликации
    if dbms_reputil.from_remote = true then
      return;
    end if;
    ----********* Вставка для сообщения
  
    if :new.pot_date is not null then
  
      select MIN(H.HOLD_ID)
        into V_HOLD_HOLD_ID
        from HOLDING_DIC H
       where h.DEL_DATE is null;
  
      for cur in (select o.ord_id, con.cont_index, con.cont_number
                    from orders o, knor_ord kd, knsm_orders ko, conteiners con
                   where o.ord_id = kd.ord_ord_id(+)
                     and kd.knor_knor_id = ko.knor_id(+)
                     and ko.knsm_knsm_id = :new.knsm_id
                     and o.cont_cont_id = con.cont_id) loop
        BEGIN
  
          begin
            --- Поиск почтового ящика
            SELECT CL.EMAIL, O.CLNT_CLNT_ID
              INTO V_EMAIL, V_CLNT_CLNT_ID -- Почта , клиент
              FROM CLIENT_CONTACTS CL, ORDERS O
             WHERE O.ORD_ID = cur.ord_id
               AND CL.CLCN_ID(+) = O.CLCN_CLCN_ID;
            begin
              select d.def
                into str
                from cities d
               where d.city_id = :new.city_pot_id;
            exception
              when others then
                Str := 'не указан';
            END;
            Mess := 'Контейнер ' || cur.cont_index || ' ' || cur.cont_number ||
                    ' прибыл в порт перегрузки ' || str || '  ' ||
                    to_char(:new.pot_date, 'dd.mm.yyyy');
  
            insert into messages2customers
              (mscm_id, message_date, send_to, clnt_clnt_id, message_text,
               ord_ord_id, delivery_type, hold_hold_id, send_date, store_days,
               event_id)
            values
              (mscm_seq.nextval, sysdate, V_EMAIL, V_CLNT_CLNT_ID, Mess,
               cur.ord_id, 0, V_HOLD_HOLD_ID, null, 3, 21);
          exception
            when others then
              ins_sys_logs(ApplId => SBC_MESSAGE.SET_ApplId,
                           Message => 'UPD_TMTB_MES_KONOSAMENTS2' || SQLERRM,
                           IsCommit => False);
          end;
  
        EXCEPTION
          WHEN OTHERS THEN
            ins_sys_logs(ApplId => SBC_MESSAGE.SET_ApplId,
                         Message => 'UPD_TMTB_MES_KONOSAMENTS2' || SQLERRM,
                         IsCommit => False);
        END;
  
      end loop;
    end if;
  end UPD_TMTB_MES_KONOSAMENTS2;
  */

END R_ORDER_STATUS_CHANGE_EVENT;
/
