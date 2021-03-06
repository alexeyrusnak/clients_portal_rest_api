create or replace package REST_API_HELPER is

  /*
  ������� ������ T_DOC � JSON
  */
 -- 26.11.17 procedure PrintT_DOC(pDoc in T_DOC);
-- procedure PrintT_DOC(pDoc in mcsf_api.t_docs);

  /*
  ��������� ������ ���������� �� ������
  27.11.2017  A.Starshinin
  */
  
  /*
  ������� ������ T_FILE � JSON
  */
  procedure PrintT_FILE(pFile in t_mcsf_api_order_doc_file, pContent boolean default false);
    
  /*
  ������� ������ T_DOCS � JSON
  */
  procedure PrintT_DOC(pDoc in t_mcsf_api_order_doc);

  /*
  ������� ������ T_DOCS � JSON
  */
  procedure PrintT_DOCS_depricated(pDoc in mcsf_api.t_doc);

  /*
  ������� ������ T_UNIT � JSON
  */
  procedure PrintT_UNIT(pUnit in t_mcsf_api_unit);

  /*
  ������� ������ T_POINT � JSON
  */
  procedure PrintT_POINT(pPoint in T_POINT);

  /*
  ������� ������ T_CARGO � JSON
  */
  procedure PrintT_CARGO(pCargo in T_CARGO);
 
  /*
  ������� ������ T_RUMMAGE � JSON
  */
  procedure PrintT_RUMMAGE(pRummage in t_mcsf_api_rummage);
  
  /*
  ������� ������ T_INVOICES � JSON
  */
  procedure PrintT_INVOICE(pInvoice in t_mcsf_api_invoice);
  
  /*
  ������� ������ T_DELIVERY_CAR � JSON
  */
  procedure PrintT_DELIVERY_CAR(pDeliveryCar in t_mcsf_api_delivery_car);
  
  /*
  ������� ������ T_CONTRACTOR_SHORT � JSON
  */
  procedure PrintT_CONTRACTOR_SHORT(pContractor in t_mcsf_api_contractor_short);
  
-- �.�. 21.06.2017
procedure PrintT_FILES_depricated(p_files in mcsf_api.t_files);
  
-- �.�. 21.06.2017
-- ����������� ���������� SQL �������
function make_filter_string_depricated(
    p_col varchar2 -- Column Name
  , p_type varchar2 -- ('=', '!=', '>', '<', '>=', '<=', 'like', 'between')
  , p_value varchar2 -- CSV (,)
) return varchar2; -- ... where ... and <return>; check for 'Error%':
-- Error: No Column Name
-- Error: Wrong Type
-- Error: No Value
-- Error: Wrong Type/Value combination

function IsDate(pTestStrin varchar, pFormat out varchar) return boolean;

function PrepareSortFilter(pFilterName varchar, pFileldName varchar default null) return varchar2;

function PrepareSqlFilter(pFilterName varchar, pFileldName varchar default null) return varchar2;

procedure AddFilter(pFilterName varchar, pFileldName varchar default null, pFilters in out varchar2);

procedure AddSortFilter(pFilterName varchar, pFileldName varchar default null, pFilters in out varchar2);

procedure SaveLog(pLog clob);

function ClobToVarcharTable(pClob clob) return apex_application_global.vc_arr2;
 
end REST_API_HELPER;
/
create or replace package body REST_API_HELPER is

  /*
  ������� ������ T_DOC � JSON
  */
  --procedure PrintT_DOC(pDoc in T_DOC) is
  /*
  procedure PrintT_DOC(pDoc in mcsf_api.t_docs) is
  begin
     26.11.17
    apex_json.write('id', pDoc.id, true);
    apex_json.write('name', pDoc.name, true);
    apex_json.write('url', pDoc.url, true);
    apex_json.write('ext', pDoc.ext, true);
    apex_json.write('size_doc', pDoc.size_doc, true);
    apex_json.write('date_doc',
                    to_char(pDoc.date_doc, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('uploaded_at',
                    to_char(pDoc.uploaded_at, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('owner', pDoc.owner, true);

    apex_json.write('id', pDoc.id, true);
    apex_json.write('order_id', pDoc.order_id, true);
    apex_json.write('type_id', pDoc.type_doc, true);
    apex_json.write('type', pDoc.name_doc, true);
    apex_json.write('date',
                    to_char(pDoc.date_doc, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('uploaded_at',
                    to_char(pDoc.uploaded_at, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('owner', pDoc.owner, true);
     
  end;
*/

  /*
  ������� ������ T_FILE � JSON
  */
  procedure PrintT_FILE(pFile in t_mcsf_api_order_doc_file, pContent boolean default false) is
  begin
    apex_json.write('id', pFile.id, true);
    apex_json.write('name', pFile.file_name, true);
    apex_json.write('size', pFile.file_size, true);
    
    if pContent then
      apex_json.write('content', pFile.content, true);
    end if;
  end;
  
  /*
  ������� ������ T_DOC � JSON
  */
  procedure PrintT_DOC(pDoc in t_mcsf_api_order_doc) is
  begin
    apex_json.write('id', pDoc.id, true);
    apex_json.write('order_id', pDoc.order_id, true);
    apex_json.write('type_id', pDoc.type_id, true);
    apex_json.write('type', pDoc.doc_type, true);
    apex_json.write('date', to_char(pDoc.doc_date, REST_API.PkgDefaultDateFormat), true);
    apex_json.write('uploaded_at', to_char(pDoc.uploaded_at, REST_API.PkgDefaultDateFormat), true);
    apex_json.write('owner', pDoc.owner, true);
    
    apex_json.open_array('files');
    
    for elem in 1 .. pDoc.files.count loop
      apex_json.open_object;
      PrintT_FILE(pDoc.files(elem));
      apex_json.close_object;
    end loop;
    
    apex_json.close_array;
 end;

 /*
  ������� ������ T_DOCS � JSON
  */
  procedure PrintT_DOCS_depricated(pDoc in mcsf_api.t_doc) is
  begin
    apex_json.write('id', pDoc.id, true);
    apex_json.write('order_id', pDoc.order_id, true);
    apex_json.write('type_id', pDoc.type_id, true);
    apex_json.write('type', pDoc.doc_type, true);
    apex_json.write('date', to_char(pDoc.doc_date, REST_API.PkgDefaultDateFormat),true);
    apex_json.write('uploaded_at', to_char(pDoc.uploaded_at, REST_API.PkgDefaultDateFormat),true);
    apex_json.write('owner', pDoc.owner, true);
  end;

  /*
  ������� ������ T_UNIT � JSON
  */
  procedure PrintT_UNIT(pUnit in t_mcsf_api_unit) is
  begin
    apex_json.write('type', pUnit.type_unit, true);
    /*
    apex_json.write('transport', pUnit.transport, true);
    apex_json.write('comment_unit', pUnit.comment_unit, true);
    apex_json.write('conditions', pUnit.conditions, true);
    apex_json.write('notes', pUnit.notes, true);
    apex_json.write('is_insurance', pUnit.is_insurance, true);
  
    -- cargoes[]
    apex_json.open_array('payload');
  
    for elem in 1 .. pUnit.payload.count loop
      apex_json.open_object;
      PrintT_CARGO(pUnit.payload(elem));
      apex_json.close_object;
    end loop;
    */
  --  apex_json.close_array;
  
 --   apex_json.write('delivery_point', pUnit.delivery_point, true);
  end;

  /*
  ������� ������ T_POINT � JSON
  */
  procedure PrintT_POINT(pPoint in T_POINT) is
  begin
    apex_json.write('id', pPoint.id, true);
    apex_json.write('address', pPoint.address, true);
    apex_json.write('phone', pPoint.phone, true);
    apex_json.write('email', pPoint.email, true);
    apex_json.write('name', pPoint.name, true);
    apex_json.write('unit_count', pPoint.unit_count, true);
  end;

  /*
  ������� ������ T_CARGO � JSON
  */
  procedure PrintT_CARGO(pCargo in T_CARGO) is
  begin
  
    apex_json.write('name', pCargo.name, true);
    /*
    apex_json.write('brutto', pCargo.brutto, true);
    apex_json.write('netto', pCargo.netto, true);
    apex_json.write('cost_cargo', pCargo.cost_cargo, true);
    apex_json.write('currency_code', pCargo.currency_code, true);
    apex_json.write('volume', pCargo.volume, true);
    --   apex_json.write('hazard_class', pCargo.hazard_class, true);
    --   apex_json.write('temperature', pCargo.temperature, true);
    --   apex_json.write('places_count', pCargo.places_count, true);
    apex_json.write('size_cargo', pCargo.size_cargo, true);
    --   apex_json.write('made', pCargo.made);
    apex_json.write('nareadinessme',
                    to_char(pCargo.readiness, REST_API.PkgDefaultDateFormat),
                    true);
    apex_json.write('ref_ord', pCargo.ref_ord);
  
    -- cargo delivery point
    apex_json.open_object('delivery_point');
  
    for elem in 1 .. pCargo.delivery_point.count loop
      PrintT_POINT(pCargo.delivery_point(elem));
    end loop;
    */
  --  apex_json.close_object;
  
  end;
  
  /*
  ������� ������ T_RUMMAGE � JSON
  */
  procedure PrintT_RUMMAGE(pRummage in t_mcsf_api_rummage) is
  begin
    apex_json.write('type_rummage',pRummage.type_rummage, true);          
    apex_json.write('date_rummage',to_char(pRummage.date_rummage, REST_API.PkgDefaultDateFormat), true);
  end;
  
  /*
  ������� ������ T_INVOICES � JSON
  */
  procedure PrintT_INVOICE(pInvoice in t_mcsf_api_invoice) is
  begin
    apex_json.write('id', pInvoice.id, true);
    apex_json.write('total', pInvoice.total, true);
    apex_json.write('paid', pInvoice.paid, true);
    apex_json.write('pay_to', to_char(pInvoice.pay_to, REST_API.PkgDefaultDateFormat), true);
    apex_json.write('currency', pInvoice.currency, true);
    
    apex_json.open_array('orders');
    
    for elem in 1 .. pInvoice.orders.count loop
      apex_json.write(pInvoice.orders(elem));
    end loop;
    
    apex_json.close_array;
  end;
  
  /*
  ������� ������ T_DELIVERY_CAR � JSON
  */
  procedure PrintT_DELIVERY_CAR(pDeliveryCar in t_mcsf_api_delivery_car) is
  begin
    apex_json.write('driver_fio', pDeliveryCar.driver_fio, true);
    apex_json.write('car_number', pDeliveryCar.car_number, true);
    apex_json.write('driver_phone', pDeliveryCar.driver_phone, true);
  end;
  
  /*
  ������� ������ T_CONTRACTOR_SHORT � JSON
  */
  procedure PrintT_CONTRACTOR_SHORT(pContractor in t_mcsf_api_contractor_short) is
  begin
    apex_json.write('id', pContractor.id, true);
    apex_json.write('name', pContractor.name, true);
  end;
  
  -- �.�., 21.06.2017
  procedure PrintT_FILES_depricated(p_files in mcsf_api.t_files)
  is
  begin
    apex_json.write('id', p_files.file_id, true);
    apex_json.write('name', p_files.file_name, true);
    apex_json.write('size', p_files.file_size, true);
  end;

-- �.�., 22.06.2017
function make_filter_string_depricated(
    p_col varchar2
  , p_type varchar2
  , p_value varchar2
) return varchar2
is
  v_col varchar2(50) := p_col;
  v_type varchar2(20) := lower(trim(nvl(p_type, '=')));
  v_value varchar2(2000) := replace(regexp_replace(p_value, ' *, *', ','), '''', '');
  vv_value v_value%type := '';
  v number; i number; d date;
  v_filter varchar2(2000);
begin
-- Initial input check:
  if v_col is null then return 'Error: No Column Name'; end if;
  begin
    select 1 into v from dual where v_type in ('=', '!=', '>', '<', '>=', '<=', 'like', 'between');
  exception when no_data_found then return 'Error: Wrong Type';
  end;
  if v_value is null then return 'Error: No Value'; end if;
-- Array analysis and datatype cleanup:
  i := 0;
  for c in (
  select regexp_substr(v_value,'[^,]+', 1, level) as elem from dual
  connect by regexp_substr(v_value, '[^,]+', 1, level) is not null
  ) loop
    i := i + 1;
    begin
      d := to_date(c.elem, rest_api.PkgDefaultDateFormat);
      --d := to_date(c.elem, 'yyyy-mm-dd'); -- �������� �� ����������� ������, ��� � ��
      vv_value := vv_value || ',' || 'to_date(''' || c.elem || ''', '''||rest_api.PkgDefaultDateFormat||''')'; -- element IS date
    exception when others then
      begin
        vv_value := vv_value || ',' || to_char(to_number(c.elem)); -- element IS number
      exception when others then
        vv_value := vv_value || ',' || '''' || c.elem || ''''; -- element IS NOT number, NOR date
      end;
    end;
  end loop;
  vv_value := ltrim(vv_value, ',');
-- Filter build:
  if i = 1 and v_type in ('=', '!=', '>', '<', '>=', '<=', 'like') then
    v_filter := v_col || ' ' || v_type || ' ' || vv_value;
  elsif i = 2 and v_type in ('between') then
    v_filter := v_col || ' between ' || regexp_replace(vv_value, ',.+$', '') || ' and ' || regexp_replace(vv_value, '^.+,', '');
  elsif i > 1 and v_type in ('=') then
    v_filter := v_col || ' in (' || vv_value || ')';
  else
    return 'Error: Wrong Type/Value combination';
  end if;
  return v_filter;
end make_filter_string_depricated;

function IsDate(pTestStrin varchar, pFormat out varchar) return boolean is
  lDate date;
  lRes boolean := false;
begin
  
  if lRes != true then
    begin
      select to_date(pTestStrin, rest_api.PkgDefaultDateShortFormat) into lDate from dual;
      lRes := true;
      pFormat := rest_api.PkgDefaultDateShortFormat;
    exception
      when others then
        null;
    end;
  end if;
  
  if lRes then return lRes; end if;
  
  begin
    select to_date(pTestStrin, rest_api.PkgDefaultDateFormat) into lDate from dual;
    lRes := true; 
    pFormat := rest_api.PkgDefaultDateFormat;
  exception 
    when others then null;
  end;
  
  return lRes;
  
end;

function PrepareSortFilter(pFilterName varchar, pFileldName varchar default null) return varchar2 is
  lVal varchar2(10);
  lRes varchar2(1000);
begin
  
  lVal := apex_json.get_varchar2('order.' || pFilterName, null);
  
  if lVal != 'asc' and lVal != 'desc' then return null; end if;
  
  if lVal is not null then
    if pFileldName is not null then
      lRes := pFileldName || ' ' || lVal;
    else
      lRes := pFilterName || ' ' || lVal;
    end if;
  end if;
  
  return lRes;
end;

function PrepareSqlFilter(pFilterName varchar, pFileldName varchar default null) return varchar2 is
  lValNode apex_json.t_value;
  lVal varchar2(100);
  lValType varchar2(20);
  lValsArrCount number;
  lType varchar2(10);
  lTempNum number;
  lDateFormat varchar2(100);
  lRes varchar2(1000);
begin 
  -- �������� ����
  lValNode := apex_json.get_value('filter.' || pFilterName || '.value');
  
  lType := apex_json.get_varchar2('filter.' || pFilterName || '.type', p_default => '=');
  
  begin
    select 1 into lTempNum from dual where lType in ('=', '!=', '>', '<', '>=', '<=', 'like', 'between', 'in', 'not in');
  exception when no_data_found then 
    return null;
  end;
  
  -- ��������� ���
  if lValNode.kind = 2 then
           --lValType := 'boolean';
           lVal := 'true';
           lRes := lRes || lVal;

       elsif lValNode.kind = 3 then
           --lValType := 'boolean';
           lVal := 'false';
           lRes := lRes || lVal;

       elsif lValNode.kind = 4 then
           --lValType := 'number';
           lVal := to_char( lValNode.number_value );
           lRes := lRes || lVal;

       elsif lValNode.kind = 5 then
           lValType := 'varchar2';
           lVal := replace(lValNode.varchar2_value, '''', '"');
           
           -- ��������� �� 'null'
           if lVal = 'null' then lValType := 'null'; end if;
           
           if lType = 'like' then lVal := '%' || lVal || '%'; end if;
           
           -- ��������� �������� �� ��� �����
           if IsDate(lVal, lDateFormat) then lValType := 'date'; end if;
           
           if lValType = 'date' then
             lRes := lRes || 'to_date(''' || lVal || ''',' || '''' || lDateFormat || '''' || ')';
           elsif lValType = 'null' then
             lRes := lRes || lVal;
             if lType = '!=' then lType := 'is not'; else lType := 'is'; end if;
           else
             lRes := lRes || '''' || lVal || '''';
           end if;
           
           if lType = 'between' or lType = 'in' then return null; end if;

       elsif lValNode.kind = 7 then
           lValType := 'array';
           lVal := null;
           
           lValsArrCount := apex_json.get_count('filter.' || pFilterName || '.value');
           
           if lValsArrCount > 1 and lType = '=' then lType := 'in'; end if;
           
           if lValsArrCount > 1 and lType = '!=' then lType := 'not in'; end if;
           
           if lValsArrCount > 1 and lType != 'between' and lType != 'in' and lType != 'not in' then return null; end if;
           
           if lValsArrCount != 2 and lType = 'between' then return null; end if;
           
           for i in 1..lValsArrCount loop
             lValNode := apex_json.get_value('filter.' || pFilterName || '.value[%d]',p0=> i);
             
             if i > 1 then
               if lType = 'between' then
                 lRes := lRes || ' and ';
               else
                 lRes := lRes || ', ';
               end if;
             end if;
             
             if lValNode.kind = 2 then
                 lValType := 'array of boolean';
                 lVal := 'true';
                 lRes := lRes || lVal;
             
             elsif lValNode.kind = 3 then
                 lValType := 'array of boolean';
                 lVal := 'false';
                 lRes := lRes || lVal;

             elsif lValNode.kind = 4 then
                 lValType := 'array of number';
                 lVal := to_char( lValNode.number_value );
                 lRes := lRes || lVal;

             elsif lValNode.kind = 5 then
                 lValType := 'array of varchar2';
                 lVal := replace(lValNode.varchar2_value, '''', '"');
                 
                 -- ��������� �������� �� ��� �����
                 if IsDate(lVal, lDateFormat) then lValType := 'array of date'; end if;
                 
                 if lValType = 'array of date' then
                   lRes := lRes || 'to_date(''' || lVal || ''',' || '''' || lDateFormat || '''' || ')';
                 else
                   lRes := lRes || '''' || lVal || '''';
                 end if;
             
             end if;
             
           end loop;
           
           if lType = 'in' or lType = 'not in' then
             lRes := '(' || lRes || ')';
           end if;
           
    end if;
    
    if lRes is null then 
      -- ��������� �������� �� ������ ������ �������
      lVal := apex_json.get_varchar2('filter.' || pFilterName, null);
      
      if lVal is not null then
        lVal := replace(lVal, '''', '"');
        
        -- ��������� �� 'null'
        if lVal = 'null' then lValType := 'null'; end if;
        
        if IsDate(lVal, lDateFormat) then lValType := 'date'; end if;
        
        if lValType = 'date' then
          lRes := lRes || 'to_date(''' || lVal || ''',' || '''' || lDateFormat || '''' || ')';
        elsif lValType = 'null' then
          lRes := lRes || lVal;
          if lType = '!=' then lType := 'is not'; else lType := 'is'; end if;
        else
          lRes := lRes || '''' || lVal || '''';
        end if;
      end if; 
    end if;
    
    if lRes is null then return lRes; end if;
    
    if pFileldName is not null then
      lRes := pFileldName || ' ' || lType || ' ' || lRes;
    else
      lRes := pFilterName || ' ' || lType || ' ' || lRes;
    end if;
  
  return lRes;

end PrepareSqlFilter;

procedure AddFilter(pFilterName varchar, pFileldName varchar default null, pFilters in out varchar2) is
  lDate date;
  lRes boolean := false;
  lTemp varchar2(250);
begin
  
  lTemp := rest_api_helper.PrepareSqlFilter(pFilterName, pFileldName);
  
  if lTemp is not null then
    
     if pFilters is not null then pFilters := pFilters || ' and '; end if;
     
     pFilters := pFilters || lTemp;
     lTemp := null;
     
  end if;
  
  return;
end;

procedure AddSortFilter(pFilterName varchar, pFileldName varchar default null, pFilters in out varchar2) is
  lDate date;
  lRes boolean := false;
  lTemp varchar2(250);
begin
  
  lTemp := rest_api_helper.PrepareSortFilter(pFilterName, pFileldName);
  
  if lTemp is not null then
    
     if pFilters is not null then pFilters := pFilters || ', '; end if;
     
     pFilters := pFilters || lTemp;
     lTemp := null;
     
  end if;
  
  return;
end;

procedure SaveLog(pLog clob) is
begin
  insert into rest_api_log (log_date, log) values (sysdate, pLog);
  commit;
exception
  when others then
    null;
end;

function ClobToVarcharTable(pClob clob) return apex_application_global.vc_arr2 is
  l_clob_tab apex_application_global.vc_arr2;
begin
  declare
    c_max_vc2_size pls_integer := 8100; -- Bug with dbms_lob.substr 8191
    l_offset pls_integer := 1;
    l_clob_length pls_integer;
  begin
    l_clob_length := dbms_lob.getlength(pClob);
    while l_offset <= l_clob_length loop
      l_clob_tab(l_clob_tab.count + 1) :=
        dbms_lob.substr (
         lob_loc => pClob,
         amount => least(c_max_vc2_size, l_clob_length - l_offset +1 ),
         offset => l_offset);
      l_offset := l_offset + c_max_vc2_size;
    end loop;
  end;
  
  return l_clob_tab;
  
end;

end REST_API_HELPER;
/
