CREATE OR REPLACE PACKAGE REST_API AS

  PkgVersion    varchar2(10) := 'v.1.0.0'; -- Версия пакета
  ApexAppId     number := 100; -- ИД Апекс-приложения
  ApexAppPageId number := 1; -- ИД страницы Апекс-приложения
  WorkspaceName varchar2(255) := 'REST'; -- Воркспейс

  PkgDefaultDateFormat varchar2(255) := 'DD.MM.YYYY HH24:MI:SS'; -- Формат даты при конвертациях в строку и обратно
  PkgDefaultOffset     number := 1; -- Значение по умолчанию для переменной offset
  PkgDefaultLimit      number := 10; -- Значение по умолчанию для переменной limit

  PkgDefaultPeriodIndays number := 1450; -- Период по умолчанию для всех запросов в днях

  type ErrorsArrType is varray(10) of rest_api_err;

  Errors ErrorsArrType;

  /*
  Выводит ошибку
  */
  procedure PrintErrorJson(pErrNum in number);

  /*
  Выводит ошибку
  */
  procedure PrintErrorJson(pErrNum in rest_api_err);

  /*
  Выводит clob в http
  */
  procedure HtpPrn(pclob in clob);

  /*
  Главная процедура, точка входа
  */
  procedure Api(pBody in clob);

  /*
  Логин
  */
  function Login return rest_api_err;

  /*
  Логаут
  */
  function Logout return rest_api_err;

  /*
  Проверка годности сессии
  */
  function IsSessionValid return boolean;

  /*
  Вывод данных пользователя
  */
  procedure PrintEcho;

  /*
  Сотрудники - пока просто пример
  */
  procedure Employees(pStatus out number);

  /*
  Вывод списка заказов
  */

  type t_OrderTest is record(
    empno emp.empno%type,
    ename emp.ename%type,
    job   emp.job%type,
    rn    number);

  type tbl_OrdersTest is table of t_OrderTest;

  function getOrdersTest return tbl_OrdersTest
    pipelined
    parallel_enable;

  function PrintOrders return rest_api_err;

END REST_API;
/
CREATE OR REPLACE PACKAGE BODY REST_API AS

  procedure PrintErrorJson(pErrNum in number) is
  begin
  
    PrintErrorJson(Errors(pErrNum));
  
  end;

  procedure PrintErrorJson(pErrNum in rest_api_err) is
  begin
  
    apex_json.open_object('error');
  
    apex_json.write('code', pErrNum.code);
  
    apex_json.write('message', pErrNum.message);
  
    apex_json.close_object;
  
  end;

  procedure HtpPrn(pclob in clob) is
    v_excel varchar2(32000);
    v_clob  clob := pclob;
  begin
    while length(v_clob) > 0 loop
      begin
        if length(v_clob) > 16000 then
          v_excel := substr(v_clob, 1, 16000);
          htp.prn(v_excel);
          v_clob := substr(v_clob, length(v_excel) + 1);
        else
          v_excel := v_clob;
          htp.prn(v_excel);
          v_clob  := '';
          v_excel := '';
        end if;
      end;
    end loop;
  end;

  procedure Api(pBody in clob) is
    lWorkspaceId number;
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOperation varchar2(255) := '';
  
  begin
  
    apex_json.initialize_clob_output;
  
    apex_json.open_object;
  
    begin
      lWorkspaceId := apex_util.find_security_group_id(p_workspace => WorkspaceName);
      apex_util.set_security_group_id(p_security_group_id => lWorkspaceId);
    exception
      when others then
        lIsSuccess     := false;
        lError         := Errors(3);
        lError.message := sqlerrm;
    end;
  
    if lIsSuccess then
      begin
        apex_json.parse(pBody);
      exception
        when others then
          lIsSuccess     := false;
          lError         := Errors(3);
          lError.message := sqlerrm;
      end;
    end if;
  
    if lIsSuccess then
      begin
        lOperation := apex_json.get_varchar2('operation');
      exception
        when others then
          lIsSuccess := false;
          lError     := Errors(4);
      end;
    end if;
  
    if lIsSuccess then
      CASE lOperation
      
        WHEN 'login' THEN
          lError := Login();
          if lError.success != 1 then
            lIsSuccess := false;
          end if;
        
        WHEN 'logout' THEN
          if IsSessionValid() then
            lError := Logout();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'echo' THEN
          if IsSessionValid() then
            apex_json.open_object('data');
            PrintEcho();
            apex_json.close_object;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'orders' THEN
          if IsSessionValid() then
            lError := PrintOrders();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        ELSE
          lIsSuccess := false;
          lError     := Errors(4);
        
      END CASE;
    end if;
  
    apex_json.write('success', lIsSuccess);
  
    if lIsSuccess != true then
      PrintErrorJson(lError);
    end if;
  
    apex_json.close_object;
  
    --htp.p(APEX_JSON.get_clob_output);
    HtpPrn(APEX_JSON.get_clob_output);
  
    apex_json.free_output;
  
  end;

  function Login return rest_api_err is
  
    lUsername varchar2(255);
    lPassword varchar2(255);
  
    lSession         varchar2(40);
    lToken           varchar2(40);
    lSessionLifeTime date;
  
    lIsSessionValid  boolean;
    lIsAuthenticated boolean;
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
  begin
  
    begin
      lUsername := apex_json.get_varchar2('data.username');
      lPassword := apex_json.get_varchar2('data.password');
    exception
      when others then
        lIsSuccess     := false;
        lError         := Errors(3);
        lError.message := sqlerrm;
    end;
  
    if lIsSuccess then
      begin
      
        apex_custom_auth.login(p_uname      => lUsername,
                               p_password   => lPassword,
                               p_session_id => apex_custom_auth.get_next_session_id,
                               p_app_page   => ApexAppId || ':' ||
                                               ApexAppPageId);
      
      exception
        when others then
          lError         := Errors(2);
          lError.message := sqlerrm;
          lIsSuccess     := false;
      end;
    end if;
  
    if lIsSuccess then
      lIsSessionValid  := APEX_CUSTOM_AUTH.IS_SESSION_VALID;
      lIsAuthenticated := APEX_AUTHENTICATION.IS_AUTHENTICATED;
    
      if lIsSessionValid and lIsAuthenticated then
        lIsSuccess := true;
      else
        lIsSuccess := false;
      end if;
    
      apex_json.open_object('data');
    
      if lIsSuccess then
        lSession := apex_application.g_instance;
        lToken   := dbms_random.string('A', 40);
        apex_json.write('session', lSession);
        apex_json.write('token', lToken);
        APEX_UTIL.set_preference('TOKEN',
                                 lToken,
                                 APEX_CUSTOM_AUTH.GET_USERNAME);
      
        select t.session_idle_timeout_on
          into lSessionLifeTime
          from APEX_WORKSPACE_SESSIONS t
         where t.apex_session_id = lSession
           and t.workspace_name = WorkspaceName;
      
        apex_json.write('session_lifetime', lSessionLifeTime);
      
        PrintEcho();
      
      else
        lError := Errors(2);
      end if;
    
      apex_json.close_object;
    end if;
  
    return lError;
  end;

  function Logout return rest_api_err is
  
    lError rest_api_err := Errors(1);
  
  begin
  
    begin
    
      APEX_UTIL.set_preference('TOKEN',
                               dbms_random.string('A', 40),
                               APEX_CUSTOM_AUTH.GET_USERNAME);
    
    exception
      when others then
        lError         := Errors(2);
        lError.message := sqlerrm;
    end;
  
    return lError;
  
  end;

  function IsSessionValid return boolean is
  
    lIsAuthenticated boolean;
  
    lIsSuccess boolean := true;
  
    lSession varchar2(255);
  
    lToken varchar2(255);
  
  begin
  
    begin
      lSession := apex_json.get_varchar2('session');
      lToken   := apex_json.get_varchar2('token');
    exception
      when others then
        lIsSuccess := false;
    end;
  
    apex_application.g_instance     := lSession;
    apex_application.g_flow_id      := ApexAppId;
    apex_application.g_flow_step_id := ApexAppPageId;
  
    lIsAuthenticated := APEX_AUTHENTICATION.IS_AUTHENTICATED;
  
    if lIsAuthenticated then
      if APEX_UTIL.get_preference('TOKEN', APEX_CUSTOM_AUTH.GET_USERNAME) =
         lToken then
        lIsSuccess := true;
        APEX_CUSTOM_AUTH.SET_SESSION_ID(lSession);
        APEX_CUSTOM_AUTH.SET_USER(APEX_CUSTOM_AUTH.GET_USERNAME);
      else
        lIsSuccess := false;
      end if;
    else
      lIsSuccess := false;
    end if;
  
    return lIsSuccess;
  end;

  procedure PrintEcho is
    lCurrentUserId   number;
    lCurrentUserName varchar2(255);
  begin
    apex_json.open_object('user');
  
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCurrentUserId   := APEX_UTIL.GET_USER_ID(lCurrentUserName);
  
    apex_json.write('id', lCurrentUserId);
    apex_json.write('login', lCurrentUserName);
    apex_json.write('email', APEX_UTIL.GET_EMAIL(lCurrentUserName));
    apex_json.write('phone', APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 2));
    apex_json.write('first_name',
                    APEX_UTIL.GET_FIRST_NAME(lCurrentUserName));
    apex_json.write('last_name', APEX_UTIL.GET_LAST_NAME(lCurrentUserName));
  
    apex_json.write('company',
                    APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1));
  
    apex_json.close_object;
  end;

  procedure Employees(pStatus out number) is
  
    lIsSuccess boolean;
  
    lError rest_api_err := Errors(3);
  
    lRc sys_refcursor;
  begin
  
    --lIsSuccess := IsSessionValid(pSession, pToken);
  
    apex_json.initialize_clob_output;
  
    apex_json.open_object;
  
    apex_json.write('success', lIsSuccess);
  
    if not lIsSuccess then
      PrintErrorJson(lError);
      pStatus := 401;
    else
      pStatus := 200;
      open lRc for
        select emp.*, row_number() over(order by empno) rn from emp;
      apex_json.write('data', lRc);
    end if;
  
    apex_json.close_object;
  
    htp.p(APEX_JSON.get_clob_output);
  
    apex_json.free_output;
  
  end;

  /*
  Вывод списка заказов
  */
  function PrintOrders return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    --lCurrentUserId   number;
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lCollectionName   varchar2(255) := 'ORDERS';
    lCollectionExists boolean;
  
    lRc sys_refcursor;
  
    lOffset number;
    lLimit  number;
  
    lPeriodFrom date := SYSDATE - PkgDefaultPeriodIndays;
    lPeriodTo   date := SYSDATE;
    lStatusId   number := null;
  
    lFiltersState    varchar2(255) := null;
    lFiltersPrevious varchar2(255) := null;
  
    lShouldResetCollection boolean := true;
    lColectionCount        number := 0;
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    --lCurrentUserId   := APEX_UTIL.GET_USER_ID(lCurrentUserName);
    lCompanyId := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1));
  
    -- filters
    begin
      lOffset := apex_json.get_number(p_path    => 'offset',
                                      p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit',
                                      p_default => PkgDefaultLimit);
    
      lPeriodFrom := apex_json.get_date(p_path    => 'filter.date_from.value',
                                        p_format  => PkgDefaultDateFormat,
                                        p_default => SYSDATE -
                                                     PkgDefaultPeriodIndays);
    
      lPeriodTo := apex_json.get_date(p_path    => 'filter.date_to.value',
                                      p_format  => PkgDefaultDateFormat,
                                      p_default => SYSDATE);
    
      lStatusId := apex_json.get_number(p_path    => 'filter.status_id',
                                        p_default => null);
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
  
    -- Проверяем, изменились ли фильтры
    lFiltersPrevious := apex_util.get_preference(lCollectionName ||
                                                 apex_application.g_instance,
                                                 lCurrentUserName);
  
    lFiltersState := to_char(lPeriodFrom, PkgDefaultDateFormat) ||
                     to_char(lPeriodTo, PkgDefaultDateFormat) ||
                     to_char(lStatusId);
  
    if lFiltersPrevious = lFiltersState then
      lShouldResetCollection := false;
    end if;
  
    apex_util.set_preference(lCollectionName ||
                             apex_application.g_instance,
                             lFiltersState,
                             lCurrentUserName);
  
    if lIsSuccess then
    
      -- Формирование коллекции
      if lShouldResetCollection then
      
        lCollectionExists := APEX_COLLECTION.COLLECTION_EXISTS(lCollectionName);
      
        if lCollectionExists then
          APEX_COLLECTION.DELETE_COLLECTION(lCollectionName);
        end if;
      
        APEX_COLLECTION.CREATE_COLLECTION(lCollectionName);
      
        for l_c in (select *
                      from TABLE(sbc.mcsf_api.get_orders(pClntId    => lCompanyId,
                                                         pDate_from => lPeriodFrom,
                                                         pDate_to   => lPeriodTo,
                                                         pStatus_id => lStatusId))) loop
          APEX_COLLECTION.ADD_MEMBER(p_collection_name => lCollectionName,
                                     p_c001            => l_c.id,
                                     p_c002            => l_c.place_from,
                                     p_c003            => l_c.place_to,
                                     p_c004            => l_c.status,
                                     p_c005            => l_c.status_id,
                                     p_c006            => l_c.receivables,
                                     p_c007            => l_c.amount,
                                     p_c008            => l_c.notification_count,
                                     p_c009            => l_c.cargo_name,
                                     p_c010            => l_c.contractor,
                                     p_c011            => l_c.created_at,
                                     p_c012            => to_char(l_c.date_from,
                                                                  PkgDefaultDateFormat),
                                     p_c013            => to_char(l_c.date_to,
                                                                  PkgDefaultDateFormat),
                                     p_c014            => l_c.ts_id,
                                     p_c015            => l_c.port_svh,
                                     p_c016            => l_c.cargo_country);
        end loop;
      
      end if;
    
      -- Постраничный вывод данных из коллекции
      open lRc for
        select c.seq_id "seq_id",
               to_number(c.c001) "id",
               c.c002 "place_from",
               c.c003 "place_to",
               c.c004 "status",
               to_number(c.c005) "status_id",
               to_number(c.c006) "receivables",
               to_number(c.c007) "amount",
               to_number(c.c008) "notification_count",
               c.c009 "cargo_name",
               c.c010 "contractor",
               c.c011 "created_at",
               c.c012 "date_from",
               c.c013 "date_to",
               c.c014 "ts_id",
               c.c015 "port_svh",
               c.c016 "cargo_country"
        
          from apex_collections c
         where c.collection_name = lCollectionName
           and c.seq_id > lOffset
           and c.seq_id <= lOffset + lLimit;
    
      apex_json.write('data', lRc);
    
      -- Pager
      apex_json.open_object('pager');
    
      apex_json.write('offset', lOffset);
    
      select count(c.seq_id)
        into lColectionCount
        from apex_collections c
       where c.collection_name = lCollectionName;
    
      apex_json.write('total', lColectionCount);
    
      apex_json.close_object();
    
    end if;
  
    return lError;
  
  end;

  function getOrdersTest return tbl_OrdersTest
    pipelined
    parallel_enable is
  begin
    for cur in (select emp.empno,
                       emp.ename,
                       emp.job,
                       row_number() over(order by empno) rn
                  from emp) loop
    
      pipe row(cur);
    
    end loop;
  
    return;
  
  end;

BEGIN

  Errors := ErrorsArrType();

  Errors.EXTEND(5);

  Errors(1) := rest_api_err('success', 'success', 1);

  Errors(2) := rest_api_err('unauthorized', 'Unauthorized', 0);

  Errors(3) := rest_api_err('service_internal_error',
                            'Service internal error',
                            0);

  Errors(4) := rest_api_err('bad_operation', 'Bad operation', 0);

  Errors(5) := rest_api_err('bad_filter', 'Bad filter', 0);

END REST_API;
/
