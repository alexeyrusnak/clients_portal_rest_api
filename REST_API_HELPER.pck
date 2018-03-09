create or replace package REST_API_HELPER is

  /*
  Выводит объект T_DOC в JSON
  */
 -- 26.11.17 procedure PrintT_DOC(pDoc in T_DOC);
-- procedure PrintT_DOC(pDoc in mcsf_api.t_docs);

  /*
  Процедура выдачи документов по заказу
  27.11.2017  A.Starshinin
  */
  
  procedure PrintOrder_Docs(pDoc in t_order_docs);

  /*
  Выводит объект T_DOCS в JSON
  */
 procedure PrintT_DOCS(pDoc in mcsf_api.t_docs);


  /*
  Выводит объект T_UNIT в JSON
  */
  procedure PrintT_UNIT(pUnit in T_UNIT);

  /*
  Выводит объект T_POINT в JSON
  */
  procedure PrintT_POINT(pPoint in T_POINT);

  /*
  Выводит объект T_CARGO в JSON
  */
  procedure PrintT_CARGO(pCargo in T_CARGO);
  
-- Ю.К. 21.06.2017
procedure PrintT_FILES(p_files in mcsf_api.t_files);
  
-- Ю.К. 21.06.2017
-- Литеральная реализация SQL Фильтра
function make_filter_string(
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
 
end REST_API_HELPER;
/
create or replace package body REST_API_HELPER is

  /*
  Выводит объект T_DOC в JSON
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
  Выводит объект T_DOC в JSON
  */
  procedure PrintOrder_DOCS(pDoc in t_order_docs) is
  begin
    apex_json.write('id', pDoc.id, true);
    apex_json.write('order_id', pDoc.order_id, true);
    apex_json.write('type_id', pDoc.type_id, true);
    apex_json.write('doc_type', pDoc.doc_type, true);
    apex_json.write('doc_date', pDoc.doc_date, true);
    apex_json.write('uploaded_at', pDoc.uploaded_at, true);
    apex_json.write('owner', pDoc.owner, true);
 end;

 /*
  Выводит объект T_DOCS в JSON
  */
  procedure PrintT_DOCS(pDoc in mcsf_api.t_docs) is
  begin
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

  /*
  Выводит объект T_UNIT в JSON
  */
  procedure PrintT_UNIT(pUnit in T_UNIT) is
  begin
    apex_json.write('type_unit', pUnit.type_unit, true);
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
  Выводит объект T_POINT в JSON
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
  Выводит объект T_CARGO в JSON
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
  
  -- Ю.К., 21.06.2017
  procedure PrintT_FILES(p_files in mcsf_api.t_files)
  is
  begin
    apex_json.write('id', p_files.file_id, true);
    apex_json.write('name', p_files.file_name, true);
    apex_json.write('size', p_files.file_size, true);
  end PrintT_FILES;

-- Ю.К., 22.06.2017
function make_filter_string(
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
      --d := to_date(c.elem, 'yyyy-mm-dd'); -- изменено на константный формат, как в ТЗ
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
end make_filter_string;

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
  -- Получаем ноду
  lValNode := apex_json.get_value('filter.' || pFilterName || '.value');
  
  lType := apex_json.get_varchar2('filter.' || pFilterName || '.type', p_default => '=');
  
  begin
    select 1 into lTempNum from dual where lType in ('=', '!=', '>', '<', '>=', '<=', 'like', 'between', 'in', 'not in');
  exception when no_data_found then 
    return null;
  end;
  
  -- Проверяем тип
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
           
           if lType = 'like' then lVal := '%' || lVal || '%'; end if;
           
           -- Проверяем является ли тип датой
           if IsDate(lVal, lDateFormat) then lValType := 'date'; end if;
           
           if lValType = 'date' then
             lRes := lRes || 'to_date(''' || lVal || ''',' || '''' || lDateFormat || '''' || ')';
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
                 
                 -- Проверяем является ли тип датой
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
      -- Проверяем явялется ли фильтр просто строкой
      lVal := apex_json.get_varchar2('filter.' || pFilterName, null);
      
      if lVal is not null then
        lVal := replace(lVal, '''', '"');
        
        if IsDate(lVal, lDateFormat) then lValType := 'date'; end if;
        
        if lValType = 'date' then
          lRes := lRes || 'to_date(''' || lVal || ''',' || '''' || lDateFormat || '''' || ')';
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

end REST_API_HELPER;
/
