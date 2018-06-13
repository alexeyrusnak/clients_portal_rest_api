CREATE OR REPLACE TRIGGER R_ORDER_STATUS_CHANGE_EVENT

/******************************************************************************
   NAME:       R_ORDER_STATUS_CHANGE_EVENT
   PURPOSE: ������� ��� ������� ��������� �������� �� ��������� ������� ������

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        27.01.2018  R-abik           ������ �������.
   1.1        14.05.2018  R-abik           �������� ���� ��������� �� ��������
   1.2        15.05.2018  R-abik           ���������� ������������, ���� ������ �� ���������
   1.3        23.05.2018  R-abik           ����������� ���������� ���������� ��������, ����������� �������� ����, ��������� ���� ���-�� � ��.���
   1.4        13.06.2018  R-abik           ��������� ���� <���������>

******************************************************************************/

  BEFORE INSERT ON ORST_HISTORIES
  FOR EACH ROW

DECLARE
  lHoldId number;
  lClntId number;
  lOrdNumber varchar2(150);
  lOrdFreightDef varchar2(200);
  lOrdFreightQuantity number;
  lOrdFreightUnit varchar2(50);
  lOrdContainer varchar2(100);

  lMessTplDefCode11 varchar2(11) := '[R_OSE_1_1]'; --������ <����� ������> ������� � ������
  lMessTplDefCode21 varchar2(11) := '[R_OSE_2_1]'; --��������� ������� ������ <����� ������>

  lMessTplDefCode12 varchar2(11) := '[R_OSE_1_2]'; --������ <����� ������> � ������  '<����>' ������� � ������
  lMessTplDefCode22 varchar2(11) := '[R_OSE_2_2]'; --��������� ������� ������ <����� ������> � ������  '<����>'

  lMessTplDefSearchCodes t_infinity_str := t_infinity_str();

  lMess   varchar2(4000);
  lMessSubject varchar2(4000);

  lOrdId number;

  lOldOrstId number;
  lNewOrstId number;

  lOldStatusDef varchar2(200);
  lNewStatusDef varchar2(200);

  lArrTemp t_infinity_str;

BEGIN

  begin

    -- �� ������ �������
    lNewOrstId := :new.orst_orst_id;

    -- ���� ����� ������ ������ - 01, �� ������ �� ����������
   if lNewOrstId = 1 then
      return;
   end if;

    -- �� ������
    lOrdId := :new.ord_ord_id;

    -- �� ����������� �������
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

    -- ���� ������ �� ����� �� ���������, ������ �� ����������
    if lOldOrstId = lNewOrstId then
      return;
    end if;

    -- �� ��������
    select min(h.hold_id)
      into lHoldId
      from holding_dic h
     where h.del_date is null;

    -- �� �������
    select o.clnt_clnt_id into lClntId from orders o where o.ord_id = lOrdId;

    -- ����� ������ �������
   select o.internal_number, fr.def, ofr.quantity, u.short_name
     into lOrdNumber, lOrdFreightDef, lOrdFreightQuantity, lOrdFreightUnit
     from orders o,
          vOrd_Frgt vofr,
          freights fr,
          order_freights ofr,
          units u
    where o.ord_id = lOrdId
      and o.ord_id = vofr.ord_ord_id(+)
      and vofr.frgt_frgt_id = fr.frgt_id(+)
      and vofr.ordfr_id = ofr.ordfr_id(+)
      and ofr.unit_unit_id = u.unit_id(+);


   -- ���� ����� ������ ������ - 02, �� ��������� ������
   if lNewOrstId = 2 then
      lMessTplDefSearchCodes.Extend;
      lMessTplDefSearchCodes(lMessTplDefSearchCodes.Count) := lMessTplDefCode11;
      lMessTplDefSearchCodes.Extend;
      lMessTplDefSearchCodes(lMessTplDefSearchCodes.Count) := lMessTplDefCode12;
   else
      lMessTplDefSearchCodes.Extend;
      lMessTplDefSearchCodes(lMessTplDefSearchCodes.Count) := lMessTplDefCode21;
      lMessTplDefSearchCodes.Extend;
      lMessTplDefSearchCodes(lMessTplDefSearchCodes.Count) := lMessTplDefCode22;
   end if;

    -- ������ ���������
    begin
      select substr(t.def, 12), t.messages_text
        into lMessSubject, lMess
        from templates_messages t, message_subscriptions ms
       where ms.tm_tm_id = t.tm_id
         and ms.clnt_clnt_id = lClntId
         and ms.del_user is null
         and ms.del_date is null
         and (t.def like lMessTplDefSearchCodes(1) || '%' or t.def like lMessTplDefSearchCodes(2) || '%')
         and rownum = 1;
    exception
      when others then
        -- ���� ��� ������� ��� ��� �������� �� ������, �������
        return;
    end;

    -- ���������� ������
    begin
      select t.def
        into lOldStatusDef
        from order_statuses t
       where t.orst_id = lOldOrstId;
    exception
      when others then
        lOldStatusDef := null;
    end;

    -- ������� ������ ����� � �������
    begin

      lArrTemp := r_helper.splitstring(lOldStatusDef,'-');

      if lArrTemp is not null then
        lOldStatusDef := lArrTemp(lArrTemp.LAST);
      end if;

    exception
      when others then
        null;
    end;

    -- ����� ������
    begin
      select t.def
        into lNewStatusDef
        from order_statuses t
       where t.orst_id = lNewOrstId;
    exception
      when others then
        lNewStatusDef := null;
    end;

    -- ������� ������ ����� � �������
    begin

      lArrTemp := r_helper.splitstring(lNewStatusDef,'-');

      if lArrTemp is not null then
        lNewStatusDef := lArrTemp(lArrTemp.LAST);
      end if;

    exception
      when others then
        null;
    end;
    
    -- ���������
    begin
      select cn.cont_index || cn.cont_number
        into lOrdContainer
        from orders o, conteiners cn
       where o.ord_id = lOrdId
         and cn.cont_id(+) = o.cont_cont_id;
    exception
      when others then
        lOrdContainer := null;
    end;
    if  lOrdContainer is null then
       begin
          select cont_index || cont_number
            into lOrdContainer
            from order_ways
           where ord_ord_id = lOrdId and orws_type=1 ;
       exception
          when others then
              lOrdContainer := '';
       end;
    end if;

    -- ���������� ��������� � ����
    lMessSubject := replace(lMessSubject, '<����>', to_char(sysdate, 'dd.mm.yyyy'));
    lMessSubject := replace(lMessSubject, '<����� ������>', lOrdNumber);
    lMessSubject := replace(lMessSubject, '<������ ������>', lOldStatusDef);
    lMessSubject := replace(lMessSubject, '<����� ������>', lNewStatusDef);
    lMessSubject := replace(lMessSubject, '<����>', lOrdFreightDef);
    lMessSubject := replace(lMessSubject, '<���-��>', lOrdFreightQuantity);
    lMessSubject := replace(lMessSubject, '<��.���>', lOrdFreightUnit);
    lMessSubject := replace(lMessSubject, '<���������>', lOrdContainer);

    lMess := replace(lMess, '<����>', to_char(sysdate, 'dd.mm.yyyy'));
    lMess := replace(lMess, '<����� ������>', lOrdNumber);
    lMess := replace(lMess, '<������ ������>', lOldStatusDef);
    lMess := replace(lMess, '<����� ������>', lNewStatusDef);
    lMess := replace(lMess, '<����>', lOrdFreightDef);
    lMess := replace(lMess, '<���-��>', lOrdFreightQuantity);
    lMess := replace(lMess, '<��.���>', lOrdFreightUnit);
    lMess := replace(lMess, '<���������>', lOrdContainer);

    -- ������ ��������� � ������� ��� ��������
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
